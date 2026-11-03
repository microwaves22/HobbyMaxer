import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/link_kids_screen.dart';

Future<void> _pumpLinkKids(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: LinkKidsScreen()));
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// Ancestor [Container]s of [text], ordered nearest first by tree depth.
///
/// Depth ordering keeps this independent of the order `find.ancestor`
/// yields elements in.
List<Container> _ancestorContainers(WidgetTester tester, String text) {
  final elements = find
      .ancestor(of: find.text(text), matching: find.byType(Container))
      .evaluate()
      .toList()
    ..sort((a, b) => b.depth.compareTo(a.depth));
  return [for (final element in elements) element.widget as Container];
}

/// [BoxDecoration] of the nearest ancestor [Container] of [text].
BoxDecoration _nearestDecoration(WidgetTester tester, String text) {
  final decoration = _ancestorContainers(tester, text).first.decoration;
  expect(decoration, isA<BoxDecoration>(), reason: '$text sits in a card');
  return decoration! as BoxDecoration;
}

/// Size of the nearest ancestor [Container] of [text].
Size _nearestContainerSize(WidgetTester tester, String text) {
  final elements = find
      .ancestor(of: find.text(text), matching: find.byType(Container))
      .evaluate()
      .toList()
    ..sort((a, b) => b.depth.compareTo(a.depth));
  final target = elements.first;
  return tester.getSize(find.byElementPredicate((e) => identical(e, target)));
}

/// First ancestor card of [text] painted with [color] (order-free search).
BoxDecoration _cardPainted(
  WidgetTester tester,
  String text,
  Color color,
) {
  for (final container in _ancestorContainers(tester, text)) {
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.color == color) {
      return decoration;
    }
  }
  fail('no ancestor card of "$text" is painted $color');
}

void main() {
  testWidgets('Link Kids matches the Figma 30:249 spec', (tester) async {
    await _pumpLinkKids(tester);

    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));

    // Back row: 18px chevron + sage label.
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    final backIcon = tester.widget<Icon>(find.byIcon(
      Icons.chevron_left_rounded,
    ));
    expect(backIcon.size, 18);
    expect(backIcon.color, const Color(0xFF5F7F55));
    final backLabel = _styleOf(tester, 'Manage Family');
    expect(backLabel.fontFamily, 'Nunito');
    expect(backLabel.fontSize, 14);
    expect(backLabel.fontWeight, FontWeight.w700);
    expect(backLabel.color, const Color(0xFF5F7F55));

    // Introduction: exact copy, sizes, line heights, colors.
    final title = _styleOf(tester, 'Link your kids');
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 28);
    expect(title.height, 34 / 28);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    final description = _styleOf(
      tester,
      'Bring their accounts into your family circle with one simple code.',
    );
    expect(description.fontFamily, 'Nunito');
    expect(description.fontSize, 14);
    expect(description.height, 19 / 14);
    expect(description.fontWeight, FontWeight.w500);
    expect(description.color, const Color(0xFF7C877A));

    // Invite card: translucent sageLight, radius 22, specified shadow.
    final inviteCard = _cardPainted(
      tester,
      familyInviteCode,
      const Color(0xA8E4EBDC),
    );
    expect(inviteCard.borderRadius, BorderRadius.circular(22));
    expect(inviteCard.boxShadow, hasLength(1));
    expect(inviteCard.boxShadow!.single.blurRadius, 16);

    // Circle label lines.
    expect(find.text('Your family circle'), findsOneWidget);
    expect(find.text('FAMILY INVITE CODE'), findsOneWidget);

    // Code: exact string, 35px, 4px letter-spacing, sageDark.
    expect(familyInviteCode, 'H7K 2M9');
    expect(find.text('H7K 2M9'), findsOneWidget);
    final code = _styleOf(tester, 'H7K 2M9');
    expect(code.fontFamily, 'Nunito');
    expect(code.fontSize, 35);
    expect(code.letterSpacing, 4);
    expect(code.fontWeight, FontWeight.w800);
    expect(code.color, const Color(0xFF4A6A41));

    // Copy action: 44x49 glass box with icon + 10px label.
    final copyDecoration = _nearestDecoration(tester, 'Copy');
    expect(copyDecoration.color, const Color(0x5CFFFFFF));
    expect(copyDecoration.borderRadius, BorderRadius.circular(12));
    expect(_nearestContainerSize(tester, 'Copy'), const Size(44, 49));
    expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    final copyLabel = _styleOf(tester, 'Copy');
    expect(copyLabel.fontSize, 10);
    expect(copyLabel.fontWeight, FontWeight.w800);
    expect(copyLabel.color, const Color(0xFF4A6A41));

    // Share button sits inside the invite card.
    expect(
      find.widgetWithText(ElevatedButton, 'Share invite code'),
      findsOneWidget,
    );
    final shareAncestors = tester.widgetList<Container>(
      find.ancestor(
        of: find.widgetWithText(ElevatedButton, 'Share invite code'),
        matching: find.byType(Container),
      ),
    );
    expect(
      shareAncestors.any((c) =>
          c.decoration is BoxDecoration &&
          (c.decoration! as BoxDecoration).color ==
              const Color(0xA8E4EBDC)),
      isTrue,
      reason: 'Share button is inside the invite card',
    );
    final shareLabel = _styleOf(tester, 'Share invite code');
    expect(shareLabel.fontFamily, 'Nunito');
    expect(shareLabel.fontSize, 16);
    expect(shareLabel.fontWeight, FontWeight.w800);

    // Reassurance line: centered, 11px sageDark.
    final reassurance = _styleOf(
      tester,
      'Use this code for each child you want to link.',
    );
    expect(reassurance.fontSize, 11);
    expect(reassurance.fontWeight, FontWeight.w600);
    expect(reassurance.height, 15 / 11);
    expect(reassurance.color, const Color(0xFF4A6A41));
    expect(
      tester
          .widget<Text>(
            find.text('Use this code for each child you want to link.'),
          )
          .textAlign,
      TextAlign.center,
    );

    // Instructions card: translucent white with verbatim steps.
    final instructionsCard = _cardPainted(
      tester,
      'On your child’s device',
      const Color(0x5CFFFFFF),
    );
    expect(instructionsCard.borderRadius, BorderRadius.circular(22));
    for (final step in [
      'Open HomeSync and sign in to their account.',
      'Go to Settings → Join a family circle.',
      'Enter the code above and tap Join.',
    ]) {
      expect(find.text(step), findsOneWidget);
      final style = _styleOf(tester, step);
      expect(style.fontFamily, 'Nunito');
      expect(style.fontSize, 13);
      expect(style.height, 18 / 13);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, const Color(0xFF2B3A2B));
    }
    for (final number in ['1', '2', '3']) {
      expect(find.text(number), findsOneWidget);
      final style = _styleOf(tester, number);
      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w800);
      expect(style.color, const Color(0xFF4A6A41));
    }

    // Kids heading row.
    final kidsHeading = _styleOf(tester, 'Your kids');
    expect(kidsHeading.fontSize, 17);
    expect(kidsHeading.fontWeight, FontWeight.w800);
    expect(kidsHeading.color, const Color(0xFF2B3A2B));
    final kidsCount = _styleOf(tester, '1 of 2 linked');
    expect(kidsCount.fontSize, 12);
    expect(kidsCount.fontWeight, FontWeight.w700);
    expect(kidsCount.color, const Color(0xFF5F7F55));

    // Ava: pink avatar, verbatim detail, Linked pill with check icon.
    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Age 8 · Kids Mode'), findsOneWidget);
    expect(find.text('Linked'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    final linkedPill = _nearestDecoration(tester, 'Linked');
    expect(linkedPill.color, const Color(0xFFE4EBDC));
    expect(linkedPill.borderRadius, BorderRadius.circular(10));

    // Noah: blue avatar, verbatim detail, Not linked pill without icon.
    expect(find.text('Noah'), findsOneWidget);
    expect(find.text('Age 14 · Teen Mode'), findsOneWidget);
    expect(find.text('Not linked'), findsOneWidget);
    final notLinkedPill = _nearestDecoration(tester, 'Not linked');
    expect(notLinkedPill.color, const Color(0xFFFDF0C8));
    expect(notLinkedPill.borderRadius, BorderRadius.circular(10));

    // One 1px line divider separates the rows inside the status card.
    final dividers = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.color == const Color(0xFFE8E4D8))
        .toList();
    expect(dividers, hasLength(1));

    // Privacy note: centered shield icon + 11px mute text.
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
    final privacyIcon = tester.widget<Icon>(
      find.byIcon(Icons.verified_user_outlined),
    );
    expect(privacyIcon.size, 14);
    final privacy = _styleOf(tester, 'Only share this code with your family.');
    expect(privacy.fontFamily, 'Nunito');
    expect(privacy.fontSize, 11);
    expect(privacy.fontWeight, FontWeight.w600);
    expect(privacy.color, const Color(0xFF7C877A));

    // This screen shares a code: no input field, no extra buttons.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Back, copy, and share taps are safe', (tester) async {
    await _pumpLinkKids(tester);

    // Copy is a no-op placeholder: no crash, label unchanged.
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('H7K 2M9'), findsOneWidget);

    // Share is a no-op placeholder: no route is pushed.
    await tester.ensureVisible(find.text('Share invite code'));
    await tester.tap(find.text('Share invite code'));
    await tester.pumpAndSettle();
    expect(find.byType(LinkKidsScreen), findsOneWidget);

    // Back with a single route pops nothing: still on this screen.
    await tester.tap(find.text('Manage Family'));
    await tester.pumpAndSettle();
    expect(find.byType(LinkKidsScreen), findsOneWidget);
  });
}
