import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/companion/ava_companion_data.dart';
import 'package:homesync/views/companion/ava_companion_drawer.dart';

Future<void> _pumpDrawer(
  WidgetTester tester, {
  VoidCallback? onCloseDrawer,
  ValueChanged<String>? onCareAction,
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
        body: Stack(
          children: [
            Container(color: const Color(0xFFFBF7EF)),
            AvaCompanionDrawer(
              onCloseDrawer: onCloseDrawer,
              onCareAction: onCareAction,
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
  group('AvaCompanionDrawer (Figma 62:6040)', () {
    testWidgets('renders the Figma content verbatim', (tester) async {
      await _pumpDrawer(tester);

      // Identity.
      expect(find.text("AVA'S COMPANION"), findsOneWidget);
      expect(find.text('Meet Sparkle! ✨'), findsOneWidget);

      // Mood pills.
      expect(find.text('Care 80%'), findsOneWidget);
      expect(find.text('😊 Happy'), findsOneWidget);
      expect(find.text('★ 120 pts'), findsOneWidget);

      // Care stats.
      expect(find.text('Care'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);

      // Care buttons.
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('🍎 3 apples'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text("Let's have fun!"), findsOneWidget);

      // Chore-care card.
      expect(find.text('Little chores, big magic!'), findsOneWidget);
      expect(
        find.text(
          'Approved chores earn points and yummy care items for Sparkle.',
        ),
        findsOneWidget,
      );
      expect(find.text('🍎 Apples ×3'), findsOneWidget);
      expect(find.text('🧸 Toys ×2'), findsOneWidget);

      // Footer.
      expect(
        find.text('Sparkle loves spending time with you. 💛'),
        findsOneWidget,
      );
    });

    testWidgets('matches the Figma geometry', (tester) async {
      await _pumpDrawer(tester);

      // Scrim: full width, top 145, height 755.
      final scrim = find.byKey(const Key('ava-scrim'));
      expect(tester.getTopLeft(scrim), const Offset(0, 145));
      expect(tester.getSize(scrim), const Size(375, 755));
      expect(
        tester.widget<Container>(scrim).color,
        const Color.fromRGBO(38, 57, 44, 0.14),
      );

      // Panel: left 12, top 148, width 363, anchored to the bottom.
      final panel = find.byKey(const Key('ava-panel'));
      expect(tester.getTopLeft(panel), const Offset(12, 148));
      expect(tester.getSize(panel), const Size(363, 664));
      final panelDecoration =
          tester.widget<Container>(panel).decoration! as BoxDecoration;
      expect(
        panelDecoration.color,
        const Color.fromRGBO(255, 252, 245, 0.95),
      );
      expect(
        panelDecoration.border,
        Border.all(color: const Color(0xFFFFFFFF)),
      );
      expect(
        panelDecoration.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      );
      expect(
        panelDecoration.boxShadow,
        const [
          BoxShadow(
            color: Color.fromRGBO(38, 57, 44, 0.15),
            offset: Offset(0, 8),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      );
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Identity type.
      final eyebrow = _styleOf(tester, "AVA'S COMPANION");
      expect(eyebrow.fontSize, 11);
      expect(eyebrow.fontWeight, FontWeight.w800);
      expect(eyebrow.color, const Color(0xFF5F7F55));
      final name = _styleOf(tester, 'Meet Sparkle! ✨');
      expect(name.fontSize, 25);
      expect(name.fontWeight, FontWeight.w800);

      // Close: 44px lavender circle, 20px X.
      final close = find.byKey(const Key('ava-close'));
      expect(tester.getSize(close), const Size(44, 44));
      final closeCircle = tester.widget<Container>(
        find.descendant(of: close, matching: find.byType(Container)),
      );
      final closeDecoration = closeCircle.decoration! as BoxDecoration;
      expect(closeDecoration.color, const Color(0xFFDDD5EE));
      expect(closeDecoration.shape, BoxShape.circle);
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: close, matching: find.byType(Icon)),
            )
            .size,
        20,
      );

      // Pills carry their data fills.
      for (var i = 0; i < kAvaCompanionPills.length; i++) {
        final pill = tester.widget<Container>(
          find.byKey(Key('ava-pill-$i')),
        );
        expect(
          (pill.decoration! as BoxDecoration).color,
          kAvaCompanionPills[i].background,
        );
        expect(
          _styleOf(tester, kAvaCompanionPills[i].label).color,
          kAvaCompanionPills[i].foreground,
        );
      }

      // Stat fills are coral, on 14px tracks, widths from the data.
      for (final stat in kAvaCareStats) {
        final track = find.byKey(Key('ava-stat-${stat.id}-track'));
        final fill = find.byKey(Key('ava-stat-${stat.id}-fill'));
        expect(tester.getSize(track).height, 14);
        expect(
          (tester.widget<Container>(track).decoration! as BoxDecoration)
              .color,
          const Color(0xFFE4EBDC),
        );
        expect(
          (tester.widget<Container>(fill).decoration! as BoxDecoration)
              .color,
          const Color(0xFFE58B6D),
        );
        expect(
          tester.getSize(fill).width,
          moreOrLessEquals(
            tester.getSize(track).width * stat.percent / 100,
            epsilon: 1.0,
          ),
        );
      }

      // Care buttons: min-height 86, radius 23, ExtraBold 19 titles.
      for (final id in ['feed', 'play']) {
        final button = tester.widget<GestureDetector>(
          find.byKey(Key('ava-action-$id')),
        );
        final box = button.child! as Container;
        final boxDecoration = box.decoration! as BoxDecoration;
        expect(box.constraints!.minHeight, 86);
        expect(
          boxDecoration.borderRadius,
          BorderRadius.circular(23),
        );
        expect(
          boxDecoration.color,
          id == 'feed'
              ? const Color(0xFF5F7F55)
              : const Color(0xFFDDD5EE),
        );
      }
      final feedTitle = _styleOf(tester, 'Feed');
      expect(feedTitle.fontSize, 19);
      expect(feedTitle.fontWeight, FontWeight.w800);
      expect(feedTitle.color, const Color(0xFFFFFFFF));

      // Chore-care card: yellowLight with two inventory pills.
      final card = tester.widget<Container>(
        find.byKey(const Key('ava-chore-card')),
      );
      expect(
        (card.decoration! as BoxDecoration).color,
        const Color(0xFFFDF0C8),
      );

      // Footer: Medium 12 sage.
      final footer = _styleOf(
        tester,
        'Sparkle loves spending time with you. 💛',
      );
      expect(footer.fontSize, 12);
      expect(footer.fontWeight, FontWeight.w500);
      expect(footer.color, const Color(0xFF5F7F55));
    });

    testWidgets('close button dismisses', (tester) async {
      var calls = 0;
      await _pumpDrawer(tester, onCloseDrawer: () => calls++);

      await tester.tap(find.byKey(const Key('ava-close')));
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

      final feed = find.byKey(const Key('ava-action-feed'));
      await tester.ensureVisible(feed);
      await tester.pumpAndSettle();
      await tester.tap(feed);

      final play = find.byKey(const Key('ava-action-play'));
      await tester.ensureVisible(play);
      await tester.pumpAndSettle();
      await tester.tap(play);

      expect(reported, ['feed', 'play']);
    });
  });
}
