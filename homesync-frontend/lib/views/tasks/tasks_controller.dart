import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../onboarding/models/user_profile.dart';
import 'models/chore_task.dart';
import 'tasks_api.dart';

/// Task store with demo seeds and optional backend sync.
///
/// Without a backend it runs fully local (onboarding demo, widget
/// tests). Once [attachBackend] is called (authenticated sessions),
/// [refresh] pulls tasks + balances and submit/review hit the API,
/// keeping the local ledger in step with each response.
class TasksController extends ChangeNotifier {
  TasksController.forProfile(UserProfile profile) {
    if (profile.isParent) {
      _tasks = [
        ChoreTask(
          id: 't1',
          title: 'Take out the trash',
          details: 'Kitchen + bathroom bins to the curb.',
          childName: 'Maya',
          points: 10,
          requiresPhoto: true,
          state: TaskState.pendingReview,
          // Submitted from another device; photo arrives with sync.
          photoPath: null,
        ),
        ChoreTask(
          id: 't2',
          title: 'Water the plants',
          details: 'Living room and balcony.',
          childName: 'Leo',
          points: 5,
          state: TaskState.pendingReview,
        ),
        ChoreTask(
          id: 't3',
          title: 'Tidy bedroom',
          details: 'Bed, desk, floor — 15 minutes.',
          childName: 'Maya',
          points: 8,
          requiresPhoto: true,
        ),
        ChoreTask(
          id: 't4',
          title: 'Read 20 minutes',
          details: 'Any book, then log it.',
          childName: 'Leo',
          points: 6,
        ),
      ];
      _balances = {'Maya': 120, 'Leo': 45};
    } else {
      final me = profile.name;
      _tasks = [
        ChoreTask(
          id: 'c1',
          title: 'Take out the trash',
          details: 'Kitchen + bathroom bins to the curb.',
          childName: me,
          points: 10,
          requiresPhoto: true,
        ),
        ChoreTask(
          id: 'c2',
          title: 'Water the plants',
          details: 'Living room and balcony.',
          childName: me,
          points: 5,
        ),
        ChoreTask(
          id: 'c3',
          title: 'Math worksheet',
          details: 'Page 42, problems 1–10.',
          childName: me,
          points: 12,
          requiresPhoto: true,
          state: TaskState.changesRequested,
          photoPath: null,
        ),
      ];
      _balances = {me: 30};
    }
  }

  /// Empty store, for tests.
  TasksController.test({List<ChoreTask>? tasks, Map<String, int>? balances}) {
    if (tasks != null) _tasks = List.of(tasks);
    if (balances != null) _balances = Map.of(balances);
  }

  List<ChoreTask> _tasks = [];
  Map<String, int> _balances = {};
  TasksApi? _backend;

  List<ChoreTask> get tasks => List.unmodifiable(_tasks);

  /// True once an authenticated backend is attached.
  bool get isSynced => _backend != null;

  List<ChoreTask> tasksFor(String childName) =>
      _tasks.where((t) => t.childName == childName).toList();

  List<ChoreTask> get pendingReview =>
      _tasks.where((t) => t.state == TaskState.pendingReview).toList();

  int balanceFor(String childName) => _balances[childName] ?? 0;

  ChoreTask? byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  void _replace(ChoreTask updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
  }

  void _award(ChoreTask task) {
    _balances.update(
      task.childName,
      (balance) => balance + task.points,
      ifAbsent: () => task.points,
    );
  }

  static TaskState _submissionState(String? status) => switch (status) {
        'approved' => TaskState.approved,
        'changes_requested' => TaskState.changesRequested,
        _ => TaskState.pendingReview,
      };

  /// Attaches the backend API. Later calls hit the network for tasks
  /// that carry a [ChoreTask.serverId]; local-only tasks keep working
  /// offline against the in-memory ledger.
  void attachBackend(TasksApi backend) {
    _backend = backend;
  }

  /// Seeds one balance (e.g. the signed-in user's, from `GET /auth/me`).
  void setBalance(String childName, int balance) {
    _balances[childName] = balance;
    notifyListeners();
  }

  /// Replaces tasks (and, for parents, balances) with the backend state.
  /// Throws [ApiException] on transport or server errors.
  Future<void> refresh() async {
    final backend = _backend;
    if (backend == null) return;
    final snapshot = await backend.fetchSnapshot();
    _tasks = List.of(snapshot.tasks);
    if (snapshot.balances.isNotEmpty) {
      _balances = Map.of(snapshot.balances);
    }
    notifyListeners();
  }

  /// Child submits [taskId] for review, moving it to "Pending Review".
  Future<void> submitPhoto(String taskId, String? photoPath) async {
    final task = byId(taskId);
    if (task == null) return;
    final backend = _backend;
    if (backend != null && task.serverId != null) {
      final submission = await backend.submitTask(
        task.serverId!,
        photoPath: photoPath,
      );
      _replace(
        task.copyWith(
          state: _submissionState(submission['status'] as String?),
          photoPath: photoPath,
          remotePhoto: submission['photo_path'] as String?,
        ),
      );
      return;
    }
    _replace(
      task.copyWith(state: TaskState.pendingReview, photoPath: photoPath),
    );
  }

  /// Parent approves [taskId] and awards its points to the child. The
  /// backend awards the same amount, so the local ledger stays exact.
  Future<void> approve(String taskId) async {
    final task = byId(taskId);
    if (task == null || task.state != TaskState.pendingReview) return;
    final backend = _backend;
    if (backend != null && task.serverId != null) {
      final submission = await backend.reviewTask(task.serverId!, 'approve');
      final state = _submissionState(submission['status'] as String?);
      if (state == TaskState.approved) _award(task);
      _replace(task.copyWith(state: state));
      return;
    }
    _award(task);
    _replace(task.copyWith(state: TaskState.approved));
  }

  /// Parent sends [taskId] back for changes.
  Future<void> requestChanges(String taskId) async {
    final task = byId(taskId);
    if (task == null || task.state != TaskState.pendingReview) return;
    final backend = _backend;
    if (backend != null && task.serverId != null) {
      final submission =
          await backend.reviewTask(task.serverId!, 'request_changes');
      _replace(
        task.copyWith(
          state: _submissionState(submission['status'] as String?),
        ),
      );
      return;
    }
    _replace(task.copyWith(state: TaskState.changesRequested));
  }

  /// Approves every pending simple (no-photo) task. Returns how many
  /// were approved.
  Future<int> approveAllSimple() async {
    final simple = pendingReview.where((t) => t.isSimple).toList();
    for (final task in simple) {
      await approve(task.id);
    }
    return simple.length;
  }

  /// Spends [amount] points from [childName]'s balance.
  /// Returns false (and changes nothing) when funds are insufficient.
  bool deduct(String childName, int amount) {
    final balance = _balances[childName] ?? 0;
    if (balance < amount) return false;
    _balances[childName] = balance - amount;
    notifyListeners();
    return true;
  }
}
