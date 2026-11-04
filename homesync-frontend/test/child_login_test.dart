import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/auth/child_login_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/settings/account_settings_screen.dart';
import 'package:homesync/views/settings/child_pin_screen.dart';

Map<String, dynamic> _kidUser() => {
      'id': 12,
      'family_id': 2,
      'email': null,
      'display_name': 'Maya',
      'role': 'child',
      'mode': 'kids',
      'points_balance': 30,
      'created_at': '2026-01-01T00:00:00',
    };

Map<String, dynamic> _parentUser() => {
      'id': 9,
      'family_id': 2,
      'email': 'm@example.com',
      'display_name': 'Mom',
      'role': 'parent',
      'mode': null,
      'points_balance': 0,
      'created_at': '2026-01-01T00:00:00',
    };

MockClient _loginMock({bool loginFails = false}) {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
    if (request.method == 'POST' && path == '/auth/child-login') {
      if (loginFails) {
        return json({'detail': 'Invalid PIN.'}, 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      assert(body['user_id'] == 12);
      return json({
        'access_token': 'kid-tok',
        'token_type': 'bearer',
        'user': _kidUser(),
      });
    }
    if (path == '/tasks/') return json([]);
    if (path == '/families/me') {
      return json({'detail': 'Parent role required.'}, 403);
    }
    return http.Response('not found', 404);
  });
}

Future<AuthSession> _freshSession(MockClient mock) async {
  return AuthSession(
    client: ApiClient(inner: mock),
    tokenStore: InMemoryTokenStore(),
  );
}

Future<AuthSession> _parentSession(MockClient mock) async {
  final session = AuthSession(
    client: ApiClient(inner: mock),
    tokenStore: InMemoryTokenStore(),
  );
  await session.register(
    email: 'm@example.com',
    password: 'secret12',
    displayName: 'Mom',
  );
  return session;
}

void main() {
  group('ChildLoginScreen', () {
    Future<void> pumpLogin(WidgetTester tester, MockClient mock) async {
      final session = await _freshSession(mock);
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: ChildLoginScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('kid login lands on the child dashboard', (tester) async {
      await pumpLogin(tester, _loginMock());

      await tester.enterText(find.byType(TextField).at(0), '12');
      await tester.enterText(find.byType(TextField).at(1), '2468');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Maya!'), findsOneWidget);
    });

    testWidgets('blank PIN still submits (unset PINs stay open)',
        (tester) async {
      await pumpLogin(tester, _loginMock());

      await tester.enterText(find.byType(TextField).at(0), '12');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Maya!'), findsOneWidget);
    });

    testWidgets('wrong PIN shows the server message', (tester) async {
      await pumpLogin(tester, _loginMock(loginFails: true));

      await tester.enterText(find.byType(TextField).at(0), '12');
      await tester.enterText(find.byType(TextField).at(1), '0000');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid PIN.'), findsOneWidget);
      expect(find.text('Kid login'), findsOneWidget);
    });
  });

  group('ChildPinScreen', () {
    Map<String, dynamic>? patchedBody;
    String? patchedPath;

    MockClient pinMock() {
      return MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status);
        final path = request.url.path;
        if (request.method == 'POST' && path == '/auth/register') {
          return json({
            'access_token': 'tok',
            'token_type': 'bearer',
            'user': _parentUser(),
          }, 201);
        }
        if (request.method == 'GET' && path == '/families/me') {
          return json({
            'id': 2,
            'name': 'Fam',
            'invite_code': 'AB12CD',
            'created_at': '2026-01-01T00:00:00',
            'members': [
              {..._parentUser(), 'has_child_pin': false},
              {..._kidUser(), 'has_child_pin': true},
              {
                'id': 13,
                'family_id': 2,
                'email': null,
                'display_name': 'Leo',
                'role': 'child',
                'mode': 'teen',
                'points_balance': 0,
                'has_child_pin': false,
                'created_at': '2026-01-01T00:00:00',
              },
            ],
          });
        }
        if (request.method == 'PATCH' && path.endsWith('/pin')) {
          patchedPath = path;
          patchedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return json(_kidUser());
        }
        return http.Response('not found', 404);
      });
    }

    Future<void> pumpPins(WidgetTester tester) async {
      patchedBody = null;
      patchedPath = null;
      final session = await _parentSession(pinMock());
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: ChildPinScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('rows show PIN status per child', (tester) async {
      await pumpPins(tester);

      expect(find.text('Maya'), findsOneWidget);
      expect(find.text('PIN set'), findsOneWidget);
      expect(find.text('Leo'), findsOneWidget);
      expect(find.text('No PIN'), findsOneWidget);
      expect(find.text('Mom'), findsNothing);
    });

    testWidgets('setting a PIN patches the child profile', (tester) async {
      await pumpPins(tester);

      await tester.tap(find.byKey(const Key('pin-action-13')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('pin-field')), '1357');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(patchedPath, '/families/2/children/13/pin');
      expect(patchedBody, {'child_pin': '1357'});
    });

    testWidgets('removing a PIN clears it', (tester) async {
      await pumpPins(tester);

      await tester.tap(find.byKey(const Key('pin-action-12')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove PIN'));
      await tester.pumpAndSettle();

      expect(patchedPath, '/families/2/children/12/pin');
      expect(patchedBody, {'child_pin': null});
    });
  });

  group('Account settings', () {
    testWidgets('links to child PIN management', (tester) async {
      final mock = MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status);
        final path = request.url.path;
        if (request.method == 'POST' && path == '/auth/register') {
          return json({
            'access_token': 'tok',
            'token_type': 'bearer',
            'user': _parentUser(),
          }, 201);
        }
        if (request.method == 'GET' && path == '/families/me') {
          return json({
            'id': 2,
            'name': 'Fam',
            'invite_code': 'AB12CD',
            'created_at': '2026-01-01T00:00:00',
            'members': [
              {..._parentUser(), 'has_child_pin': false},
              {..._kidUser(), 'has_child_pin': false},
            ],
          });
        }
        return http.Response('not found', 404);
      });
      final session = await _parentSession(mock);
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: MaterialApp(
            home: AccountSettingsScreen(
              profile: UserProfile(
                name: 'Mom',
                birthday: DateTime(1990, 1, 1),
                role: FamilyRole.parent,
                mode: FamilyMode.parent,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Child PINs'));
      await tester.tap(find.text('Child PINs'));
      await tester.pumpAndSettle();

      expect(find.byType(ChildPinScreen), findsOneWidget);
    });
  });
}
