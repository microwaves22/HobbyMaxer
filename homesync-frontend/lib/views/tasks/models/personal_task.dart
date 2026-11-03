/// Teen My To-Do List (Figma node 100:4622) personal-task data.
///
/// MOCK DATA — placeholder content only. Noah's personal tasks earn no
/// points and need no parent review, so this screen renders from the
/// arrays below and keeps completion/category state locally. It performs
/// no backend calls.
class PersonalTask {
  const PersonalTask({
    required this.id,
    required this.title,
    required this.meta,
    this.done = false,
  });

  final String id;
  final String title;
  final String meta;

  /// Design state: which rows render completed. The screen copies this
  /// into local state so tapping a completion circle stays local-only.
  final bool done;
}

/// MOCK: Noah's 3 personal tasks, verbatim from node 100:4622. Exactly
/// one row (`pack-soccer-bag`) is completed in the design.
const List<PersonalTask> kTeenPersonalTasks = [
  PersonalTask(
    id: 'read-history',
    title: 'Read history chapter 4',
    meta: 'Homework · Today, 5:00 PM',
  ),
  PersonalTask(
    id: 'run-mile',
    title: 'Run a mile',
    meta: 'Personal goal · Sun, Nov 1',
  ),
  PersonalTask(
    id: 'pack-soccer-bag',
    title: 'Pack soccer bag',
    meta: 'Task · Completed today',
    done: true,
  ),
];

/// A parent-assigned chore row: display-only, no checkbox.
class AssignedChore {
  const AssignedChore({required this.title, required this.time});

  final String title;
  final String time;
}

/// MOCK: the 2 "Assigned by Sarah" rows, verbatim from node 100:4622.
const List<AssignedChore> kTeenAssignedChores = [
  AssignedChore(title: 'Math homework', time: '6:00 PM'),
  AssignedChore(title: 'Vacuum living room', time: '7:00 PM'),
];

/// Add-card category chips. Labels are inferred from the personal-task
/// metas — the spec pins only the 9px vertical padding and the sage
/// selected fill, so update these from the design if they differ.
const List<String> kTeenTaskCategories = [
  'Homework',
  'Personal goal',
  'Task',
];

/// Progress-pill copy, computed from the data — e.g. "1 of 3 done".
/// No exclamation mark: the Kids pill has one ("1 of 3 done!") and this
/// screen must not copy it.
String teenProgressLabel({required int done, required int total}) =>
    '$done of $total done';
