import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/family_member.dart';
import 'package:homesync/views/onboarding/link_kids_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

FamilySetupMember _member(String name, String role) => FamilySetupMember(
      id: name,
      name: name,
      age: '9',
      gender: 'Female',
      role: role,
      avatarColor: Colors.pink,
      glyph: 'K',
    );

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

/// First `/families/me` reports no family (404); later calls return it.
MockClient _mock({required List<String> calls}) {
  var familyCalls = 0;
  return MockClient((request) async {
    final path = request.url.path;
    calls.add('${request.method} $path');
    if (request.method == 'POST' && path == '/auth/register') {
      return _json({
        'access_token': 'tok',
        'token_type': 'bearer',
        'user': {
          'id': 9,
          'family_id': null,
          'email': 'm@example.com',
          'display_name': 'Mom',
          'role': 'parent',
          'mode': null,
          'points_balance': 0,
          'created_at': '2026-01-01T00:00:00',
        },
      }, 201);
    }
    if (request.method == 'GET' && path == '/families/me') {
      familyCalls++;
      if (familyCalls == 1) {
        return _json({'detail': 'No family yet.'}, 404);
      }
      return _json({
        'id': 2,
        'name': 'The Mom Family',
        'invite_code': 'AB12CD',
        'created_at': '2026-01-01T00:00:00',
        'members': [],
      });
    }
    if (request.method == 'POST' && path == '/families/') {
      return _json({
        'id': 2,
        'name': 'The Mom Family',
        'invite_code': 'AB12CD',
        'created_at': '2026-01-01T00:00:00',
      }, 201);
    }
    if (request.method == 'POST' && path == '/families/2/children') {
      return _json({'id': 12}, 201);
    }
    if (request.method == 'GET' && path == '/tasks/') {
      return _json([]);
    }
    return http.Response('not found', 404);
  });
}

Future<AuthSession> _registeredSession(List<String> calls) async {
  final session = AuthSession(
    client: ApiClient(inner: _mock(calls: calls)),
    tokenStore: InMemoryTokenStore(),
  );
  // Seed an authenticated parent without hitting the login form.
  await session.register(
    email: 'm@example.com',
    password: 'secret12',
    displayName: 'Mom',
  );
  return session;
}

Future<void> _pumpHome(
  WidgetTester tester,
  AuthSession session,
  List<FamilySetupMember> pendingMembers,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AuthScope(
        session: session,
        child: FocusAreasScope(
          controller: FocusAreasController(FocusAreas.all),
          child: HomeScreen(
            profile: _parent(),
            pendingMembers: pendingMembers,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('First-run family bootstrap', () {
    testWidgets('parent without a family creates it and adds kids',
        (tester) async {
      final calls = <String>[];
      final session = await _registeredSession(calls);

      await _pumpHome(tester, session, [
        _member('Maya', 'Kids'),
        _member('Leo', 'Teen'),
        _member('Mom', 'Parent'),
      ]);

      expect(find.text('Hello, Mom!'), findsOneWidget);
      expect(calls, contains('POST /families/'));
      // Both kids are added; the parent-role member is skipped.
      expect(
        calls.where((c) => c == 'POST /families/2/children').length,
        2,
      );
      // No error surfaces for the happy path.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('second parent in setup surfaces the invite code',
        (tester) async {
      final calls = <String>[];
      final session = await _registeredSession(calls);

      await _pumpHome(tester, session, [
        _member('Dad', 'Parent'),
      ]);

      // The creator's own entry stays silent, but a second parent is
      // never dropped: the invite code is shown so they can join.
      expect(find.textContaining('AB1 2CD'), findsOneWidget);
      expect(find.textContaining('Dad'), findsOneWidget);
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(find.byType(LinkKidsScreen), findsOneWidget);
    });
  });
}
