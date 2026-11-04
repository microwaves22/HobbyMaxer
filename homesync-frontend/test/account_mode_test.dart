import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homesync/core/state/account_mode.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountModeController', () {
    test('starts unselected', () {
      final controller = AccountModeController();
      expect(controller.hasSelection, isFalse);
      expect(controller.role, isNull);
      expect(controller.mode, isNull);
    });

    test('select notifies and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AccountModeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.select(role: FamilyRole.child, mode: FamilyMode.teen);

      expect(controller.hasSelection, isTrue);
      expect(controller.role, FamilyRole.child);
      expect(controller.mode, FamilyMode.teen);
      expect(notifications, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AccountModeController.roleKey), 'child');
      expect(prefs.getString(AccountModeController.modeKey), 'teen');
    });

    test('restore reloads a saved selection', () async {
      SharedPreferences.setMockInitialValues({
        AccountModeController.roleKey: 'parent',
        AccountModeController.modeKey: 'parent',
      });
      final controller = AccountModeController();

      await controller.restore();

      expect(controller.hasSelection, isTrue);
      expect(controller.role, FamilyRole.parent);
      expect(controller.mode, FamilyMode.parent);
    });

    test('restore ignores unknown values', () async {
      SharedPreferences.setMockInitialValues({
        AccountModeController.roleKey: 'grandparent',
        AccountModeController.modeKey: 'parent',
      });
      final controller = AccountModeController();

      await controller.restore();

      expect(controller.hasSelection, isFalse);
    });

    test('clear resets selection and storage', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AccountModeController();
      await controller.select(role: FamilyRole.parent, mode: FamilyMode.parent);
      expect(controller.hasSelection, isTrue);

      await controller.clear();

      expect(controller.hasSelection, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AccountModeController.roleKey), isNull);
      expect(prefs.getString(AccountModeController.modeKey), isNull);
    });
  });
}
