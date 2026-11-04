import 'package:flutter/widgets.dart';

import 'customization_data.dart';
import 'customization_store.dart';

/// App-wide customization state: the avatar/background selection applied
/// live across the app (dashboard background) and persisted locally.
///
/// [CustomizationScreen] writes through [update]; interested screens
/// (currently the dashboard) read [selection]/[background] via
/// [CustomizationScope]. A null [selection] means nothing was ever saved:
/// screens keep their theme defaults until the user picks and saves.
class CustomizationController extends ChangeNotifier {
  CustomizationController({CustomizationStore? store})
      : _store = store ?? PrefsCustomizationStore();

  final CustomizationStore _store;

  CustomizationSelection? _selection;

  CustomizationSelection? get selection => _selection;

  /// The selected background, or the design default (meadow) when the
  /// saved id is unknown. Only meaningful when [selection] != null.
  BackgroundOption get background {
    final id = _selection?.backgroundId;
    for (final option in backgroundOptions) {
      if (option.id == id) return option;
    }
    return backgroundOptions.firstWhere(
      (o) => o.selected,
      orElse: () => backgroundOptions.first,
    );
  }

  /// Reloads the saved selection. Missing/corrupt data keeps [selection]
  /// null (theme defaults apply).
  Future<void> restore() async {
    final saved = await _store.load();
    if (saved == null) return;
    _selection = saved;
    notifyListeners();
  }

  /// Merges [selection] over the current one (or the design defaults),
  /// persists it, and notifies listeners so applied surfaces update live.
  Future<void> update(CustomizationSelection selection) async {
    _selection = selection;
    notifyListeners();
    try {
      await _store.save(selection);
    } catch (_) {
      // Silent: the live selection remains for this session.
    }
  }
}

/// Provides the [CustomizationController] to the subtree (normally the
/// whole app, above [MaterialApp]).
class CustomizationScope extends InheritedNotifier<CustomizationController> {
  const CustomizationScope({
    super.key,
    required CustomizationController controller,
    required super.child,
  }) : super(notifier: controller);

  static CustomizationController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CustomizationScope>();
    assert(scope != null, 'CustomizationScope not found above this widget.');
    return scope!.notifier!;
  }

  static CustomizationController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CustomizationScope>()
      ?.notifier;
}
