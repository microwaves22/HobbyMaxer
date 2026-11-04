import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/models/chore_task.dart';
import 'package:homesync/views/tasks/tasks_api.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/tasks_screen.dart';

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

UserProfile _child() => UserProfile(
      name: 'Ava',
      birthday: DateTime(2018, 5, 2),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

ChoreTask _chore(String id, String title) => ChoreTask(
      id: id,
      title: title,
      details: 'details',
      childName: 'Ava',
      points: 5,
    );

ChoreTask _homework(String id, String title) => ChoreTask(
      id: id,
      title: title,
      details: 'details',
      childName: 'Ava',
      points: 8,
      isHomework: true,
    );

Future<void> _pumpHub(
  WidgetTester tester, {
  required TasksController controller,
  UserProfile? profile,
  TasksSegment initialSegment = TasksSegment.chores,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TasksScreen(
        controller: controller,
        profile: profile ?? _child(),
        initialSegment: initialSegment,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Set<TasksSegment> _selected(WidgetTester tester) {
  final button = tester.widget<SegmentedButton<TasksSegment>>(
    find.byType(SegmentedButton<TasksSegment>),
  );
  return button.selected;
}

void main() {
  group('Tasks hub', () {
    testWidgets('segments divide chores from homework', (tester) async {
      await _pumpHub(
        tester,
        controller: TasksController.test(tasks: [
          _chore('c1', 'Mop the floor'),
          _homework('h1', 'Science report'),
        ]),
      );

      expect(find.text('Chores'), findsOneWidget);
      expect(find.text('Homework'), findsOneWidget);
      expect(_selected(tester), {TasksSegment.chores});
      expect(find.text('Mop the floor'), findsOneWidget);
      expect(find.text('Science report'), findsNothing);

      await tester.tap(find.text('Homework'));
      await tester.pumpAndSettle();

      expect(_selected(tester), {TasksSegment.homework});
      expect(find.text('Science report'), findsOneWidget);
      expect(find.text('Mop the floor'), findsNothing);
    });

    testWidgets('empty states are per segment', (tester) async {
      await _pumpHub(
        tester,
        controller: TasksController.test(tasks: [
          _homework('h1', 'Science report'),
        ]),
      );

      expect(find.text('No chores yet.'), findsOneWidget);

      await tester.tap(find.text('Homework'));
      await tester.pumpAndSettle();
      expect(find.text('Science report'), findsOneWidget);
      expect(find.text('No chores yet.'), findsNothing);
    });

    testWidgets('homework-only gap shows the homework empty state',
        (tester) async {
      await _pumpHub(
        tester,
        controller: TasksController.test(tasks: [
          _chore('c1', 'Mop the floor'),
        ]),
      );

      await tester.tap(find.text('Homework'));
      await tester.pumpAndSettle();

      expect(find.text('No homework yet.'), findsOneWidget);
      expect(find.text('Mop the floor'), findsNothing);
    });

    testWidgets('initialSegment preselects homework', (tester) async {
      await _pumpHub(
        tester,
        controller: TasksController.test(tasks: [
          _chore('c1', 'Mop the floor'),
          _homework('h1', 'Science report'),
        ]),
        initialSegment: TasksSegment.homework,
      );

      expect(_selected(tester), {TasksSegment.homework});
      expect(find.text('Science report'), findsOneWidget);
      expect(find.text('Mop the floor'), findsNothing);
    });

    testWidgets('dashboard cards open the hub on their side', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FocusAreasScope(
            controller: FocusAreasController(FocusAreas.all),
            child: HomeScreen(profile: _parent()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final homeworkCard = find.text('Homework tracking');
      await tester.ensureVisible(homeworkCard);
      await tester.tap(homeworkCard);
      await tester.pumpAndSettle();

      expect(find.byType(TasksScreen), findsOneWidget);
      expect(_selected(tester), {TasksSegment.homework});
      expect(find.text('Read 20 minutes'), findsOneWidget);
      expect(find.text('Take out the trash'), findsNothing);

      Navigator.of(tester.element(find.byType(TasksScreen))).pop();
      await tester.pumpAndSettle();

      final choresCard = find.text('Chore distribution');
      await tester.ensureVisible(choresCard);
      await tester.tap(choresCard);
      await tester.pumpAndSettle();

      expect(_selected(tester), {TasksSegment.chores});
      expect(find.text('Take out the trash'), findsOneWidget);
      expect(find.text('Read 20 minutes'), findsNothing);
    });
  });

  group('Homework classification', () {
    test('task_type homework maps to the Homework segment', () async {
      Map<String, dynamic> task(int id, String type) => {
            'id': id,
            'family_id': 2,
            'title': 'Task $id',
            'description': 'Details $id',
            'task_type': type,
            'points_reward': 10,
            'requires_photo': false,
            'assigned_to_user_id': 10,
            'status': 'open',
            'due_date': null,
            'created_at': '2026-01-01T00:00:00',
          };
      final api = TasksApi(ApiClient(
        inner: MockClient((request) async {
          http.Response json(Object body, [int status = 200]) =>
              http.Response(jsonEncode(body), status);
          final path = request.url.path;
          if (request.method == 'GET' && path == '/tasks/') {
            return json([task(1, 'homework'), task(2, 'chore')]);
          }
          if (request.method == 'GET' && path == '/families/me') {
            return json({
              'id': 2,
              'name': 'Fam',
              'created_at': '2026-01-01T00:00:00',
              'members': [
                {
                  'id': 10,
                  'display_name': 'Ava',
                  'role': 'child',
                  'mode': 'kids',
                  'points_balance': 30,
                  'created_at': '2026-01-01T00:00:00',
                },
              ],
            });
          }
          if (path.endsWith('/submissions')) return json([]);
          return http.Response('not found', 404);
        }),
      ));

      final snapshot = await api.fetchSnapshot();

      expect(
        snapshot.tasks.firstWhere((t) => t.id == 'srv-1').isHomework,
        isTrue,
      );
      expect(
        snapshot.tasks.firstWhere((t) => t.id == 'srv-2').isHomework,
        isFalse,
      );
    });
  });
}
