import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/customization/customization_screen.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/join_circle_screen.dart';
import 'package:homesync/views/onboarding/link_kids_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/onboarding/splash_screen.dart';
import 'package:homesync/views/settings/account_settings_screen.dart';

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

UserProfile _kid() => UserProfile(
      name: 'Ava',
      birthday: DateTime(2018, 4, 23),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

UserProfile _teen() => UserProfile(
      name: 'Noah',
      birthday: DateTime(2012, 5, 6),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
    );

Future<void> _pumpSettings(
  WidgetTester tester,
  UserProfile profile, {
  AuthSession? session,
}) async {
  final screen = AccountSettingsScreen(profile: profile);
  if (session == null) {
    await tester.pumpWidget(MaterialApp(home: screen));
  } else {
    await tester.pumpWidget(
      AuthScope(session: session, child: MaterialApp(home: screen)),
    );
  }
  await tester.pumpAndSettle();
}

MockClient _loginMock() {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    if (request.method == 'POST' && request.url.path == '/auth/login') {
      return json({'access_token': 'tok', 'token_type': 'bearer'});
    }
    if (request.method == 'GET' && request.url.path == '/auth/me') {
      return json({
        'id': 9,
        'family_id': 2,
        'email': 'mom@x.com',
        'display_name': 'Mom',
        'role': 'parent',
        'mode': null,
        'points_balance': 0,
        'created_at': '2026-01-01T00:00:00',
      });
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('Account Settings', () {
    testWidgets('shows account info and option rows', (tester) async {
      final profile = _parent();
      await _pumpSettings(tester, profile);

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Mom'), findsOneWidget);
      expect(
        find.text('Parent · Age ${profile.age()}'),
        findsOneWidget,
      );
      expect(find.text('Customization'), findsOneWidget);
      expect(find.text('Link your kids'), findsOneWidget);
      expect(find.text('Join a family circle'), findsOneWidget);
      // Logged out: no sign-out row, no placeholders.
      expect(find.text('Sign out'), findsNothing);
      expect(find.textContaining('coming soon'), findsNothing);
    });

    testWidgets('profile dropdown opens Account Settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FocusAreasScope(
            controller: FocusAreasController(FocusAreas.all),
            child: HomeScreen(profile: _parent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account settings'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountSettingsScreen), findsOneWidget);
      expect(find.text('Mom'), findsOneWidget);
    });

    testWidgets('rows open Customization and Link screens', (tester) async {
      await _pumpSettings(tester, _parent());

      await tester.tap(find.text('Customization'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomizationScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(CustomizationScreen))).pop();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Link your kids'));
      await tester.tap(find.text('Link your kids'));
      await tester.pumpAndSettle();
      expect(find.byType(LinkKidsScreen), findsOneWidget);
    });

    testWidgets('kid accounts reach the join flow', (tester) async {
      await _pumpSettings(tester, _kid());

      expect(find.text('Ava'), findsOneWidget);
      expect(find.text('Join a family circle'), findsOneWidget);
      await tester.tap(find.text('Join a family circle'));
      await tester.pumpAndSettle();
      expect(find.byType(JoinCircleScreen), findsOneWidget);
    });

    testWidgets('teen accounts reach the join flow', (tester) async {
      await _pumpSettings(tester, _teen());

      expect(find.text('Noah'), findsOneWidget);
      expect(find.text('Join a family circle'), findsOneWidget);
      await tester.tap(find.text('Join a family circle'));
      await tester.pumpAndSettle();
      expect(find.byType(JoinCircleScreen), findsOneWidget);
    });

    testWidgets('sign out returns to Splash when signed in', (tester) async {
      final session = AuthSession(
        client: ApiClient(inner: _loginMock()),
        tokenStore: InMemoryTokenStore(),
      );
      await session.login('mom@x.com', 'secret123');
      await _pumpSettings(tester, _parent(), session: session);

      expect(find.text('Sign out'), findsOneWidget);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(session.isAuthenticated, isFalse);
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('Join a family circle', () {
    Future<void> pumpJoin(WidgetTester tester) async {
      await _pumpSettings(tester, _kid());
      await tester.tap(find.text('Join a family circle'));
      await tester.pumpAndSettle();
    }

    testWidgets('rejects empty and malformed codes', (tester) async {
      await pumpJoin(tester);

      await tester.tap(find.text('Join'));
      await tester.pump();
      expect(
        find.text('Enter the 6-character invite code.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Join'));
      await tester.pump();
      expect(
        find.text('Enter the 6-character invite code.'),
        findsOneWidget,
      );
      expect(find.text('Circle joined!'), findsNothing);
    });

    testWidgets('accepts a valid code and finishes', (tester) async {
      await pumpJoin(tester);

      await tester.enterText(find.byType(TextField), 'h7k2m9');
      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();

      expect(find.text('Circle joined!'), findsOneWidget);
      expect(
        find.text("You're now linked with code H7K 2M9."),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(JoinCircleScreen), findsNothing);
      expect(find.byType(AccountSettingsScreen), findsOneWidget);
    });
  });
}
