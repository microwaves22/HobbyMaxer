import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/companion/noah_companion_data.dart';
import 'package:homesync/views/companion/noah_companion_drawer.dart';

Future<void> _pumpDrawer(
  WidgetTester tester, {
  VoidCallback? onCloseDrawer,
  ValueChanged<String>? onCareAction,
  VoidCallback? onEquipArmor,
  ValueChanged<String>? onCollectionItemPress,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F3EF),
        body: Stack(
          children: [
            Container(color: const Color(0xFFF4F3EF)),
            NoahCompanionDrawer(
              onCloseDrawer: onCloseDrawer,
              onCareAction: onCareAction,
              onEquipArmor: onEquipArmor,
              onCollectionItemPress: onCollectionItemPress,
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text).first);
  return widget.style!;
}

void main() {
  group('NoahCompanionDrawer (Figma 62:5907)', () {
    testWidgets('renders the Figma content verbatim', (tester) async {
      await _pumpDrawer(tester);

      // Identity.
      expect(find.text("NOAH'S COMPANION"), findsOneWidget);
      expect(find.text('Ember'), findsOneWidget);
      expect(find.text('120 pts'), findsOneWidget);

      // Wellbeing pills.
      expect(find.text('Thriving'), findsOneWidget);
      expect(find.text('☾ Rested'), findsOneWidget);
      expect(find.text('94% care'), findsOneWidget);

      // Care stats.
      expect(find.text('Nourishment'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('98%'), findsOneWidget);

      // Care actions: Feed + Interact, and NO Play.
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('3 emberberries'), findsOneWidget);
      expect(find.text('Interact'), findsOneWidget);
      expect(find.text('Bond with Ember'), findsOneWidget);
      expect(find.text('Play'), findsNothing);

      // Earn line (no card, no inventory pills).
      expect(
        find.text('Approved chores earn points + care items for Ember.'),
        findsOneWidget,
      );

      // Armor unlock.
      expect(find.text('NEWLY UNLOCKED · OWNED'), findsOneWidget);
      expect(find.text('Scout armor'), findsOneWidget);
      expect(find.text('Custom armor · Chore streak reward'), findsOneWidget);
      expect(find.text('Equip'), findsOneWidget);

      // Collection.
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

    testWidgets('matches the Figma geometry', (tester) async {
      await _pumpDrawer(tester);

      // Scrim: full width, top 142, height 838.
      final scrim = find.byKey(const Key('noah-scrim'));
      expect(tester.getTopLeft(scrim), const Offset(0, 142));
      expect(tester.getSize(scrim), const Size(375, 838));
      expect(
        tester.widget<Container>(scrim).color,
        const Color.fromRGBO(38, 57, 44, 0.14),
      );

      // Panel: left 12, top 145, width 363, anchored to the bottom.
      final panel = find.byKey(const Key('noah-panel'));
      expect(tester.getTopLeft(panel), const Offset(12, 145));
      expect(tester.getSize(panel).width, 363);
      final panelDecoration =
          tester.widget<Container>(panel).decoration! as BoxDecoration;
      expect(
        panelDecoration.border,
        Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.93),
        ),
      );
      expect(
        panelDecoration.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      );
      // No shadow: the spec lists none (unlike Ava's drawer).
      expect(panelDecoration.boxShadow, isNull);
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Identity type: 10px MUTE eyebrow, 24px name, starless pill.
      final eyebrow = _styleOf(tester, "NOAH'S COMPANION");
      expect(eyebrow.fontSize, 10);
      expect(eyebrow.fontWeight, FontWeight.w800);
      expect(eyebrow.color, const Color(0xFF7C877A));
      final name = _styleOf(tester, 'Ember');
      expect(name.fontSize, 24);
      expect(name.fontWeight, FontWeight.w800);
      expect(find.text('★ 120 pts'), findsNothing);

      // Close: 32×32 sageLight, radius 16, 16px X.
      final close = find.byKey(const Key('noah-close'));
      expect(tester.getSize(close), const Size(32, 32));
      final closeBox = tester.widget<Container>(
        find.descendant(of: close, matching: find.byType(Container)),
      );
      final closeDecoration = closeBox.decoration! as BoxDecoration;
      expect(closeDecoration.color, const Color(0xFFE4EBDC));
      expect(
        closeDecoration.borderRadius,
        BorderRadius.circular(16),
      );
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: close, matching: find.byType(Icon)),
            )
            .size,
        16,
      );

      // Habitat: 167 tall, radius 22, sageLight.
      final habitat = find.byKey(const Key('noah-habitat'));
      expect(tester.getSize(habitat).height, 167);
      final habitatDecoration =
          tester.widget<Container>(habitat).decoration! as BoxDecoration;
      expect(habitatDecoration.color, const Color(0xFFE4EBDC));
      expect(
        habitatDecoration.borderRadius,
        BorderRadius.circular(22),
      );

      // Pills carry their data fills (all sage text).
      for (var i = 0; i < kNoahCompanionPills.length; i++) {
        final pill = tester.widget<Container>(
          find.byKey(Key('noah-pill-$i')),
        );
        expect(
          (pill.decoration! as BoxDecoration).color,
          kNoahCompanionPills[i].background,
        );
        expect(
          _styleOf(tester, kNoahCompanionPills[i].label).color,
          const Color(0xFF5F7F55),
        );
      }

      // Stat fills are sage on 7px tracks, widths from the data.
      for (final stat in kNoahCareStats) {
        final track = find.byKey(Key('noah-stat-${stat.id}-track'));
        final fill = find.byKey(Key('noah-stat-${stat.id}-fill'));
        expect(tester.getSize(track).height, 7);
        expect(
          (tester.widget<Container>(track).decoration! as BoxDecoration)
              .color,
          const Color(0xFFE4EBDC),
        );
        expect(
          (tester.widget<Container>(fill).decoration! as BoxDecoration)
              .color,
          const Color(0xFF5F7F55),
        );
        expect(
          tester.getSize(fill).width,
          moreOrLessEquals(
            tester.getSize(track).width * stat.percent / 100,
            epsilon: 1.0,
          ),
        );
      }

      // Care actions: 50px horizontal buttons.
      final feed = find.byKey(const Key('noah-action-feed'));
      final interact = find.byKey(const Key('noah-action-interact'));
      expect(tester.getSize(feed).height, 50);
      expect(tester.getSize(interact).height, 50);
      // Side by side, not stacked.
      expect(
        tester.getTopLeft(feed).dy,
        tester.getTopLeft(interact).dy,
      );
      expect(
        ((tester.widget<GestureDetector>(feed).child! as Container)
                    .decoration! as BoxDecoration)
                .color,
        const Color(0xFF5F7F55),
      );
      expect(
        ((tester.widget<GestureDetector>(interact).child!
                    as Container)
                .decoration! as BoxDecoration)
            .color,
        const Color(0xFFE4EBDC),
      );

      // Earn line: 11px mute.
      final earn = _styleOf(
        tester,
        'Approved chores earn points + care items for Ember.',
      );
      expect(earn.fontSize, 11);
      expect(earn.color, const Color(0xFF7C877A));

      // Armor: 42×48 white tile, 27px shield, sage Equip radius 13.
      final armorCard = find.byKey(const Key('noah-armor-card'));
      final tile = find.descendant(
        of: armorCard,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color ==
                  const Color(0xFFFFFFFF),
        ),
      );
      expect(tile, findsOneWidget);
      expect(tester.getSize(tile), const Size(42, 48));
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: tile, matching: find.byType(Icon)),
            )
            .size,
        27,
      );
      final equip = tester.widget<GestureDetector>(
        find.byKey(const Key('noah-armor-equip')),
      );
      final equipBox = equip.child! as Container;
      final equipDecoration = equipBox.decoration! as BoxDecoration;
      expect(equipDecoration.color, const Color(0xFF5F7F55));
      expect(
        equipDecoration.borderRadius,
        BorderRadius.circular(13),
      );

      // Collection: 2×2, unlocked white / locked #EDEEE8, 1px borders.
      for (final item in kNoahCollection) {
        final cell = tester.widget<GestureDetector>(
          find.byKey(Key('noah-collection-${item.id}')),
        );
        final cellBox = cell.child! as Container;
        final cellDecoration = cellBox.decoration! as BoxDecoration;
        expect(
          cellDecoration.color,
          item.locked
              ? const Color(0xFFEDEEE8)
              : const Color(0xFFFFFFFF),
        );
        expect(
          cellDecoration.border,
          Border.all(color: const Color(0xFFE8E4D8)),
        );
        final nameStyle = _styleOf(tester, item.name);
        expect(nameStyle.fontSize, 11);
        expect(nameStyle.fontWeight, FontWeight.w800);
        final stateStyle = _styleOf(tester, item.state);
        expect(stateStyle.fontSize, 9);
        expect(stateStyle.fontWeight, FontWeight.w500);
        expect(
          stateStyle.color,
          item.locked
              ? const Color(0xFF7C877A)
              : const Color(0xFF5F7F55),
        );
      }
    });

    testWidgets('close button dismisses', (tester) async {
      var calls = 0;
      await _pumpDrawer(tester, onCloseDrawer: () => calls++);

      await tester.tap(find.byKey(const Key('noah-close')));
      expect(calls, 1);
    });

    testWidgets('scrim tap dismisses', (tester) async {
      var calls = 0;
      await _pumpDrawer(tester, onCloseDrawer: () => calls++);

      // Left strip beside the panel (panel starts at x=12).
      await tester.tapAt(const Offset(6, 200));
      expect(calls, 1);
    });

    testWidgets('care buttons report their ids', (tester) async {
      final reported = <String>[];
      await _pumpDrawer(tester, onCareAction: reported.add);

      final feed = find.byKey(const Key('noah-action-feed'));
      await tester.ensureVisible(feed);
      await tester.pumpAndSettle();
      await tester.tap(feed);

      final interact = find.byKey(const Key('noah-action-interact'));
      await tester.ensureVisible(interact);
      await tester.pumpAndSettle();
      await tester.tap(interact);

      expect(reported, ['feed', 'interact']);
    });

    testWidgets('Equip reports', (tester) async {
      var calls = 0;
      await _pumpDrawer(tester, onEquipArmor: () => calls++);

      final equip = find.byKey(const Key('noah-armor-equip'));
      await tester.ensureVisible(equip);
      await tester.pumpAndSettle();
      await tester.tap(equip);

      expect(calls, 1);
    });

    testWidgets('all collection items report taps, locked included',
        (tester) async {
      final reported = <String>[];
      await _pumpDrawer(tester, onCollectionItemPress: reported.add);

      final unlocked = find.byKey(const Key('noah-collection-forest-skin'));
      await tester.ensureVisible(unlocked);
      await tester.pumpAndSettle();
      await tester.tap(unlocked);

      final locked = find.byKey(const Key('noah-collection-moonstone-den'));
      await tester.ensureVisible(locked);
      await tester.pumpAndSettle();
      await tester.tap(locked);

      expect(reported, ['forest-skin', 'moonstone-den']);
    });
  });
}
