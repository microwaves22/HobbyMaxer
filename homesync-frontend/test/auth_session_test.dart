import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

Map<String, dynamic> _meJson() => {
      'id': 1,
      'family_id': 2,
      'email': 'mom@x.com',
      'display_name': 'Mom',
      'role': 'parent',
      'mode': null,
      'points_balance': 120,
      'created_at': '2026-01-01T00:00:00',
    };

AuthSession _session(MockClient mock, InMemoryTokenStore store) {
  return AuthSession(
    client: ApiClient(inner: mock),
    tokenStore: store,
  );
}

void main() {
  group('AuthSession', () {
    test('login stores the token, profile, and persists the JWT', () async {
      String? loginBody;
      String? meAuth;
      final mock = MockClient((request) async {
        if (request.url.path == '/auth/login') {
          loginBody = request.body;
          return http.Response(
            jsonEncode({'access_token': 'tok', 'token_type': 'bearer'}),
            200,
          );
        }
        if (request.url.path == '/auth/me') {
          meAuth = request.headers['Authorization'];
          return http.Response(jsonEncode(_meJson()), 200);
        }
        return http.Response('not found', 404);
      });
      final store = InMemoryTokenStore();
      final session = _session(mock, store);

      await session.login('mom@x.com', 'pw');

      expect(loginBody, contains('username='));
      expect(meAuth, 'Bearer tok');
      expect(session.isAuthenticated, isTrue);
      expect(session.token, 'tok');
      expect(session.user!.displayName, 'Mom');
      expect(session.user!.pointsBalance, 120);
      expect(await store.readToken(), 'tok');
      final profile = session.toProfile();
      expect(profile.name, 'Mom');
      expect(profile.role, FamilyRole.parent);
      expect(profile.mode, FamilyMode.parent);
      expect(profile.birthday, isNull);
      expect(profile.age(), isNull);
    });

    test('login failure leaves the session logged out', () async {
      final mock = MockClient(
        (_) async => http.Response(
          jsonEncode({'detail': 'Incorrect email or password.'}),
          401,
        ),
      );
      final store = InMemoryTokenStore();
      final session = _session(mock, store);

      await expectLater(
        () => session.login('mom@x.com', 'wrong'),
        throwsA(isA<ApiException>()),
      );
      expect(session.isAuthenticated, isFalse);
      expect(await store.readToken(), isNull);
    });

    test('register authenticates from the response', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, '/auth/register');
        return http.Response(
          jsonEncode({
            'access_token': 'tok',
            'token_type': 'bearer',
            'user': _meJson(),
          }),
          201,
        );
      });
      final store = InMemoryTokenStore();
      final session = _session(mock, store);

      await session.register(
        email: 'mom@x.com',
        password: 'secret123',
        displayName: 'Mom',
      );

      expect(session.isAuthenticated, isTrue);
      expect(session.user!.displayName, 'Mom');
      expect(await store.readToken(), 'tok');
    });

    test('restore revalidates a saved token', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, '/auth/me');
        expect(request.headers['Authorization'], 'Bearer saved');
        return http.Response(jsonEncode(_meJson()), 200);
      });
      final store = InMemoryTokenStore();
      await store.writeToken('saved');
      final session = _session(mock, store);

      await session.restore();

      expect(session.isAuthenticated, isTrue);
      expect(session.user!.displayName, 'Mom');
    });

    test('restore discards a dead token', () async {
      final mock = MockClient(
        (_) async => http.Response(jsonEncode({'detail': 'Expired.'}), 401),
      );
      final store = InMemoryTokenStore();
      await store.writeToken('stale');
      final session = _session(mock, store);

      await session.restore();

      expect(session.isAuthenticated, isFalse);
      expect(session.token, isNull);
      expect(await store.readToken(), isNull);
    });

    test('logout clears everything', () async {
      final mock = MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({'access_token': 'tok', 'token_type': 'bearer'}),
            200,
          );
        }
        return http.Response(jsonEncode(_meJson()), 200);
      });
      final store = InMemoryTokenStore();
      final session = _session(mock, store);
      await session.login('mom@x.com', 'pw');

      await session.logout();

      expect(session.isAuthenticated, isFalse);
      expect(await store.readToken(), isNull);
    });
  });
}
