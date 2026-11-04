import 'dart:typed_data';

import '../../core/network/api_client.dart';
import '../../core/widgets/member_avatar.dart';
import 'models/chore_task.dart';

/// One synced snapshot: backend tasks plus the points ledger balances.
class TasksSnapshot {
  const TasksSnapshot({
    required this.tasks,
    required this.balances,
    this.avatars = const {},
  });

  final List<ChoreTask> tasks;
  final Map<String, int> balances;

  /// Display-ready avatar URLs by member name (`{}` when unknown).
  final Map<String, String> avatars;
}

/// Backend task endpoints (`GET /tasks/`, submissions, review).
class TasksApi {
  TasksApi(this.client);

  final ApiClient client;

  /// Fetches tasks, merges each open task's latest submission (for state
  /// and evidence), and resolves assignee names + balances from the
  /// family roster (parents only; children keep local balances).
  Future<TasksSnapshot> fetchSnapshot() async {
    final raw = await client.get('/tasks/') as List;
    final names = <int, String>{};
    final balances = <String, int>{};
    final avatars = <String, String>{};
    try {
      final family = await client.get('/families/me') as Map<String, dynamic>;
      for (final member in family['members'] as List) {
        final user = member as Map<String, dynamic>;
        final name = user['display_name'] as String;
        names[user['id'] as int] = name;
        balances[name] = user['points_balance'] as int? ?? 0;
        final avatar =
            resolveAvatarUrl(user['avatar_url'] as String?, client.baseUrl);
        if (avatar != null) avatars[name] = avatar;
      }
    } on ApiException catch (e) {
      if (e.statusCode != 403 && e.statusCode != 404) rethrow;
    }

    final tasks = <ChoreTask>[];
    for (final item in raw) {
      final task = item as Map<String, dynamic>;
      Map<String, dynamic>? latest;
      if (task['status'] != 'approved') {
        final submissions =
            await client.get("/tasks/${task['id']}/submissions") as List;
        if (submissions.isNotEmpty) {
          latest = submissions.last as Map<String, dynamic>;
        }
      }
      tasks.add(_mapTask(task, names, latest));
    }
    return TasksSnapshot(tasks: tasks, balances: balances, avatars: avatars);
  }

  static ChoreTask _mapTask(
    Map<String, dynamic> task,
    Map<int, String> names,
    Map<String, dynamic>? latest,
  ) {
    final status = task['status'] as String? ?? 'open';
    final submittedBy = latest?['submitted_by_user_id'] as int?;
    final assignee = task['assigned_to_user_id'] as int?;
    final childName = names[assignee] ?? names[submittedBy] ?? 'Unassigned';
    final submissionStatus = latest?['status'] as String?;
    final state = switch (status) {
      'approved' => TaskState.approved,
      'pending_review' => TaskState.pendingReview,
      _ => submissionStatus == 'changes_requested'
          ? TaskState.changesRequested
          : TaskState.pending,
    };
    return ChoreTask(
      id: 'srv-${task['id']}',
      serverId: task['id'] as int,
      title: task['title'] as String? ?? 'Untitled',
      details: task['description'] as String? ?? '',
      childName: childName,
      points: task['points_reward'] as int? ?? 0,
      requiresPhoto: task['requires_photo'] as bool? ?? false,
      state: state,
      remotePhoto: latest?['photo_path'] as String?,
    );
  }

  /// Submits a task for review (multipart photo upload).
  /// Returns the created submission JSON.
  Future<Map<String, dynamic>> submitTask(
    int serverId, {
    String? photoPath,
    Uint8List? photoBytes,
    String? note,
  }) async {
    final body = await client.postMultipart(
      '/tasks/$serverId/submit',
      fields: {if (note != null) 'note': note},
      fileField: (photoPath == null && photoBytes == null) ? null : 'photo',
      filePath: photoPath,
      fileBytes: photoBytes,
      filename: 'evidence.jpg',
    );
    return body as Map<String, dynamic>;
  }

  /// Reviews a task (`approve` or `request_changes`).
  /// Returns the updated submission JSON.
  Future<Map<String, dynamic>> reviewTask(
    int serverId,
    String action, {
    String? note,
  }) async {
    final body = await client.put(
      '/tasks/$serverId/approve',
      body: {'action': action, if (note != null) 'note': note},
    );
    return body as Map<String, dynamic>;
  }
}
