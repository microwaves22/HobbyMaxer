import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/customization/customization_controller.dart';
import 'package:homesync/views/customization/customization_data.dart';
import 'package:homesync/views/customization/customization_store.dart';

void main() {
  group('CustomizationController', () {
    test('starts with no selection (theme defaults apply)', () {
      final controller = CustomizationController(
        store: InMemoryCustomizationStore(),
      );
      expect(controller.selection, isNull);
    });

    test('update publishes and persists', () async {
      final store = InMemoryCustomizationStore();
      final controller = CustomizationController(store: store);
      var notifications = 0;
      controller.addListener(() => notifications++);
      const selection = CustomizationSelection(
        segment: CustomizationSegment.settings,
        avatarId: 'fox',
        backgroundId: 'sunset',
      );

      await controller.update(selection);

      expect(controller.selection, selection);
      expect(controller.background.id, 'sunset');
      expect(notifications, 1);
      expect(await store.load(), selection);
    });

    test('restore reloads a saved selection', () async {
      final store = InMemoryCustomizationStore();
      await store.save(
        const CustomizationSelection(
          segment: CustomizationSegment.forYou,
          avatarId: 'bunny',
          backgroundId: 'night',
        ),
      );
      final controller = CustomizationController(store: store);

      await controller.restore();

      expect(controller.selection?.backgroundId, 'night');
      expect(controller.background.id, 'night');
    });

    test('restore keeps null selection when nothing was saved', () async {
      final controller = CustomizationController(
        store: InMemoryCustomizationStore(),
      );

      await controller.restore();

      expect(controller.selection, isNull);
    });
  });
}
