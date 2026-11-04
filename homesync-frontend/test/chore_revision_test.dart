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

ChoreTask _task({
  String id = 't1',
  String child = 'Maya',
  int points = 10,
  TaskState state = TaskState.pending,
  String? feedback,
  bool isParentTodo = false,
}) {
  return ChoreTask(
    id: id,
    title: 'Title $id',
    details: 'Details $id',
    childName: child,
    points: points,
    state: state,
    feedback: feedback,
    isParentTodo: isParentTodo,
  );
}

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

UserProfile _child() => UserProfile(
      name: 'Maya',
      birthday: DateTime(2016, 4, 23),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

Future<void> _pumpParentHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(profile: _parent()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// TextField inside the revision dialogs, found by its label.
Finder _dialogField(String label) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == label,
    );

void main() {
  group('Chore revision controller', () {
    test('requestChanges attaches feedback and returns the task', () async {
      final controller = TasksController.test(
        tasks: [_task(state: TaskState.pendingReview)],
      );

      await controller.requestChanges('t1', note: '  Fold the sleeves too. ');

      final task = controller.byId('t1')!;
      expect(task.state, TaskState.changesRequested);
      expect(task.feedback, 'Fold the sleeves too.');
      expect(controller.needsRevision.map((t) => t.id), ['t1']);
      expect(controller.pendingReview, isEmpty);
    });

    test('requestChanges without a note leaves feedback empty', () async {
      final controller = TasksController.test(
        tasks: [_task(state: TaskState.pendingReview)],
      );

      await controller.requestChanges('t1', note: '   ');

      final task = controller.byId('t1')!;
      expect(task.state, TaskState.changesRequested);
      expect(task.feedback, isNull);
    });

    test('updateChore edits points, details, and photo requirement', () {
      final controller = TasksController.test(tasks: [_task()]);

      final updated = controller.updateChore(
        't1',
        points: 25,
        details: 'New details',
        requiresPhoto: true,
      );

      expect(updated, isTrue);
      final task = controller.byId('t1')!;
      expect(task.points, 25);
      expect(task.details, 'New details');
      expect(task.requiresPhoto, isTrue);
    });

    test('updateChore rejects negative points, todos, and unknown ids', () {
      final controller = TasksController.test(
        tasks: [_task(), _task(id: 'pt1', isParentTodo: true)],
      );

      expect(controller.updateChore('t1', points: -5), isFalse);
      expect(controller.byId('t1')!.points, 10);
      expect(controller.updateChore('pt1', points: 5), isFalse);
      expect(controller.updateChore('missing', points: 5), isFalse);
      expect(controller.updateChore('t1'), isFalse);
    });

    test('fetchSnapshot maps the parent note to feedback', () async {
      final mock = MockClient((request) async {
        http.Response json(Object body, [int status = 200]) =>
            http.Response(jsonEncode(body), status);
        final path = request.url.path;
        if (request.method == 'GET' && path == '/tasks/') {
          return json([
            {
              'id': 8,
              'family_id': 2,
              'title': 'Task 8',
              'description': 'Details 8',
              'task_type': 'chore',
              'points_reward': 5,
              'requires_photo': false,
              'assigned_to_user_id': 11,
              'status': 'open',
              'due_date': null,
              'created_at': '2026-01-01T00:00:00',
            },
          ]);
        }
        if (request.method == 'GET' && path == '/tasks/8/submissions') {
          return json([
            {
              'id': 2,
              'task_id': 8,
              'submitted_by_user_id': 11,
              'status': 'changes_requested',
              'photo_path': null,
              'note': 'Try again, please.',
              'expires_at': null,
              'reviewed_at': '2026-01-02T00:00:00',
              'created_at': '2026-01-01T00:00:00',
            },
          ]);
        }
        if (request.method == 'GET' && path == '/families/me') {
          return json({
            'id': 2,
            'name': 'Fam',
            'created_at': '2026-01-01T00:00:00',
            'members': [
              {
                'id': 11,
                'family_id': 2,
                'email': null,
                'display_name': 'Leo',
                'role': 'child',
                'mode': 'kids',
                'points_balance': 45,
                'created_at': '2026-01-01T00:00:00',
              },
            ],
          });
        }
        return http.Response('not found', 404);
      });

      final snapshot = await TasksApi(ApiClient(inner: mock)).fetchSnapshot();

      expect(snapshot.tasks.single.feedback, 'Try again, please.');
      expect(snapshot.tasks.single.state, TaskState.changesRequested);
    });
  });

  group('Chore revision widgets', () {
    testWidgets('points chip opens the edit dialog and saves', (tester) async {
      await _pumpParentHome(tester);

      final chip = find.widgetWithText(Chip, '10 pts');
      expect(chip, findsOneWidget);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.text('Edit chore'), findsOneWidget);
      await tester.enterText(_dialogField('Points'), '25');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Chip, '25 pts'), findsOneWidget);
      expect(find.text('Chore updated.'), findsOneWidget);
    });

    testWidgets('Request Changes opens the feedback popup', (tester) async {
      await _pumpParentHome(tester);

      await tester.ensureVisible(find.text('Request Changes').first);
      await tester.tap(find.text('Request Changes').first);
      await tester.pumpAndSettle();

      // The popup opens instead of the card vanishing.
      expect(find.text('Request changes'), findsOneWidget);
      expect(find.text('Review queue (2)'), findsOneWidget);

      // Feedback is required.
      await tester.tap(find.text('Send feedback'));
      await tester.pump();
      expect(find.text('Tell them what to change.'), findsOneWidget);
      expect(find.text('Request changes'), findsOneWidget);

      await tester.enterText(
        _dialogField('Feedback'),
        'Fold the sleeves too.',
      );
      await tester.enterText(_dialogField('Points'), '15');
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Feedback sent to Maya.'), findsOneWidget);
      expect(find.text('Review queue (1)'), findsOneWidget);
      expect(find.text('Needs revision (1)'), findsOneWidget);
      expect(
        find.textContaining('Fold the sleeves too.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(Chip, '15 pts'), findsOneWidget);
    });

    testWidgets('child sees feedback and retries with resubmit', (tester) async {
      final controller = TasksController.test(
        tasks: [
          _task(
            id: 'c9',
            state: TaskState.changesRequested,
            feedback: 'Tuck the corners.',
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TasksScreen(controller: controller, profile: _child()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Changes Requested'), findsOneWidget);
      expect(find.textContaining('Tuck the corners.'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(
        find.text('Parent feedback: Tuck the corners.'),
        findsOneWidget,
      );
      expect(find.text('Resubmit for review'), findsOneWidget);

      await tester.tap(find.text('Resubmit for review'));
      await tester.pumpAndSettle();

      expect(find.text('Submitted — pending review.'), findsOneWidget);
      expect(controller.byId('c9')!.state, TaskState.pendingReview);
    });
  });
}
