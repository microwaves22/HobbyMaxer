import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/auth/login_screen.dart';

Map<String, dynamic> _meJson() => {
      'id': 9,
      'family_id': 2,
      'email': 'mom@x.com',
      'display_name': 'Mom',
      'role': 'parent',
      'mode': null,
      'points_balance': 0,
      'created_at': '2026-01-01T00:00:00',
    };

MockClient _mock({bool loginFails = false}) {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
    if (request.method == 'POST' && path == '/auth/login') {
      if (loginFails) {
        return json({'detail': 'Incorrect email or password.'}, 401);
      }
      return json({'access_token': 'tok', 'token_type': 'bearer'});
    }
    if (path == '/auth/me') return json(_meJson());
    if (path == '/tasks/') return json([]);
    if (path == '/families/me') {
      return json({
        'id': 2,
        'name': 'Fam',
        'created_at': '2026-01-01T00:00:00',
        'members': [_meJson()],
      });
    }
    return http.Response('not found', 404);
  });
}

Future<void> _pumpLogin(WidgetTester tester, AuthSession session) async {
  await tester.pumpWidget(
    AuthScope(
      session: session,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Backend login', () {
    testWidgets('login navigates to a synced dashboard', (tester) async {
      final session = AuthSession(
        client: ApiClient(inner: _mock()),
        tokenStore: InMemoryTokenStore(),
      );
      await _pumpLogin(tester, session);

      await tester.enterText(find.byType(TextField).at(0), 'mom@x.com');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Mom!'), findsOneWidget);
      // The dashboard syncs over an unawaited future; wait for it to land.
      for (var i = 0;
          i < 50 && find.text('Review queue (0)').evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      // Synced (empty) queue, not the two seeded demo tasks.
      expect(find.text('Review queue (0)'), findsOneWidget);
    });

    testWidgets('login failure shows the server message', (tester) async {
      final session = AuthSession(
        client: ApiClient(inner: _mock(loginFails: true)),
        tokenStore: InMemoryTokenStore(),
      );
      await _pumpLogin(tester, session);

      await tester.enterText(find.byType(TextField).at(0), 'mom@x.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
