import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/models/reward_management_data.dart';
import 'package:homesync/views/rewards/reward_management_screen.dart';

Future<void> _pumpManagement(
  WidgetTester tester, {
  RewardManagementScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const RewardManagementScreen()),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// The container rendering [color]: all of these fills are unique on
/// this screen, so the predicate identifies each part unambiguously.
Finder _containerWithColor(Color color) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == color,
    );

void main() {
  group('Sarah reward management (Figma 62:6235)', () {
    testWidgets('renders header, categories, and control banner',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Reward Management'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(
        find.text("Your family's rewards, on your terms."),
        findsOneWidget,
      );

      expect(find.text('Digital'), findsOneWidget);
      expect(find.text('Real-world'), findsOneWidget);
      expect(
        _styleOf(tester, 'Real-world').color,
        const Color(0xFF5F7F55),
      );

      expect(
        find.text('Managed by Sarah · Parent approval'),
        findsOneWidget,
      );
      expect(
        find.text(
          'You set the cost, who can redeem, and any conditions. '
          'All requests come to you.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the creation card with verbatim fields',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Create a custom perk'), findsOneWidget);
      expect(find.text('Privilege / title'), findsOneWidget);
      expect(
        find.text('Contribution toward a personal purchase'),
        findsOneWidget,
      );
      expect(find.text('Point cost'), findsOneWidget);
      expect(find.text('200 points'), findsOneWidget);
      expect(find.text('Eligible child'), findsOneWidget);
      expect(find.text('Noah · 14'), findsOneWidget);
      expect(find.text('Contribution amount'), findsOneWidget);
      expect(find.text('Enter an amount'), findsOneWidget);
      expect(
        find.text(
          'Parent-defined amount. No payment or commitment is created here.',
        ),
        findsOneWidget,
      );
      expect(find.text('Conditions · optional'), findsOneWidget);
      expect(
        find.text('Agree on the item together before redeeming.'),
        findsOneWidget,
      );
      expect(find.text('Add Perk'), findsOneWidget);
    });

    testWidgets('renders the 4 managed perks with a derived count',
        (tester) async {
      await _pumpManagement(tester);

      expect(find.text('Your real-world perks'), findsOneWidget);
      expect(find.text('4 perks'), findsOneWidget);

      expect(
        kRewardManagementData.perks.map((p) => p.name),
        [
          'Extended weekend curfew',
          'Choose Friday night dinner / takeout',
          'Pick the family movie',
          'Personal purchase contribution',
        ],
      );
      expect(find.text('+30 mins · Noah'), findsOneWidget);
      expect(find.text('Ava & Noah'), findsNWidgets(2));
      expect(
        find.text('Amount defined by parent · Noah'),
        findsOneWidget,
      );
      expect(find.text('★ 80'), findsOneWidget);
      expect(find.text('★ 120'), findsOneWidget);
      expect(find.text('★ 150'), findsOneWidget);
      expect(find.text('★ 200'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(4));
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('bottom nav has Family active', (tester) async {
      await _pumpManagement(tester);

      expect(
        _styleOf(tester, 'Family').color,
        const Color(0xFF5F7F55),
      );
      expect(
        _styleOf(tester, 'Tasks').color,
        const Color(0xFF7C877A),
      );
    });

    testWidgets('create and edit actions fire', (tester) async {
      PerkFormState? created;
      String? edited;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onCreatePerk: (form) => created = form,
          onEditPerk: (id) => edited = id,
        ),
      );

      await tester.ensureVisible(find.text('Add Perk'));
      await tester.tap(find.text('Add Perk'));
      await tester.pumpAndSettle();
      expect(
        created?.field1,
        'Contribution toward a personal purchase',
      );
      expect(created?.cost, '200 points');
      expect(created?.eligibility, 'Noah · 14');
      expect(created?.field2, isEmpty);
      expect(created?.field3, 'Agree on the item together before redeeming.');
      expect(created?.category, 'b');

      await tester.ensureVisible(find.text('Edit').first);
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();
      expect(edited, 'managed-perk-1');
    });

    testWidgets('matches the Figma measurements', (tester) async {
      await _pumpManagement(tester);

      // Header avatar: 42px peach circle with Sarah's initial.
      final avatar = _containerWithColor(const Color(0xFFF6D9C4));
      expect(avatar, findsOneWidget);
      expect(tester.getSize(avatar), const Size(42, 42));

      // Description is Medium 13.
      final description =
          _styleOf(tester, "Your family's rewards, on your terms.");
      expect(description.fontSize, 13);
      expect(description.fontWeight, FontWeight.w500);

      // Segmented control: #E9EAE3 track, Real-world selected in a
      // white segment with sage text.
      final track = _containerWithColor(const Color(0xFFE9EAE3));
      expect(track, findsOneWidget);
      final selectedSegment = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.child is Text &&
              (w.child! as Text).data == 'Real-world',
        ),
      );
      expect(
        (selectedSegment.decoration! as BoxDecoration).color,
        const Color(0xFFFFFFFF),
      );

      // Control banner: sageLight, radius 18, 13px padding.
      final banner = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color ==
                const Color(0xFFE4EBDC) &&
            (w.decoration! as BoxDecoration).borderRadius ==
                const BorderRadius.all(Radius.circular(18)),
      );
      expect(banner, findsOneWidget);
      final bannerWidget = tester.widget<Container>(banner);
      expect(bannerWidget.padding, const EdgeInsets.all(13));

      // Field labels: ExtraBold 11 mute.
      for (final label in [
        'Privilege / title',
        'Point cost',
        'Eligible child',
        'Contribution amount',
        'Conditions · optional',
      ]) {
        final style = _styleOf(tester, label);
        expect(style.fontSize, 11);
        expect(style.fontWeight, FontWeight.w800);
        expect(style.color, const Color(0xFF7C877A));
      }

      // Primary button: ExtraBold 14.
      final addPerk = _styleOf(tester, 'Add Perk');
      expect(addPerk.fontSize, 14);
      expect(addPerk.fontWeight, FontWeight.w800);

      // Perk tiles: 34×38 sageLight.
      final tiles = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color ==
                const Color(0xFFE4EBDC) &&
            (w.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(10),
      );
      expect(tiles, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(tester.getSize(tiles.at(i)), const Size(34, 38));
      }

      // Cost: ExtraBold 11 sage. Edit: Bold 10 mute.
      final cost = _styleOf(tester, '★ 80');
      expect(cost.fontSize, 11);
      expect(cost.fontWeight, FontWeight.w800);
      expect(cost.color, const Color(0xFF5F7F55));
      final edit = tester.widget<Text>(find.text('Edit').first).style!;
      expect(edit.fontSize, 10);
      expect(edit.fontWeight, FontWeight.w700);
      expect(edit.color, const Color(0xFF7C877A));
    });

    testWidgets('category selection calls back and flips the segments',
        (tester) async {
      String? selected;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onSelectCategory: (id) => selected = id,
        ),
      );

      await tester.tap(find.text('Digital'));
      await tester.pumpAndSettle();

      expect(selected, 'a');
      expect(_styleOf(tester, 'Digital').color, const Color(0xFF5F7F55));
    });

    testWidgets('eligibility field opens the selector', (tester) async {
      var calls = 0;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onOpenEligibilitySelect: () => calls++,
        ),
      );

      await tester.tap(find.text('Noah · 14'));
      expect(calls, 1);
    });

    testWidgets('Family nav tab calls back', (tester) async {
      var calls = 0;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onNavigateFamily: () => calls++,
        ),
      );

      await tester.tap(find.text('Family'));
      expect(calls, 1);
    });

    testWidgets('eligibility dropdown lists the active children',
        (tester) async {
      await _pumpManagement(tester);

      final dropdown = find.byType(DropdownButtonFormField<String>);
      expect(dropdown, findsOneWidget);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Both active profiles are offered; the current value stays put.
      expect(find.text('Ava · 8'), findsOneWidget);
      expect(find.text('Noah · 14'), findsNWidgets(2));
    });

    testWidgets('eligibility selection reaches the creation form',
        (tester) async {
      PerkFormState? created;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onCreatePerk: (form) => created = form,
        ),
      );

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ava · 8'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add Perk'));
      await tester.tap(find.text('Add Perk'));
      await tester.pumpAndSettle();
      expect(created?.eligibility, 'Ava · 8');
    });

    testWidgets('eligibility dropdown hides inactive children',
        (tester) async {
      const base = kRewardManagementData;
      final data = RewardManagementData(
        title: base.title,
        avatarLabel: base.avatarLabel,
        description: base.description,
        categoryA: base.categoryA,
        categoryB: base.categoryB,
        selectedCategoryId: base.selectedCategoryId,
        bannerTitle: base.bannerTitle,
        bannerBody: base.bannerBody,
        creationHeading: base.creationHeading,
        field1Label: base.field1Label,
        field1Value: base.field1Value,
        costLabel: base.costLabel,
        costValue: base.costValue,
        eligibilityLabel: base.eligibilityLabel,
        eligibilityValue: base.eligibilityValue,
        field2Label: base.field2Label,
        field2Value: base.field2Value,
        field2Placeholder: base.field2Placeholder,
        helperText: base.helperText,
        field3Label: base.field3Label,
        field3Value: base.field3Value,
        primaryActionLabel: base.primaryActionLabel,
        existingHeading: base.existingHeading,
        statusPillLabel: base.statusPillLabel,
        perks: base.perks,
        editLabel: base.editLabel,
        eligibleChildren: const [
          EligibleChild(id: 'ava', name: 'Ava', label: 'Ava · 8'),
          EligibleChild(id: 'noah', name: 'Noah', label: 'Noah · 14'),
          EligibleChild(
            id: 'mia',
            name: 'Mia',
            label: 'Mia · 10',
            active: false,
          ),
        ],
        navLabels: base.navLabels,
        activeNavId: base.activeNavId,
      );
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(data: data),
      );

      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('Ava · 8'), findsOneWidget);
      expect(find.text('Noah · 14'), findsNWidgets(2));
      expect(find.text('Mia · 10'), findsNothing);
    });

    testWidgets('edit opens a modal that updates the perk', (tester) async {
      ManagedPerk? saved;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onSavePerk: (perk) => saved = perk,
        ),
      );

      await tester.ensureVisible(find.text('Edit').first);
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('Edit perk'), findsOneWidget);
      expect(find.text('Perk type'), findsOneWidget);
      expect(find.text('Extra time'), findsOneWidget);
      expect(find.text('Assigned child'), findsOneWidget);
      expect(find.text('Point cost'), findsNWidgets(2));

      final modalFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(modalFields, findsNWidgets(3));
      await tester.enterText(modalFields.at(0), 'Late bedtime Friday');
      await tester.enterText(modalFields.at(1), '+45 mins');
      await tester.enterText(modalFields.at(2), '95');

      final modalDropdown = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(DropdownButtonFormField<String>),
      );
      await tester.tap(modalDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ava · 8'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit perk'), findsNothing);
      expect(find.text('Late bedtime Friday'), findsOneWidget);
      expect(find.text('+45 mins · Ava'), findsOneWidget);
      expect(find.text('★ 95'), findsOneWidget);
      expect(saved?.name, 'Late bedtime Friday');
      expect(saved?.detail, '+45 mins · Ava');
      expect(saved?.costLabel, '★ 95');
    });

    testWidgets('edit modal cancel changes nothing', (tester) async {
      var saves = 0;
      await _pumpManagement(
        tester,
        build: () => RewardManagementScreen(
          onSavePerk: (_) => saves++,
        ),
      );

      await tester.ensureVisible(find.text('Edit').first);
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      final modalFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(modalFields.at(0), 'Discarded');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit perk'), findsNothing);
      expect(find.text('Discarded'), findsNothing);
      expect(find.text('Extended weekend curfew'), findsOneWidget);
      expect(saves, 0);
    });

    testWidgets('edit modal save without changes is a no-op',
        (tester) async {
      await _pumpManagement(tester);

      // The 'Ava & Noah' row exercises the child-only detail path.
      await tester.ensureVisible(find.text('Edit').at(1));
      await tester.tap(find.text('Edit').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Friday night dinner / takeout'),
          findsOneWidget);
      expect(find.text('Ava & Noah'), findsNWidgets(2));
      expect(find.text('★ 120'), findsOneWidget);
    });
  });
}
