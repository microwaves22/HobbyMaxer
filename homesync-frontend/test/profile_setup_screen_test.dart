import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/family_setup_screen.dart';
import 'package:homesync/views/onboarding/profile_setup_screen.dart';

Finder _fieldWithHint(String hint) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hint,
    );

Future<void> _pumpSignup(WidgetTester tester, {AuthSession? session}) async {
  final screen = const ProfileSetupScreen(focusAreas: ['a']);
  if (session == null) {
    await tester.pumpWidget(MaterialApp(home: screen));
  } else {
    await tester.pumpWidget(
      AuthScope(session: session, child: MaterialApp(home: screen)),
    );
  }
  await tester.pumpAndSettle();
}

Map<String, dynamic> _meJson(String name) => {
      'id': 9,
      'family_id': 2,
      'email': 'new@x.com',
      'display_name': name,
      'role': 'parent',
      'mode': null,
      'points_balance': 0,
      'created_at': '2026-01-01T00:00:00',
    };

MockClient _registerMock() {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
    if (request.method == 'POST' && path == '/auth/register') {
      return json({
        'access_token': 'tok',
        'token_type': 'bearer',
        'user': _meJson('New Mom'),
      }, 201);
    }
    if (path == '/tasks/') return json([]);
    if (path == '/families/me') {
      return json({
        'id': 2,
        'name': 'Fam',
        'created_at': '2026-01-01T00:00:00',
        'members': [_meJson('New Mom')],
      });
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('Create-an-account flow', () {
    testWidgets('shows email, password, name, birthday, role, and mode',
        (tester) async {
      await _pumpSignup(tester);

      expect(_fieldWithHint('Email address'), findsOneWidget);
      expect(_fieldWithHint('Password'), findsOneWidget);
      expect(_fieldWithHint('Confirm Password'), findsOneWidget);
      expect(_fieldWithHint('Enter name'), findsOneWidget);
      expect(_fieldWithHint('Birthday (YYYY-MM-DD)'), findsOneWidget);
      expect(find.text('Account type'), findsOneWidget);
      expect(find.text('Parent'), findsWidgets);
      expect(find.text('Kid'), findsOneWidget);
      expect(find.text('Kids'), findsOneWidget);
      expect(find.text('Teens'), findsOneWidget);
    });

    testWidgets('requires a valid email and a 6+ character password',
        (tester) async {
      await _pumpSignup(tester);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email.'), findsOneWidget);
      expect(
        find.text('Enter a password (6+ characters).'),
        findsOneWidget,
      );
      // Still on the signup form.
      expect(find.text('Tell us about yourself'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('completes signup locally without an auth session',
        (tester) async {
      await _pumpSignup(tester);

      await tester.enterText(
          _fieldWithHint('Email address'), 'mom@x.com');
      await tester.enterText(_fieldWithHint('Password'), 'secret123');
      await tester.enterText(
          _fieldWithHint('Confirm Password'), 'secret123');
      await tester.enterText(_fieldWithHint('Enter name'), 'Mom');
      await tester.enterText(
          _fieldWithHint('Birthday (YYYY-MM-DD)'), '1990-01-01');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Mom!'), findsOneWidget);
    });

    testWidgets('registers through the backend when a session exists',
        (tester) async {
      final session = AuthSession(
        client: ApiClient(inner: _registerMock()),
        tokenStore: InMemoryTokenStore(),
      );
      await _pumpSignup(tester, session: session);

      await tester.enterText(
          _fieldWithHint('Email address'), 'new@x.com');
      await tester.enterText(_fieldWithHint('Password'), 'secret123');
      await tester.enterText(
          _fieldWithHint('Confirm Password'), 'secret123');
      await tester.enterText(_fieldWithHint('Enter name'), 'New Mom');
      await tester.enterText(
          _fieldWithHint('Birthday (YYYY-MM-DD)'), '1990-01-01');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(session.isAuthenticated, isTrue);
      expect(find.text('Hello, New!'), findsOneWidget);
    });
  });

  group('Member age input', () {
    testWidgets('age field strips letters and decimals', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FamilySetupScreen()));
      await tester.pumpAndSettle();

      final ageField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == null &&
            (w.controller?.text ?? '') == '',
      );
      expect(ageField, findsOneWidget);
      expect(
        tester.widget<TextField>(ageField).keyboardType,
        TextInputType.number,
      );

      final controller = tester.widget<TextField>(ageField).controller!;
      await tester.enterText(ageField, '12a.5b');
      await tester.pump();

      expect(controller.text, '125');
    });
  });
}
