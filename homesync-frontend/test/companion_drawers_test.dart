import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/companion/ava_companion_drawer.dart';
import 'package:homesync/views/companion/noah_companion_drawer.dart';

Future<void> _pumpAva(
  WidgetTester tester, {
  VoidCallback? onCloseDrawer,
  ValueChanged<String>? onCareAction,
}) async {
  tester.view.physicalSize = const Size(1125, 3000);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AvaCompanionDrawer(
          onCloseDrawer: onCloseDrawer,
          onCareAction: onCareAction,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpNoah(
  WidgetTester tester, {
  VoidCallback? onCloseDrawer,
  ValueChanged<String>? onCareAction,
  VoidCallback? onEquipArmor,
  ValueChanged<String>? onCollectionItemPress,
}) async {
  tester.view.physicalSize = const Size(1125, 3600);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NoahCompanionDrawer(
          onCloseDrawer: onCloseDrawer,
          onCareAction: onCareAction,
          onEquipArmor: onEquipArmor,
          onCollectionItemPress: onCollectionItemPress,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Ava companion drawer (Figma 62:6040)', () {
    testWidgets('renders identity, pills, stats, and actions', (tester) async {
      await _pumpAva(tester);

      expect(find.text("AVA'S COMPANION"), findsOneWidget);
      expect(find.text('Meet Sparkle! ✨'), findsOneWidget);

      expect(find.text('Care 80%'), findsOneWidget);
      expect(find.text('😊 Happy'), findsOneWidget);
      expect(find.text('★ 120 pts'), findsOneWidget);

      expect(find.text('Care'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('🍎 3 apples'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text("Let's have fun!"), findsOneWidget);

      expect(find.text('Little chores, big magic!'), findsOneWidget);
      expect(
        find.text(
          'Approved chores earn points and yummy care items for Sparkle.',
        ),
        findsOneWidget,
      );
      expect(find.text('🍎 Apples ×3'), findsOneWidget);
      expect(find.text('🧸 Toys ×2'), findsOneWidget);
      expect(
        find.text('Sparkle loves spending time with you. 💛'),
        findsOneWidget,
      );
    });

    testWidgets('close and care actions fire', (tester) async {
      var closed = 0;
      String? action;
      await _pumpAva(
        tester,
        onCloseDrawer: () => closed++,
        onCareAction: (id) => action = id,
      );

      await tester.tap(find.text('Feed'));
      await tester.pumpAndSettle();
      expect(action, 'feed');

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(closed, 1);
    });
  });

  group('Noah companion drawer (Figma 62:5907)', () {
    testWidgets('renders identity, habitat, and wellbeing', (tester) async {
      await _pumpNoah(tester);

      expect(find.text("NOAH'S COMPANION"), findsOneWidget);
      expect(find.text('Ember'), findsOneWidget);
      expect(find.text('120 pts'), findsOneWidget);

      expect(find.text('Thriving'), findsOneWidget);
      expect(find.text('☾ Rested'), findsOneWidget);
      expect(find.text('94% care'), findsOneWidget);

      expect(find.text('Nourishment'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('98%'), findsOneWidget);
    });

    testWidgets('renders actions, earn line, armor, and collection',
        (tester) async {
      await _pumpNoah(tester);

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('3 emberberries'), findsOneWidget);
      expect(find.text('Interact'), findsOneWidget);
      expect(find.text('Bond with Ember'), findsOneWidget);
      expect(find.text('Play'), findsNothing);

      expect(
        find.text('Approved chores earn points + care items for Ember.'),
        findsOneWidget,
      );

      expect(find.text('NEWLY UNLOCKED · OWNED'), findsOneWidget);
      expect(find.text('Scout armor'), findsOneWidget);
      expect(
        find.text('Custom armor · Chore streak reward'),
        findsOneWidget,
      );
      expect(find.text('Equip'), findsOneWidget);

      expect(find.text('Make Ember yours'), findsOneWidget);
      expect(find.text('Forest skin'), findsOneWidget);
      expect(find.text('Skin · Equipped'), findsOneWidget);
      expect(find.text('Moss & copper'), findsOneWidget);
      expect(find.text('Palette · Owned'), findsOneWidget);
      expect(find.text('Woodland den'), findsOneWidget);
      expect(find.text('Background · Equipped'), findsOneWidget);
      expect(find.text('Moonstone den'), findsOneWidget);
      expect(find.text('Locked · 180 pts'), findsOneWidget);
    });

    testWidgets('all handlers fire', (tester) async {
      var closed = 0;
      String? action;
      var equipped = 0;
      String? item;
      await _pumpNoah(
        tester,
        onCloseDrawer: () => closed++,
        onCareAction: (id) => action = id,
        onEquipArmor: () => equipped++,
        onCollectionItemPress: (id) => item = id,
      );

      await tester.tap(find.text('Interact'));
      await tester.pumpAndSettle();
      expect(action, 'interact');

      await tester.tap(find.text('Equip'));
      await tester.pumpAndSettle();
      expect(equipped, 1);

      await tester.tap(find.text('Moonstone den'));
      await tester.pumpAndSettle();
      expect(item, 'moonstone-den');

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(closed, 1);
    });
  });
}
