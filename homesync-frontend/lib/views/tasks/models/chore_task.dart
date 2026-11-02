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
    this.photoPath,
    this.serverId,
    this.remotePhoto,
  });

  final String id;
  final String title;
  final String details;
  final String childName;
  final int points;
  final bool requiresPhoto;
  final TaskState state;

  /// Local path of the submitted evidence photo, if any.
  final String? photoPath;

  /// Backend task id once synced; null for local-only demo tasks.
  final int? serverId;

  /// Backend evidence filename (lives in server `uploads/`); the API
  /// serves no photo downloads, so this renders as a placeholder.
  final String? remotePhoto;

  /// A task is "simple" when it needs no photo evidence, so a parent can
  /// batch-approve it without reviewing a photo.
  bool get isSimple => !requiresPhoto;

  ChoreTask copyWith({
    TaskState? state,
    String? photoPath,
    String? remotePhoto,
  }) {
    return ChoreTask(
      id: id,
      title: title,
      details: details,
      childName: childName,
      points: points,
      requiresPhoto: requiresPhoto,
      state: state ?? this.state,
      photoPath: photoPath ?? this.photoPath,
      serverId: serverId,
      remotePhoto: remotePhoto ?? this.remotePhoto,
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
