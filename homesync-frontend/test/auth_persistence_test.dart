import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/splash_screen.dart';

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

MockClient _mock() {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
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

void main() {
  group('Auth persistence on startup', () {
    testWidgets('restored session auto-routes from Splash to Home',
        (tester) async {
      final store = InMemoryTokenStore();
      await store.writeToken('saved');
      final session = AuthSession(
        client: ApiClient(inner: _mock()),
        tokenStore: store,
      );
      // Mirror main(): restore runs in the background while Splash shows.
      unawaited(session.restore());

      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(session.isAuthenticated, isTrue);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Hello, Mom!'), findsOneWidget);
    });

    test('restore marks the session resolved and shares one flight',
        () async {
      final store = InMemoryTokenStore();
      await store.writeToken('saved');
      var meCalls = 0;
      final mock = MockClient((request) async {
        meCalls++;
        return http.Response(jsonEncode(_meJson()), 200);
      });
      final session = AuthSession(
        client: ApiClient(inner: mock),
        tokenStore: store,
      );

      expect(session.hasRestored, isFalse);
      await Future.wait([session.restore(), session.restore()]);

      expect(session.isAuthenticated, isTrue);
      expect(session.hasRestored, isTrue);
      expect(session.isRestoring, isFalse);
      expect(meCalls, 1);
      await session.restore();
      expect(meCalls, 1);
    });

    testWidgets('no saved token stays on Splash with login actions',
        (tester) async {
      final session = AuthSession(
        client: ApiClient(inner: _mock()),
        tokenStore: InMemoryTokenStore(),
      );
      unawaited(session.restore());

      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(session.isAuthenticated, isFalse);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });
  });
}
