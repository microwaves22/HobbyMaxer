import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

UserProfile _parent() => UserProfile(
      name: 'Mom',
      birthday: DateTime(1990, 1, 1),
      role: FamilyRole.parent,
      mode: FamilyMode.parent,
    );

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(profile: _parent()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Parent To-Do section', () {
    testWidgets('shows seeded todos with the open count', (tester) async {
      await _pumpHome(tester);

      expect(find.text('Parent To-Do (1 open)'), findsOneWidget);
      expect(find.text('Pay electricity bill'), findsOneWidget);
      expect(find.text('Book dentist appointments'), findsOneWidget);
    });

    testWidgets('add flow appends a to-do', (tester) async {
      await _pumpHome(tester);

      final add = find.byIcon(Icons.add_rounded);
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Mow lawn');
      await tester.enterText(find.byType(TextField).at(1), 'Front yard');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Mow lawn'), findsOneWidget);
      expect(find.text('Parent To-Do (2 open)'), findsOneWidget);
    });

    testWidgets('checkbox toggles a to-do done and back', (tester) async {
      await _pumpHome(tester);

      final box = find.byType(Checkbox).first;
      await tester.ensureVisible(box);
      await tester.tap(box);
      await tester.pump();
      expect(find.text('Parent To-Do (0 open)'), findsOneWidget);

      await tester.tap(box);
      await tester.pump();
      expect(find.text('Parent To-Do (1 open)'), findsOneWidget);
    });

    testWidgets('edit and delete update the list', (tester) async {
      await _pumpHome(tester);

      final edit = find.byIcon(Icons.edit_outlined).first;
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Pay water bill');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Pay water bill'), findsOneWidget);

      final remove = find.byIcon(Icons.delete_outlined).first;
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pump();
      expect(find.text('Pay water bill'), findsNothing);
    });
  });
}
