import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/network/auth_session.dart';
import 'package:homesync/core/network/token_store.dart';
import 'package:homesync/views/home/widgets/load_balance_section.dart';

Map<String, dynamic> _share({
  required int userId,
  required String name,
  required int tasks,
  required int approvals,
  required int events,
  required int score,
  required int percent,
}) {
  return {
    'user_id': userId,
    'display_name': name,
    'tasks_created': tasks,
    'approvals': approvals,
    'events_added': events,
    'score': score,
    'percent': percent,
  };
}

MockClient _mock({bool empty = false}) {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
    if (request.method == 'POST' && path == '/auth/register') {
      return json({
        'access_token': 'tok',
        'token_type': 'bearer',
        'user': {
          'id': 9,
          'family_id': 2,
          'email': 'm@example.com',
          'display_name': 'Mom',
          'role': 'parent',
          'mode': null,
          'points_balance': 0,
          'created_at': '2026-01-01T00:00:00',
        },
      }, 201);
    }
    if (request.method == 'GET' && path == '/families/load-balance') {
      if (empty) {
        return json({
          'window_days': 7,
          'total': 0,
          'shares': [
            _share(
                userId: 9,
                name: 'Mom',
                tasks: 0,
                approvals: 0,
                events: 0,
                score: 0,
                percent: 0),
          ],
        });
      }
      return json({
        'window_days': 7,
        'total': 25,
        'shares': [
          _share(
              userId: 9,
              name: 'Mom',
              tasks: 6,
              approvals: 8,
              events: 4,
              score: 18,
              percent: 72),
          _share(
              userId: 10,
              name: 'Dad',
              tasks: 2,
              approvals: 3,
              events: 2,
              score: 7,
              percent: 28),
        ],
      });
    }
    return http.Response('not found', 404);
  });
}

Future<void> _pumpWithSession(WidgetTester tester, MockClient mock) async {
  final session = AuthSession(
    client: ApiClient(inner: mock),
    tokenStore: InMemoryTokenStore(),
  );
  await session.register(
    email: 'm@example.com',
    password: 'secret12',
    displayName: 'Mom',
  );
  await tester.pumpWidget(
    AuthScope(
      session: session,
      child: const MaterialApp(home: Scaffold(body: LoadBalanceSection())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoadBalanceSection', () {
    testWidgets('renders the split, bar, and per-parent counts',
        (tester) async {
      await _pumpWithSession(tester, _mock());

      expect(find.text('Load Balance'), findsOneWidget);
      expect(find.text('Mom 72% / Dad 28%'), findsOneWidget);
      expect(find.byKey(const Key('load-balance-bar')), findsOneWidget);
      expect(
        find.text('Mom · 6 tasks · 8 approvals · 4 events'),
        findsOneWidget,
      );
      expect(
        find.text('Dad · 2 tasks · 3 approvals · 2 events'),
        findsOneWidget,
      );
    });

    testWidgets('shows the quiet-week state when nothing was logged',
        (tester) async {
      await _pumpWithSession(tester, _mock(empty: true));

      expect(find.text('No activity in the last 7 days.'), findsOneWidget);
      expect(find.byKey(const Key('load-balance-bar')), findsNothing);
    });
  });
}
