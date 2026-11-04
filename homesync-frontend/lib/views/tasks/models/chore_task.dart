import 'dart:typed_data';

/// A chore/homework task assigned to a child.
class ChoreTask {
  ChoreTask({
    required this.id,
    required this.title,
    required this.details,
    required this.childName,
    required this.points,
    this.requiresPhoto = false,
    this.state = TaskState.pending,
    this.feedback,
    this.photoPath,
    this.photoBytes,
    this.serverId,
    this.remotePhoto,
    this.isParentTodo = false,
    this.isHomework = false,
  });

  final String id;
  final String title;
  final String details;
  final String childName;
  final int points;
  final bool requiresPhoto;
  final TaskState state;

  /// Parent's revision note from the latest "Request Changes" review.
  /// Shown to the child on retry; null when no feedback was sent.
  final String? feedback;

  /// Local path of the submitted evidence photo, if any.
  ///
  /// Legacy (native-only): new picks store [photoBytes] instead, which
  /// is the only previewable form on Flutter Web.
  final String? photoPath;

  /// Submitted evidence photo bytes (web-safe preview + upload).
  final Uint8List? photoBytes;

  /// Backend task id once synced; null for local-only demo tasks.
  final int? serverId;

  /// Backend evidence filename (lives in server `uploads/`); the API
  /// serves no photo downloads, so this renders as a placeholder.
  final String? remotePhoto;

  /// True for parent-owned to-dos, managed in the Parent To-Do section
  /// instead of the child chore / review flow.
  final bool isParentTodo;

  /// True for homework/school work, shown under the hub's Homework
  /// segment; false for household chores. Mirrors the backend
  /// `task_type` (`homework` vs `chore`).
  final bool isHomework;

  /// A task is "simple" when it needs no photo evidence, so a parent can
  /// batch-approve it without reviewing a photo.
  bool get isSimple => !requiresPhoto;

  ChoreTask copyWith({
    String? title,
    String? details,
    TaskState? state,
    String? photoPath,
    Uint8List? photoBytes,
    String? remotePhoto,
    int? points,
    bool? requiresPhoto,
    String? feedback,
  }) {
    return ChoreTask(
      id: id,
      title: title ?? this.title,
      details: details ?? this.details,
      childName: childName,
      points: points ?? this.points,
      requiresPhoto: requiresPhoto ?? this.requiresPhoto,
      state: state ?? this.state,
      photoPath: photoPath ?? this.photoPath,
      photoBytes: photoBytes ?? this.photoBytes,
      serverId: serverId,
      remotePhoto: remotePhoto ?? this.remotePhoto,
      isParentTodo: isParentTodo,
      isHomework: isHomework,
      feedback: feedback ?? this.feedback,
    );
  }
}

enum TaskState { pending, pendingReview, approved, changesRequested }

extension TaskStateLabel on TaskState {
  String get label => switch (this) {
        TaskState.pending => 'Pending',
        TaskState.pendingReview => 'Pending Review',
        TaskState.approved => 'Approved',
        TaskState.changesRequested => 'Changes Requested',
      };
}
