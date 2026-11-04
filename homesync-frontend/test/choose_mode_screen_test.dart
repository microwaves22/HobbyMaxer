import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/account_mode.dart';
import 'package:homesync/views/onboarding/choose_mode_screen.dart';
import 'package:homesync/views/onboarding/family_setup_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

Future<void> _pumpChooseMode(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ChooseModeScreen()));
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// Border of the card containing [title].
BoxBorder? _cardBorder(WidgetTester tester, String title) {
  final textFinder = find.text(title);
  final containerFinder = find.ancestor(
    of: textFinder,
    matching: find.byType(Container),
  );
  final containers = tester.widgetList<Container>(containerFinder);
  for (final container in containers) {
    final decoration = container.decoration;
    if (decoration is BoxDecoration && decoration.border is Border) {
      return decoration.border;
    }
  }
  return null;
}

void main() {
  testWidgets('Choose Mode matches the Figma 02 spec', (tester) async {
    await _pumpChooseMode(tester);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF9F8F6));

    // Intro: exact copy, Nunito, sizes, weights, colors, centered.
    final heading = _styleOf(tester, 'Welcome to HomeSync!');
    expect(heading.fontFamily, 'Nunito');
    expect(heading.fontSize, 28);
    expect(heading.fontWeight, FontWeight.w800);
    expect(heading.color, const Color(0xFF2B3A2B));
    expect(
      tester.widget<Text>(find.text('Welcome to HomeSync!')).textAlign,
      TextAlign.center,
    );
    final subtitle = _styleOf(
      tester,
      'Choose the account type that fits your family role.',
    );
    expect(subtitle.fontFamily, 'Nunito');
    expect(subtitle.fontSize, 15);
    expect(subtitle.fontWeight, FontWeight.w500);
    expect(subtitle.color, const Color(0xFF7C877A));

    // Exactly three mode cards with verbatim titles and descriptions.
    for (final title in ['Parent Mode', 'Teen Mode', 'Kids Mode']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(
      find.text(
        'Administrative controls, task management, and family data at a glance.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A mature, simplified view for independence and responsibility.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Playful rewards, animal friends, and gentle chore encouragement.',
      ),
      findsOneWidget,
    );

    // Card titles: Nunito ExtraBold 17px ink.
    final cardTitle = _styleOf(tester, 'Teen Mode');
    expect(cardTitle.fontFamily, 'Nunito');
    expect(cardTitle.fontSize, 17);
    expect(cardTitle.fontWeight, FontWeight.w800);
    expect(cardTitle.color, const Color(0xFF2B3A2B));

    // Parent Mode starts selected: 2px sage border + "Selected" pill;
    // the other cards have 1px line borders and no pill.
    expect(find.text('Selected'), findsOneWidget);
    final parentBorder = _cardBorder(tester, 'Parent Mode')! as Border;
    expect(parentBorder.top.width, 2);
    expect(parentBorder.top.color, const Color(0xFF7A9A85));
    for (final title in ['Teen Mode', 'Kids Mode']) {
      final border = _cardBorder(tester, title)! as Border;
      expect(border.top.width, 1);
      expect(border.top.color, const Color(0xFFE8E4D8));
    }

    // Continue button: exact label and Nunito ExtraBold 16px white.
    expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    final buttonLabel = _styleOf(tester, 'Continue');
    expect(buttonLabel.fontFamily, 'Nunito');
    expect(buttonLabel.fontSize, 16);
    expect(buttonLabel.fontWeight, FontWeight.w800);
  });

  testWidgets('Tapping a card moves the selection to it', (tester) async {
    await _pumpChooseMode(tester);

    await tester.tap(find.text('Kids Mode'));
    await tester.pumpAndSettle();

    // Pill moved with the selection; exactly one pill exists.
    expect(find.text('Selected'), findsOneWidget);
    final kidsBorder = _cardBorder(tester, 'Kids Mode')! as Border;
    expect(kidsBorder.top.width, 2);
    expect(kidsBorder.top.color, const Color(0xFF7A9A85));
    final parentBorder = _cardBorder(tester, 'Parent Mode')! as Border;
    expect(parentBorder.top.width, 1);
    expect(parentBorder.top.color, const Color(0xFFE8E4D8));

    // Continue advances to family setup.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilySetupScreen), findsOneWidget);
  });

  testWidgets('Continue persists the mode centrally', (tester) async {
    final controller = AccountModeController();
    await tester.pumpWidget(
      MaterialApp(
        home: AccountModeScope(
          controller: controller,
          child: const ChooseModeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Teen Mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(controller.hasSelection, isTrue);
    expect(controller.role, FamilyRole.child);
    expect(controller.mode, FamilyMode.teen);
    expect(find.byType(FamilySetupScreen), findsOneWidget);
  });
}
