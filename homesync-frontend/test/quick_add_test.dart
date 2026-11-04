import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/ai_api.dart';
import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/ai/quick_add_screen.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

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

Map<String, dynamic> _drafts() => {
      'events': [
        {
          'title': 'Soccer',
          'starts_at': '2026-11-06T17:00:00+00:00',
          'ends_at': '2026-11-06T18:00:00+00:00',
          'attendee_names': ['Noah'],
        },
      ],
      'tasks': [
        {
          'title': 'Empty the dishwasher',
          'description': null,
          'task_type': 'chore',
          'points_reward': 10,
          'requires_photo': false,
          'assigned_to_user_id': 12,
          'assigned_to_name': 'Ava',
          'due_date': null,
          'repeat_rule': 'daily',
        },
      ],
      'warnings': [],
    };

MockClient _screenMock({
  required List<String> calls,
  bool empty = false,
}) {
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
    if (request.method == 'POST' && path == '/ai/quick-add') {
      calls.add('POST /ai/quick-add');
      if (empty) {
        return json({
          'events': [],
          'tasks': [],
          'warnings': ['No names, days, or times found.'],
        });
      }
      return json(_drafts());
    }
    if (request.method == 'POST' && path == '/calendar/events') {
      calls.add('POST /calendar/events');
      return json({'id': 3}, 201);
    }
    if (request.method == 'POST' && path == '/tasks/') {
      calls.add('POST /tasks/');
      return json({'id': 7}, 201);
    }
    return http.Response('not found', 404);
  });
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

Future<void> _pumpScreen(
  WidgetTester tester,
  AuthSession session,
  List<String> calls, {
  bool empty = false,
}) async {
  await tester.pumpWidget(
    AuthScope(
      session: session,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuickAddScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Noah has soccer Thursday');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Parse'));
  await tester.pumpAndSettle();
}

void main() {
  group('AiApi', () {
    test('quickAdd posts text and parses drafts', () async {
      String? posted;
      final api = AiApi(ApiClient(
        inner: MockClient((request) async {
          posted = request.body;
          return http.Response(jsonEncode(_drafts()), 200);
        }),
      ));

      final drafts = await api.quickAdd('Do the thing');

      expect(jsonDecode(posted!)['text'], 'Do the thing');
      expect((drafts['events'] as List).length, 1);
      expect((drafts['tasks'] as List).length, 1);
    });
  });

  group('QuickAddScreen', () {
    testWidgets('parse, review, and confirm save the drafts',
        (tester) async {
      final calls = <String>[];
      final session = await _parentSession(_screenMock(calls: calls));
      await _pumpScreen(tester, session, calls);

      expect(find.text('Soccer'), findsOneWidget);
      expect(find.text('Empty the dishwasher'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(calls, contains('POST /calendar/events'));
      expect(calls, contains('POST /tasks/'));
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('deselected drafts are not created', (tester) async {
      final calls = <String>[];
      final session = await _parentSession(_screenMock(calls: calls));
      await _pumpScreen(tester, session, calls);

      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(calls, isNot(contains('POST /calendar/events')));
      expect(calls, contains('POST /tasks/'));
    });

    testWidgets('empty drafts show a rephrase hint, no confirm',
        (tester) async {
      final calls = <String>[];
      final session =
          await _parentSession(_screenMock(calls: calls, empty: true));
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: const MaterialApp(home: QuickAddScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'asdf qwer');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Parse'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Couldn't understand that — try rephrasing with names, days, and times.",
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'Confirm'), findsNothing);
    });
  });

  group('Dashboard entry', () {
    testWidgets('parents get a quick-add button', (tester) async {
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
            'members': [_parentUser()],
          });
        }
        if (request.method == 'GET' && path == '/tasks/') return json([]);
        return http.Response('not found', 404);
      });
      final session = await _parentSession(mock);
      await tester.pumpWidget(
        AuthScope(
          session: session,
          child: MaterialApp(
            home: FocusAreasScope(
              controller: FocusAreasController(FocusAreas.all),
              child: HomeScreen(
                profile: UserProfile(
                  name: 'Mom',
                  birthday: DateTime(1990, 1, 1),
                  role: FamilyRole.parent,
                  mode: FamilyMode.parent,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quick-add-button')));
      await tester.pumpAndSettle();

      expect(find.byType(QuickAddScreen), findsOneWidget);
    });
  });
}
