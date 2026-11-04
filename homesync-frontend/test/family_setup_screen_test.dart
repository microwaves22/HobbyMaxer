import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/family_setup_screen.dart';
import 'package:homesync/views/onboarding/member_detail_screen.dart';
import 'package:homesync/views/onboarding/focus_areas_screen.dart';
import 'package:homesync/views/onboarding/profile_setup_screen.dart';

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

Finder _nameField() => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Enter name',
    );

/// Adds one member through the form with the given [name] (defaults kept).
Future<void> _addMember(WidgetTester tester, String name) async {
  await tester.enterText(_nameField(), name);
  await tester.pump();
  await tester.ensureVisible(find.text('Add Member'));
  await tester.tap(find.text('Add Member'));
  await tester.pumpAndSettle();
}

/// Opens the role/account-role dropdown (the second dropdown on both the
/// setup and edit screens) and picks [option].
Future<void> _pickDropdownOption(
  WidgetTester tester,
  int dropdownIndex,
  String option,
) async {
  await tester.ensureVisible(
    find.byType(DropdownButtonFormField<String>).at(dropdownIndex),
  );
  await tester.tap(
    find.byType(DropdownButtonFormField<String>).at(dropdownIndex),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('new users start with a clean slate', (tester) async {
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

    // No pre-populated members: empty-state hint instead of cards.
    expect(
      find.text('No members yet. Add your first member below.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    expect(find.text('Kids Mode'), findsNothing);
    expect(find.text('Teen Mode'), findsNothing);

    // Form labels.
    for (final label in ['Name', 'Age', 'Gender', 'Role', 'Profile picture']) {
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

    // Gender and Role are real selects with defaults.
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Kids'), findsOneWidget);
    final dropdowns = tester
        .widgetList<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .toList();
    expect(dropdowns, hasLength(2));
    for (final dropdown in dropdowns) {
      expect(dropdown.decoration.errorText, isNull);
      expect(dropdown.decoration.helperText, isNull);
    }

    // Optional photo row.
    expect(find.text('Choose a photo (optional)'), findsOneWidget);

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

    await _addMember(tester, 'Liam');

    // New card appears with the entered name and default Kids role.
    expect(find.text('Liam'), findsOneWidget);
    expect(find.text('Kids · Age 12'), findsOneWidget);
    expect(
      find.text('No members yet. Add your first member below.'),
      findsNothing,
    );

    // Member card shape: white, radius 22, specified shadow.
    final card = _nearestDecoration(tester, 'Liam');
    expect(card.color, const Color(0xFFFFFFFF));
    expect(
      card.borderRadius,
      BorderRadius.circular(22),
    );
    expect(card.boxShadow, hasLength(1));
    expect(card.boxShadow!.single.blurRadius, 16);

    // Kids role shows the Kids Mode pill.
    expect(find.text('Kids Mode'), findsOneWidget);
    final kidsPill = _styleOf(tester, 'Kids Mode');
    expect(kidsPill.fontSize, 11);
    expect(kidsPill.fontWeight, FontWeight.w700);
    expect(kidsPill.color, const Color(0xFF2B3A2B));
    expect(
      _nearestDecoration(tester, 'Kids Mode').color,
      const Color(0xFFFDF0C8),
    );

    // A second member can be added; both cards stay.
    await _addMember(tester, 'Mia');
    expect(find.text('Liam'), findsOneWidget);
    expect(find.text('Mia'), findsOneWidget);

    // Done / Later goes straight to profile setup (focus picker shelved).
    await tester.ensureVisible(find.text('Done / Later'));
    await tester.tap(find.text('Done / Later'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.byType(FocusAreasScreen), findsNothing);
  });

  testWidgets('role trailing matches Kids, Teen, and Parent', (tester) async {
    await _pumpFamilySetup(tester);

    // Teen member shows the Teen Mode pill.
    await tester.enterText(_nameField(), 'Noah');
    await tester.pump();
    await _pickDropdownOption(tester, 1, 'Teen');
    await tester.ensureVisible(find.text('Add Member'));
    await tester.tap(find.text('Add Member'));
    await tester.pumpAndSettle();
    expect(find.text('Teen · Age 12'), findsOneWidget);
    expect(find.text('Teen Mode'), findsOneWidget);
    expect(
      _nearestDecoration(tester, 'Teen Mode').color,
      const Color(0xFFDDD5EE),
    );

    // Parent member shows a chevron and a bare "Parent" detail.
    await tester.enterText(_nameField(), 'Sarah');
    await tester.pump();
    await _pickDropdownOption(tester, 1, 'Parent');
    await tester.ensureVisible(find.text('Add Member'));
    await tester.tap(find.text('Add Member'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('tapping a member opens the editor with every field',
      (tester) async {
    await _pumpFamilySetup(tester);
    await _addMember(tester, 'Liam');

    await tester.ensureVisible(find.text('Liam'));
    await tester.tap(find.text('Liam'));
    await tester.pumpAndSettle();

    final detailScreen = find.byType(MemberDetailScreen);
    expect(detailScreen, findsOneWidget);

    // Every editable field is present and prefilled.
    final nameField = tester.widget<TextField>(
      find.descendant(of: detailScreen, matching: _nameField()),
    );
    expect(nameField.controller?.text, 'Liam');
    final ageField = tester.widget<TextField>(
      find.descendant(
        of: detailScreen,
        matching: find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.hintText == null,
        ),
      ),
    );
    expect(ageField.controller?.text, '12');
    expect(ageField.keyboardType, TextInputType.number);
    expect(
      find.descendant(of: detailScreen, matching: find.text('Gender')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailScreen, matching: find.text('Account Role')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailScreen, matching: find.text('Change photo')),
      findsOneWidget,
    );

    // Save and Delete actions.
    expect(
      find.descendant(
        of: detailScreen,
        matching: find.widgetWithText(ElevatedButton, 'Save Changes'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detailScreen,
        matching: find.widgetWithText(OutlinedButton, 'Delete Member'),
      ),
      findsOneWidget,
    );

    // Back returns with state kept and no toast.
    await tester.tap(find.byKey(const Key('member-detail-back')));
    await tester.pumpAndSettle();
    expect(find.byType(MemberDetailScreen), findsNothing);
    expect(find.byType(FamilySetupScreen), findsOneWidget);
    expect(find.text('Liam'), findsOneWidget);
    expect(find.text('Member updated'), findsNothing);
  });

  testWidgets('editing a member updates the card', (tester) async {
    await _pumpFamilySetup(tester);
    await _addMember(tester, 'Liam');

    await tester.ensureVisible(find.text('Liam'));
    await tester.tap(find.text('Liam'));
    await tester.pumpAndSettle();

    await tester.enterText(_nameField(), 'Liam Jr');
    await tester.pump();
    await _pickDropdownOption(tester, 1, 'Parent');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Editor closed; card shows the new name and Parent detail.
    expect(find.byType(MemberDetailScreen), findsNothing);
    expect(find.text('Liam Jr'), findsOneWidget);
    expect(find.text('Liam'), findsNothing);
    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Member updated'), findsOneWidget);
  });

  testWidgets('deleting a member removes the card', (tester) async {
    await _pumpFamilySetup(tester);
    await _addMember(tester, 'Liam');

    await tester.ensureVisible(find.text('Liam'));
    await tester.tap(find.text('Liam'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete Member'));
    await tester.tap(find.text('Delete Member'));
    await tester.pumpAndSettle();
    expect(find.text('Delete member?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Editor closed; empty state is back with a confirmation toast.
    expect(find.byType(MemberDetailScreen), findsNothing);
    expect(find.text('Liam'), findsNothing);
    expect(
      find.text('No members yet. Add your first member below.'),
      findsOneWidget,
    );
    expect(find.text('Member deleted'), findsOneWidget);
  });

  testWidgets('delete can be cancelled', (tester) async {
    await _pumpFamilySetup(tester);
    await _addMember(tester, 'Liam');

    await tester.ensureVisible(find.text('Liam'));
    await tester.tap(find.text('Liam'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete Member'));
    await tester.tap(find.text('Delete Member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Still editing; member kept.
    expect(find.byType(MemberDetailScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('member-detail-back')));
    await tester.pumpAndSettle();
    expect(find.text('Liam'), findsOneWidget);
    expect(find.text('Member deleted'), findsNothing);
  });

  testWidgets('photo picker degrades gracefully without the plugin',
      (tester) async {
    // Simulate the missing native plugin: without a mock the channel
    // call never settles in widget tests, so throw explicitly like a
    // device with no camera/gallery support would.
    const channel = MethodChannel('plugins.flutter.io/image_picker');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => throw MissingPluginException('No implementation found'),
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await _pumpFamilySetup(tester);

    await tester.ensureVisible(find.byKey(const Key('add-member-photo')));
    await tester.tap(find.byKey(const Key('add-member-photo')));
    await tester.pumpAndSettle();
    expect(find.text('Profile picture'), findsOneWidget);

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not open camera/gallery.'),
      findsOneWidget,
    );
  });
}
