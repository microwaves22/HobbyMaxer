import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/notifications_api.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/notifications/notifications_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/settings/account_settings_screen.dart';
import 'package:homesync/views/settings/notification_settings_screen.dart';

Map<String, dynamic> _note({
  required int id,
  required String type,
  required String title,
  bool isRead = false,
}) {
  return {
    'id': id,
    'type': type,
    'title': title,
    'body': null,
    'ref_type': 'task',
    'ref_id': 7,
    'is_read': isRead,
    'created_at': '2026-01-01T00:00:00',
  };
}

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

Future<AuthSession> _loggedInSession(MockClient mock) async {
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

MockClient _homeMock() {
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
        'members': [_parentUser()],
      });
    }
    if (request.method == 'GET' && path == '/tasks/') return json([]);
    if (request.method == 'GET' && path == '/notifications') {
      return json([
        _note(id: 1, type: 'review_needed', title: 'Maya submitted Trash'),
        _note(id: 2, type: 'approved', title: 'Dad approved Dishes'),
      ]);
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('NotificationsApi', () {
    test('fetch unread, mark read, and preferences round-trip', () async {
      final calls = <String>[];
      Map<String, dynamic>? putBody;
      final api = NotificationsApi(ApiClient(
        inner: MockClient((request) async {
          http.Response json(Object body, [int status = 200]) =>
              http.Response(jsonEncode(body), status);
          final path = request.url.path;
          calls.add('${request.method} $path?${request.url.query}');
          if (request.method == 'GET' && path == '/notifications') {
            return json([_note(id: 1, type: 'approved', title: 'Hi')]);
          }
          if (request.method == 'PUT' && path == '/notifications/1/read') {
            return json(_note(id: 1, type: 'approved', title: 'Hi', isRead: true));
          }
          if (request.method == 'POST' && path == '/notifications/read-all') {
            return json({'marked_read': 2});
          }
          if (request.method == 'GET' &&
              path == '/families/me/preferences') {
            return json({
              'review_needed': true,
              'approved': true,
              'member_joined': true,
            });
          }
          if (request.method == 'PUT' &&
              path == '/families/me/preferences') {
            putBody = jsonDecode(request.body) as Map<String, dynamic>;
            return json({
              'review_needed': true,
              'approved': false,
              'member_joined': true,
            });
          }
          return http.Response('not found', 404);
        }),
      ));

      final unread = await api.fetchNotifications(unreadOnly: true);
      expect(unread.length, 1);
      expect(calls.first, contains('unread_only=true'));

      final read = await api.markRead(1);
      expect(read['is_read'], isTrue);
      expect(await api.markAllRead(), 2);

      final prefs = await api.fetchPreferences();
      expect(prefs['approved'], isTrue);
      await api.updatePreferences({
        'review_needed': true,
        'approved': false,
        'member_joined': true,
      });
      expect(putBody?['approved'], isFalse);
    });
  });

  group('Notification bell', () {
    Future<void> pumpHome(WidgetTester tester, UserProfile profile) async {
      final session = await _loggedInSession(_homeMock());
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: MaterialApp(
            home: FocusAreasScope(
              controller: FocusAreasController(FocusAreas.all),
              child: HomeScreen(profile: profile),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('parent dashboard shows the unread badge', (tester) async {
      await pumpHome(tester, _parent());

      expect(find.byKey(const Key('notifications-bell')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('bell opens the notifications screen', (tester) async {
      await pumpHome(tester, _parent());

      await tester.tap(find.byKey(const Key('notifications-bell')));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('Maya submitted Trash'), findsOneWidget);
    });

    testWidgets('kid dashboard shows no bell', (tester) async {
      await pumpHome(tester, _kid());

      expect(find.byKey(const Key('notifications-bell')), findsNothing);
    });
  });

  group('NotificationsScreen', () {
    testWidgets('mark all read clears the unread dots', (tester) async {
      final calls = <String>[];
      final mock = MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status);
        final path = request.url.path;
        calls.add('${request.method} $path');
        if (request.method == 'POST' && path == '/auth/register') {
          return json({
            'access_token': 'tok',
            'token_type': 'bearer',
            'user': _parentUser(),
          }, 201);
        }
        if (request.method == 'GET' && path == '/notifications') {
          return json([
            _note(id: 1, type: 'approved', title: 'Dad approved Dishes'),
            _note(
                id: 2,
                type: 'member_joined',
                title: 'Dad joined the family',
                isRead: true),
          ]);
        }
        if (request.method == 'POST' && path == '/notifications/read-all') {
          return json({'marked_read': 1});
        }
        return http.Response('not found', 404);
      });
      final session = await _loggedInSession(mock);
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dad approved Dishes'), findsOneWidget);
      expect(find.byKey(const Key('unread-dot')), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(calls, contains('POST /notifications/read-all'));
      expect(find.byKey(const Key('unread-dot')), findsNothing);
    });
  });

  group('Notification preferences', () {
    testWidgets('toggles save a merged preference map', (tester) async {
      Map<String, dynamic>? putBody;
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
        if (request.method == 'GET' && path == '/families/me/preferences') {
          return json({
            'review_needed': true,
            'approved': true,
            'member_joined': true,
          });
        }
        if (request.method == 'PUT' && path == '/families/me/preferences') {
          putBody = jsonDecode(request.body) as Map<String, dynamic>;
          return json(putBody!);
        }
        return http.Response('not found', 404);
      });
      final session = await _loggedInSession(mock);
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: NotificationSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pref-approved')));
      await tester.pumpAndSettle();

      expect(putBody, {
        'review_needed': true,
        'approved': false,
        'member_joined': true,
      });
    });

    testWidgets('account settings links to notification preferences',
        (tester) async {
      final session = await _loggedInSession(_homeMock());
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: MaterialApp(home: AccountSettingsScreen(profile: _parent())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });
  });
}
