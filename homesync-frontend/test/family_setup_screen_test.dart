import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/family_setup_screen.dart';
import 'package:homesync/views/onboarding/focus_areas_screen.dart';

Future<void> _pumpFamilySetup(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: FamilySetupScreen()));
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// [BoxDecoration] of the nearest ancestor [Container] of [text].
///
/// Ancestors are ordered by tree depth, so this does not depend on the
/// order `find.ancestor` yields elements in.
BoxDecoration _nearestDecoration(WidgetTester tester, String text) {
  final elements = find
      .ancestor(of: find.text(text), matching: find.byType(Container))
      .evaluate()
      .toList()
    ..sort((a, b) => b.depth.compareTo(a.depth));
  final container = elements.first.widget as Container;
  final decoration = container.decoration;
  expect(decoration, isA<BoxDecoration>(), reason: '$text sits in a card');
  return decoration! as BoxDecoration;
}

void main() {
  testWidgets('Family Setup matches the Figma 03 spec', (tester) async {
    await _pumpFamilySetup(tester);

    expect(find.byType(SingleChildScrollView), findsOneWidget);

    // Solid cream background, edge to edge (Scaffold paints it all).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));

    // Header: exact copy, Nunito, sizes, weights, colors, left-aligned.
    final title = _styleOf(tester, 'Set Up Your Family');
    expect(title.fontFamily, 'Nunito');
    expect(title.fontSize, 28);
    expect(title.fontWeight, FontWeight.w800);
    expect(title.color, const Color(0xFF2B3A2B));
    final subtitle = _styleOf(tester, 'Add your family members to get started.');
    expect(subtitle.fontFamily, 'Nunito');
    expect(subtitle.fontSize, 15);
    expect(subtitle.fontWeight, FontWeight.w500);
    expect(subtitle.color, const Color(0xFF7C877A));

    // Section labels.
    for (final label in ['Existing members', 'Add member']) {
      final style = _styleOf(tester, label);
      expect(style.fontFamily, 'Nunito');
      expect(style.fontSize, 13);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, const Color(0xFF7C877A));
    }

    // Exactly three members with verbatim names and details.
    for (final name in ['Sarah', 'Ava', 'Noah']) {
      expect(find.text(name), findsOneWidget);
      final style = _styleOf(tester, name);
      expect(style.fontFamily, 'Nunito');
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, const Color(0xFF2B3A2B));
    }
    for (final detail in [
      'Mom · Parent',
      'Child · Age 8',
      'Child · Age 14',
    ]) {
      expect(find.text(detail), findsOneWidget);
      final style = _styleOf(tester, detail);
      expect(style.fontFamily, 'Nunito');
      expect(style.fontSize, 13);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.color, const Color(0xFF7C877A));
    }

    // Avatar glyphs at 31px.
    for (final glyph in ['👩', '👧', '👦']) {
      expect(find.text(glyph), findsOneWidget);
      final style = _styleOf(tester, glyph);
      expect(style.fontSize, 31);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.color, const Color(0xFF2B3A2B));
    }

    // Sarah ends with a chevron and no pill; Ava/Noah have mode pills.
    expect(
      find.byIcon(Icons.chevron_right_rounded),
      findsOneWidget,
    );
    expect(find.text('Kids Mode'), findsOneWidget);
    expect(find.text('Teen Mode'), findsOneWidget);
    final kidsPill = _styleOf(tester, 'Kids Mode');
    expect(kidsPill.fontSize, 11);
    expect(kidsPill.fontWeight, FontWeight.w700);
    expect(kidsPill.color, const Color(0xFF2B3A2B));
    expect(
      _nearestDecoration(tester, 'Kids Mode').color,
      const Color(0xFFFDF0C8),
    );
    expect(
      _nearestDecoration(tester, 'Teen Mode').color,
      const Color(0xFFDDD5EE),
    );

    // Member card shape: white, radius 22, specified shadow.
    final card = _nearestDecoration(tester, 'Sarah');
    expect(card.color, const Color(0xFFFFFFFF));
    expect(
      card.borderRadius,
      BorderRadius.circular(22),
    );
    expect(card.boxShadow, hasLength(1));
    expect(card.boxShadow!.single.blurRadius, 16);

    // Form labels.
    for (final label in ['Name', 'Age', 'Role']) {
      expect(find.text(label), findsOneWidget);
      final style = _styleOf(tester, label);
      expect(style.fontFamily, 'Nunito');
      expect(style.fontSize, 12);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, const Color(0xFF7C877A));
    }

    // Name is a real input with the placeholder; Age starts at "12".
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(2));
    final nameField =
        fields.firstWhere((f) => f.decoration?.hintText == 'Enter name');
    final nameDecoration = nameField.decoration!;
    expect(nameField.controller?.text ?? '', isEmpty);
    expect(nameDecoration.hintText, 'Enter name');
    expect(nameDecoration.errorText, isNull);
    expect(nameDecoration.helperText, isNull);
    expect(nameField.style?.fontSize, 16);
    expect(nameField.style?.fontWeight, FontWeight.w600);
    expect(nameField.style?.color, const Color(0xFF2B3A2B));

    final ageField =
        fields.firstWhere((f) => (f.controller?.text ?? '') == '12');
    expect(ageField.controller?.text, '12');
    expect(ageField.keyboardType, TextInputType.number);
    final ageDecoration = ageField.decoration!;
    expect(ageDecoration.errorText, isNull);
    expect(ageDecoration.helperText, isNull);

    // Role is a real select showing "Child".
    expect(find.text('Child'), findsOneWidget);
    final roleField = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    final roleState = tester.state<FormFieldState<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(roleState.value, 'Child');
    expect(roleField.decoration.errorText, isNull);
    expect(roleField.decoration.helperText, isNull);

    // Buttons: exact labels and styles.
    expect(find.widgetWithText(ElevatedButton, 'Add Member'), findsOneWidget);
    final primary = _styleOf(tester, 'Add Member');
    expect(primary.fontFamily, 'Nunito');
    expect(primary.fontSize, 16);
    expect(primary.fontWeight, FontWeight.w800);
    expect(
      find.widgetWithText(OutlinedButton, 'Done / Later'),
      findsOneWidget,
    );
    final secondary = _styleOf(tester, 'Done / Later');
    expect(secondary.fontFamily, 'Nunito');
    expect(secondary.fontSize, 16);
    expect(secondary.fontWeight, FontWeight.w800);
  });

  testWidgets('Add Member appends the entered member locally', (tester) async {
    await _pumpFamilySetup(tester);

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Enter name',
      ),
      'Liam',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Add Member'));
    await tester.tap(find.text('Add Member'));
    await tester.pumpAndSettle();

    // New card appears with the entered name; existing cards stay.
    expect(find.text('Liam'), findsOneWidget);
    expect(find.text('Child · Age 12'), findsOneWidget);
    for (final name in ['Sarah', 'Ava', 'Noah']) {
      expect(find.text(name), findsOneWidget);
    }

    // Member taps are safe no-ops: still on this screen.
    await tester.tap(find.text('Sarah'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilySetupScreen), findsOneWidget);

    // Done / Later continues to the existing focus areas flow.
    await tester.ensureVisible(find.text('Done / Later'));
    await tester.tap(find.text('Done / Later'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusAreasScreen), findsOneWidget);
  });
}
