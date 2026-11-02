import 'package:flutter/widgets.dart';

/// Canonical focus-area labels, shared by onboarding and the dashboard.
abstract final class FocusAreas {
  static const String calendar = 'Calendar coordination';
  static const String chores = 'Chore distribution';
  static const String rewards = 'Task rewards';
  static const String homework = 'Homework tracking';

  static const List<String> all = [calendar, chores, rewards, homework];
}

/// Holds the household's selected focus areas and notifies listeners
/// so the dashboard can show or hide features dynamically.
class FocusAreasController extends ChangeNotifier {
  FocusAreasController([Iterable<String>? initial])
      : _selected = Set.of(initial ?? const <String>{});

  final Set<String> _selected;

  Set<String> get selected => Set.unmodifiable(_selected);

  bool has(String area) => _selected.contains(area);

  void toggle(String area) {
    if (_selected.contains(area)) {
      _selected.remove(area);
    } else {
      _selected.add(area);
    }
    notifyListeners();
  }

  void replaceAll(Iterable<String> areas) {
    _selected
      ..clear()
      ..addAll(areas);
    notifyListeners();
  }
}

/// Provides the [FocusAreasController] to the dashboard subtree.
class FocusAreasScope extends InheritedNotifier<FocusAreasController> {
  const FocusAreasScope({
    super.key,
    required FocusAreasController controller,
    required super.child,
  }) : super(notifier: controller);

  static FocusAreasController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FocusAreasScope>();
    assert(scope != null, 'FocusAreasScope not found above this widget.');
    return scope!.notifier!;
  }

  static FocusAreasController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FocusAreasScope>()?.notifier;
}
