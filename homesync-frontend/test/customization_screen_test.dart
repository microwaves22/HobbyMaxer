import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/customization/avatar_art.dart';
import 'package:homesync/views/customization/customization_data.dart';
import 'package:homesync/views/customization/customization_screen.dart';
import 'package:homesync/views/home/widgets/household_bottom_nav.dart';

const Color _ink = Color(0xFF2B3A2B);
const Color _mute = Color(0xFF7C877A);
const Color _sage = Color(0xFF7A9A85);
const Color _sageDark = Color(0xFF4A6A41);
const Color _sageLight = Color(0xFFE4EBDC);
const Color _white = Color(0xFFFFFFFF);
const Color _cream = Color(0xFFF9F8F6);
const Color _pink = Color(0xFFF4C9C9);
const Color _peach = Color(0xFFF6D9C4);
const Color _blue = Color(0xFFCFE0EE);
const Color _lavender = Color(0xFFDDD5EE);

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onBack,
  ValueChanged<CustomizationSegment>? onSegmentChange,
  ValueChanged<String>? onSelectAvatar,
  ValueChanged<String>? onSelectBackground,
  ValueChanged<CustomizationSelection>? onSaveChanges,
}) async {
  // Tall phone surface so the full-height layout fits without scrolling.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: CustomizationScreen(
        onBack: onBack,
        onSegmentChange: onSegmentChange,
        onSelectAvatar: onSelectAvatar,
        onSelectBackground: onSelectBackground,
        onSaveChanges: onSaveChanges,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// [BoxDecoration] of the [Container] found by [key].
BoxDecoration _decorationOf(WidgetTester tester, String key) {
  final container =
      tester.widget<Container>(find.byKey(Key(key), skipOffstage: false));
  expect(container.decoration, isA<BoxDecoration>(), reason: '$key card');
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('Customization matches the Figma 5:248 spec', (tester) async {
    await _pump(tester);

    // Cream page, scrollable full-height body, household tab bar, no inputs.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, _cream);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(HouseholdBottomNav), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(TextField), findsNothing);

    // Top Bar: 38px white round back button, 20px chevron, centered title.
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    final backIcon = tester.widget<Icon>(
      find.byIcon(Icons.chevron_left_rounded),
    );
    expect(backIcon.size, 20);
    expect(backIcon.color, _ink);
    final backButton = find.descendant(
      of: find.byKey(const Key('customization-back')),
      matching: find.byType(Container),
    );
    expect(tester.getSize(backButton), const Size(38, 38));
    final backDecoration =
        tester.widget<Container>(backButton).decoration! as BoxDecoration;
    expect(backDecoration.color, _white);
    expect(
      backDecoration.borderRadius,
      BorderRadius.circular(19),
    );
    expect(backDecoration.boxShadow, hasLength(1));
    expect(
      backDecoration.boxShadow!.first.color,
      const Color.fromRGBO(51, 64, 38, 0.08),
    );
    final title = _styleOf(tester, 'Customization');
    expect(title.fontFamily, 'Nunito');
    expect(title.fontWeight, FontWeight.w700);
    expect(title.fontSize, 18);
    expect(title.color, _ink);
    expect(
      tester.widget<Text>(find.text('Customization')).textAlign,
      TextAlign.center,
    );

    // Segmented control: sagelight track, For You selected.
    final track = _decorationOf(tester, 'customization-segments');
    expect(track.color, _sageLight);
    expect(track.borderRadius, BorderRadius.circular(16));
    expect(
      tester
          .widget<Container>(find.byKey(const Key('customization-segments')))
          .padding,
      const EdgeInsets.all(4),
    );
    Container segmentContainer(String label) {
      final containers = find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .evaluate()
          .toList()
        ..sort((a, b) => b.depth.compareTo(a.depth));
      return containers.first.widget as Container;
    }

    BoxDecoration segmentDecoration(String label) =>
        segmentContainer(label).decoration! as BoxDecoration;

    expect(
      segmentContainer('For You').padding,
      const EdgeInsets.symmetric(vertical: 8),
    );
    expect(
      segmentContainer('Settings').padding,
      const EdgeInsets.symmetric(vertical: 8),
    );
    expect(segmentDecoration('For You').color, _sage);
    expect(
      segmentDecoration('For You').borderRadius,
      BorderRadius.circular(12),
    );
    final forYou = _styleOf(tester, 'For You');
    expect(forYou.fontFamily, 'Nunito');
    expect(forYou.fontWeight, FontWeight.w700);
    expect(forYou.fontSize, 13);
    expect(forYou.color, _white);
    expect(segmentDecoration('Settings').color, Colors.transparent);
    final settings = _styleOf(tester, 'Settings');
    expect(settings.fontWeight, FontWeight.w700);
    expect(settings.fontSize, 13);
    expect(settings.color, _sageDark);
    // Equal widths, 8px vertical padding.
    final forYouBox = tester.getSize(find.ancestor(
      of: find.text('For You'),
      matching: find.byType(Container),
    ).first);
    final settingsBox = tester.getSize(find.ancestor(
      of: find.text('Settings'),
      matching: find.byType(Container),
    ).first);
    expect(forYouBox.width, settingsBox.width);

    // For You shows the profile card only; the background card
    // lives on the Settings tab.
    expect(
      find.byKey(const Key('customization-background-card')),
      findsNothing,
    );

    // Profile Card: white, radius 24, exact shadow, verbatim copy.
    final profile = _decorationOf(tester, 'customization-profile-card');
    expect(profile.color, _white);
    expect(profile.borderRadius, BorderRadius.circular(24));
    expect(
      profile.border,
      Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
      ),
    );
    expect(profile.boxShadow, hasLength(1));
    expect(
      profile.boxShadow!.first.color,
      const Color.fromRGBO(59, 77, 56, 0.09),
    );
    expect(profile.boxShadow!.first.offset, const Offset(0, 5));
    expect(profile.boxShadow!.first.blurRadius, 16);
    expect(profile.boxShadow!.first.spreadRadius, -4);
    final profileHeading = _styleOf(tester, 'Your Profile');
    expect(profileHeading.fontFamily, 'Nunito');
    expect(profileHeading.fontWeight, FontWeight.w800);
    expect(profileHeading.fontSize, 17);
    expect(profileHeading.color, _ink);
    final profileSubtitle = _styleOf(tester, 'Change your avatar and look!');
    expect(profileSubtitle.fontFamily, 'Nunito');
    expect(profileSubtitle.fontWeight, FontWeight.w500);
    expect(profileSubtitle.fontSize, 13);
    expect(profileSubtitle.color, _mute);

    // Crown above the main avatar; main avatar 112px pink, 4px sage border.
    expect(find.byType(CrownArt), findsOneWidget);
    expect(tester.getSize(find.byType(CrownArt)), const Size(46, 28));
    final mainAvatar = find.byKey(const Key('customization-main-avatar'));
    expect(tester.getSize(mainAvatar), const Size(112, 112));
    final mainDecoration =
        tester.widget<Container>(mainAvatar).decoration! as BoxDecoration;
    expect(mainDecoration.color, _pink);
    expect(mainDecoration.borderRadius, BorderRadius.circular(56));
    expect(mainDecoration.border, Border.all(color: _sage, width: 4));
    expect(
      tester.getTopLeft(find.byType(CrownArt)).dy,
      lessThan(tester.getTopLeft(mainAvatar).dy),
    );

    // Main avatar shows the cat; four options in design order.
    final art = tester
        .widgetList<AvatarArt>(find.byType(AvatarArt))
        .map((w) => w.avatarId)
        .toList();
    expect(art, ['cat', 'cat', 'fox', 'bunny', 'person']);
    const optionBackgrounds = {
      'cat': _pink,
      'fox': _peach,
      'bunny': _blue,
      'person': _lavender,
    };
    for (final entry in optionBackgrounds.entries) {
      final option = find.byKey(Key('avatar-option-${entry.key}'));
      expect(tester.getSize(option), const Size(50, 50),
          reason: '${entry.key} option size');
      final decoration =
          tester.widget<Container>(option).decoration! as BoxDecoration;
      expect(decoration.color, entry.value, reason: '${entry.key} color');
      expect(decoration.borderRadius, BorderRadius.circular(25));
      if (entry.key == 'cat') {
        expect(decoration.border, Border.all(color: _sage, width: 3));
      } else {
        expect(decoration.border, isNull, reason: '${entry.key} no border');
      }
    }

    // Settings tab owns the background card; the profile card hides.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('customization-profile-card')),
      findsNothing,
    );

    // Background Card: white, left-aligned, verbatim heading.
    final backgroundCard =
        _decorationOf(tester, 'customization-background-card');
    expect(backgroundCard.color, _white);
    expect(backgroundCard.borderRadius, BorderRadius.circular(24));
    final backgroundColumn = tester.widget<Column>(
      find
          .descendant(
            of: find.byKey(const Key('customization-background-card')),
            matching: find.byType(Column),
          )
          .first,
    );
    expect(backgroundColumn.crossAxisAlignment, CrossAxisAlignment.start);
    final backgroundHeading = _styleOf(tester, 'Your Background');
    expect(backgroundHeading.fontFamily, 'Nunito');
    expect(backgroundHeading.fontWeight, FontWeight.w700);
    expect(backgroundHeading.fontSize, 16);
    expect(backgroundHeading.color, _ink);

    // Four tiles: 72px tall, exact top->bottom gradients, meadow selected.
    const gradients = {
      'sky': [Color(0xFFCFE3F5), Color(0xFFF5E8D0)],
      'meadow': [Color(0xFFCDE5C0), Color(0xFFF2F0CC)],
      'sunset': [Color(0xFFF8D3B8), Color(0xFFF2B7C8)],
      'night': [Color(0xFF3C4572), Color(0xFF8E86C0)],
    };
    double? tileWidth;
    for (final entry in gradients.entries) {
      final tile = find.byKey(Key('background-tile-${entry.key}'));
      expect(tester.getSize(tile).height, 72, reason: '${entry.key} height');
      tileWidth ??= tester.getSize(tile).width;
      expect(tester.getSize(tile).width, tileWidth, reason: 'equal widths');
      final decoration =
          tester.widget<Container>(tile).decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(
        tester.widget<Container>(tile).padding,
        const EdgeInsets.all(6),
      );
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, entry.value);
      if (entry.key == 'meadow') {
        expect(decoration.border, Border.all(color: _sage, width: 3));
      } else {
        expect(decoration.border, isNull, reason: '${entry.key} no border');
      }
    }
    // One check badge, 20px sage circle with a 12px white check, top-right
    // of the meadow tile.
    expect(find.byIcon(Icons.check), findsOneWidget);
    final check = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(check.size, 12);
    expect(check.color, _white);
    final badge = find
        .ancestor(of: find.byIcon(Icons.check), matching: find.byType(Container))
        .evaluate()
        .toList()
      ..sort((a, b) => b.depth.compareTo(a.depth));
    expect(
      tester.getSize(
        find.byElementPredicate((e) => identical(e, badge.first)),
      ),
      const Size(20, 20),
    );
    final badgeDecoration =
        (badge.first.widget as Container).decoration! as BoxDecoration;
    expect(badgeDecoration.color, _sage);
    expect(badgeDecoration.borderRadius, BorderRadius.circular(10));
    final badgeCenter = tester.getCenter(find.byIcon(Icons.check));
    final meadowRect = tester.getRect(
      find.byKey(const Key('background-tile-meadow')),
    );
    expect(badgeCenter.dx, greaterThan(meadowRect.center.dx));
    expect(badgeCenter.dy, lessThan(meadowRect.center.dy));

    // Section order on the Settings tab, 12px gaps, 20px sides.
    double top(String key) =>
        tester.getTopLeft(find.byKey(Key(key))).dy;
    double bottom(String key) =>
        tester.getBottomLeft(find.byKey(Key(key))).dy;
    expect(top('customization-back'), 6);
    expect(top('customization-segments'), bottom('customization-back') + 12);
    expect(
      top('customization-background-card'),
      bottom('customization-segments') + 12,
    );
    final backgroundRect = tester.getRect(
      find.byKey(const Key('customization-background-card')),
    );
    expect(backgroundRect.left, 20);
    expect(backgroundRect.right, 390 - 20);
    // Back on For You: the profile card takes the same slot.
    await tester.tap(find.text('For You'));
    await tester.pumpAndSettle();
    expect(
      top('customization-profile-card'),
      bottom('customization-segments') + 12,
    );
    final profileRect = tester.getRect(
      find.byKey(const Key('customization-profile-card')),
    );
    expect(profileRect.left, 20);
    expect(profileRect.right, 390 - 20);
    // Spacer pins the button above the bottom nav: 30px body padding.
    final navTop = tester.getTopLeft(find.byType(HouseholdBottomNav)).dy;
    expect(bottom('customization-save'), navTop - 30);
    expect(top('customization-save'),
        greaterThan(bottom('customization-profile-card') + 12));

    // Save Changes: 54px sage button, exact shadow, ExtraBold 16 white.
    final save = find.byKey(const Key('customization-save'));
    expect(tester.getSize(save), const Size(350, 54));
    final saveDecoration =
        tester.widget<Container>(save).decoration! as BoxDecoration;
    expect(saveDecoration.borderRadius, BorderRadius.circular(18));
    expect(saveDecoration.boxShadow, hasLength(1));
    expect(
      saveDecoration.boxShadow!.first.color,
      const Color.fromRGBO(94, 128, 84, 0.3),
    );
    expect(saveDecoration.boxShadow!.first.offset, const Offset(0, 4));
    expect(saveDecoration.boxShadow!.first.blurRadius, 5);
    final saveButton = tester.widget<ElevatedButton>(
      find.descendant(of: save, matching: find.byType(ElevatedButton)),
    );
    expect(
      saveButton.style!.backgroundColor!.resolve({}),
      _sage,
    );
    final saveLabel = _styleOf(tester, 'Save Changes');
    expect(saveLabel.fontFamily, 'Nunito');
    expect(saveLabel.fontWeight, FontWeight.w800);
    expect(saveLabel.fontSize, 16);
    expect(saveLabel.color, _white);
  });

  testWidgets('segment, avatar, background, save, and back handlers',
      (tester) async {
    CustomizationSegment? segment;
    String? avatarId;
    String? backgroundId;
    CustomizationSelection? saved;
    var backCalls = 0;
    await _pump(
      tester,
      onBack: () => backCalls++,
      onSegmentChange: (s) => segment = s,
      onSelectAvatar: (id) => avatarId = id,
      onSelectBackground: (id) => backgroundId = id,
      onSaveChanges: (s) => saved = s,
    );

    // Segment switch moves the sage pill + white text.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(segment, CustomizationSegment.settings);
    expect(_styleOf(tester, 'Settings').color, _white);
    expect(_styleOf(tester, 'For You').color, _sageDark);
    await tester.tap(find.text('For You'));
    await tester.pumpAndSettle();
    expect(segment, CustomizationSegment.forYou);

    // Avatar switch updates the border AND the main avatar; crown stays.
    await tester.tap(find.byKey(const Key('avatar-option-fox')));
    await tester.pumpAndSettle();
    expect(avatarId, 'fox');
    final mainDecoration = tester
        .widget<Container>(
          find.byKey(const Key('customization-main-avatar')),
        )
        .decoration! as BoxDecoration;
    expect(mainDecoration.color, _peach);
    expect(mainDecoration.border, Border.all(color: _sage, width: 4));
    expect(
      tester.widget<AvatarArt>(find.byType(AvatarArt).first).avatarId,
      'fox',
    );
    expect(find.byType(CrownArt), findsOneWidget);
    BoxDecoration optionDecoration(String id) => tester
        .widget<Container>(find.byKey(Key('avatar-option-$id')))
        .decoration! as BoxDecoration;
    expect(optionDecoration('fox').border, Border.all(color: _sage, width: 3));
    expect(optionDecoration('cat').border, isNull);

    // Background switch moves the border + check badge (Settings tab).
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(segment, CustomizationSegment.settings);
    await tester.tap(find.byKey(const Key('background-tile-sunset')));
    await tester.pumpAndSettle();
    expect(backgroundId, 'sunset');
    BoxDecoration tileDecoration(String id) => tester
        .widget<Container>(find.byKey(Key('background-tile-$id')))
        .decoration! as BoxDecoration;
    expect(tileDecoration('sunset').border, Border.all(color: _sage, width: 3));
    expect(tileDecoration('meadow').border, isNull);
    expect(find.byIcon(Icons.check), findsOneWidget);
    final badgeCenter = tester.getCenter(find.byIcon(Icons.check));
    final sunsetRect = tester.getRect(
      find.byKey(const Key('background-tile-sunset')),
    );
    expect(sunsetRect.contains(badgeCenter), isTrue);

    // Save collects the current selections; back fires.
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(
      saved,
      const CustomizationSelection(
        segment: CustomizationSegment.settings,
        avatarId: 'fox',
        backgroundId: 'sunset',
      ),
    );
    await tester.tap(find.byKey(const Key('customization-back')));
    await tester.pumpAndSettle();
    expect(backCalls, 1);
  });
}
