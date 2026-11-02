import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/tasks/models/chore_task.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';

ChoreTask _task({
  String id = 't1',
  String child = 'Maya',
  int points = 10,
  bool requiresPhoto = false,
  TaskState state = TaskState.pending,
  String? photoPath,
}) {
  return ChoreTask(
    id: id,
    title: 'Title $id',
    details: 'Details $id',
    childName: child,
    points: points,
    requiresPhoto: requiresPhoto,
    state: state,
    photoPath: photoPath,
  );
}

UserProfile _profile({String name = 'Maya', bool parent = false}) {
  return UserProfile(
    name: name,
    birthday: DateTime(2016, 4, 23),
    role: parent ? FamilyRole.parent : FamilyRole.child,
    mode: parent ? FamilyMode.parent : FamilyMode.kids,
  );
}

void main() {
  group('TasksController', () {
    test('submitPhoto moves a task to Pending Review with the photo',
        () async {
      final controller = TasksController.test(
        tasks: [_task(requiresPhoto: true)],
      );

      await controller.submitPhoto('t1', '/tmp/photo.jpg');

      final task = controller.byId('t1')!;
      expect(task.state, TaskState.pendingReview);
      expect(task.photoPath, '/tmp/photo.jpg');
    });

    test('approve awards points and marks the task approved', () async {
      final controller = TasksController.test(
        tasks: [_task(state: TaskState.pendingReview)],
        balances: {'Maya': 30},
      );

      await controller.approve('t1');

      expect(controller.byId('t1')!.state, TaskState.approved);
      expect(controller.balanceFor('Maya'), 40);
    });

    test('approve ignores tasks that are not pending review', () async {
      final controller = TasksController.test(
        tasks: [_task(state: TaskState.pending)],
        balances: {'Maya': 30},
      );

      await controller.approve('t1');

      expect(controller.byId('t1')!.state, TaskState.pending);
      expect(controller.balanceFor('Maya'), 30);
    });

    test('requestChanges sends the task back', () async {
      final controller = TasksController.test(
        tasks: [_task(state: TaskState.pendingReview)],
      );

      await controller.requestChanges('t1');

      expect(controller.byId('t1')!.state, TaskState.changesRequested);
    });

    test('approveAllSimple approves only no-photo tasks', () async {
      final controller = TasksController.test(
        tasks: [
          _task(id: 'simple', state: TaskState.pendingReview),
          _task(
            id: 'photo',
            requiresPhoto: true,
            state: TaskState.pendingReview,
          ),
          _task(id: 'todo', state: TaskState.pending),
        ],
        balances: {'Maya': 0},
      );

      final approved = await controller.approveAllSimple();

      expect(approved, 1);
      expect(controller.byId('simple')!.state, TaskState.approved);
      expect(controller.byId('photo')!.state, TaskState.pendingReview);
      expect(controller.byId('todo')!.state, TaskState.pending);
      expect(controller.balanceFor('Maya'), 10);
    });

    test('balanceFor defaults to zero for unknown children', () {
      final controller = TasksController.test();
      expect(controller.balanceFor('Nobody'), 0);
    });

    test('forProfile seeds household tasks for a parent', () {
      final controller = TasksController.forProfile(_profile(parent: true));

      expect(controller.tasks.length, 4);
      expect(controller.pendingReview.length, 2);
      expect(controller.balanceFor('Maya'), 120);
    });

    test('forProfile seeds personal tasks for a child', () {
      final controller = TasksController.forProfile(_profile(name: 'Alex'));

      expect(
        controller.tasks.every((t) => t.childName == 'Alex'),
        isTrue,
      );
      expect(controller.tasksFor('Alex').length, 3);
      expect(controller.balanceFor('Alex'), 30);
    });
  });
}
