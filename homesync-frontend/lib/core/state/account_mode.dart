import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/onboarding/models/user_profile.dart';

/// Central account mode state: the role/mode chosen once during setup.
///
/// [ChooseModeScreen] writes the selection via [select]; downstream
/// screens ([ProfileSetupScreen], dashboards) read it through
/// [AccountModeScope] instead of asking again. The selection persists
/// in [SharedPreferences] so it survives restarts; [restore] reloads it
/// at startup. Screens reachable without a prior choice (direct
/// registration links, widget tests) see [hasSelection] false and fall
/// back to their local selectors.
class AccountModeController extends ChangeNotifier {
  AccountModeController({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const String roleKey = 'account_mode_role';
  static const String modeKey = 'account_mode_mode';

  FamilyRole? _role;
  FamilyMode? _mode;

  /// Whether a mode was chosen (and not cleared) this session or a prior one.
  bool get hasSelection => _role != null && _mode != null;

  FamilyRole? get role => _role;
  FamilyMode? get mode => _mode;

  Future<SharedPreferences> _prefs() async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  /// Records the chosen role/mode, notifies listeners, and persists it.
  /// Persistence failures are silent: the in-memory selection still applies.
  Future<void> select({required FamilyRole role, required FamilyMode mode}) async {
    _role = role;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await _prefs();
      await prefs.setString(roleKey, role.name);
      await prefs.setString(modeKey, mode.name);
    } catch (_) {
      // Silent: the live selection remains for this session.
    }
  }

  /// Reloads a previously saved selection. Unknown or missing values
  /// leave the controller unselected.
  Future<void> restore() async {
    try {
      final prefs = await _prefs();
      final roleName = prefs.getString(roleKey);
      final modeName = prefs.getString(modeKey);
      FamilyRole? role;
      FamilyMode? mode;
      if (roleName != null) {
        for (final candidate in FamilyRole.values) {
          if (candidate.name == roleName) role = candidate;
        }
      }
      if (modeName != null) {
        for (final candidate in FamilyMode.values) {
          if (candidate.name == modeName) mode = candidate;
        }
      }
      if (role == null || mode == null) return;
      _role = role;
      _mode = mode;
      notifyListeners();
    } catch (_) {
      // Silent: no usable saved selection.
    }
  }

  /// Clears the selection (sign-out). Test/backdoor use only for now.
  Future<void> clear() async {
    _role = null;
    _mode = null;
    notifyListeners();
    try {
      final prefs = await _prefs();
      await prefs.remove(roleKey);
      await prefs.remove(modeKey);
    } catch (_) {
      // Silent.
    }
  }
}

/// Provides the [AccountModeController] to the subtree (normally the
/// whole app, above [MaterialApp]).
class AccountModeScope extends InheritedNotifier<AccountModeController> {
  const AccountModeScope({
    super.key,
    required AccountModeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AccountModeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AccountModeScope>();
    assert(scope != null, 'AccountModeScope not found above this widget.');
    return scope!.notifier!;
  }

  static AccountModeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccountModeScope>()?.notifier;
}
