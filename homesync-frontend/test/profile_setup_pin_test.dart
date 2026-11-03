import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/onboarding/profile_setup_screen.dart';

Future<void> _pumpSetup(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProfileSetupScreen()));
  await tester.pumpAndSettle();
}

Future<void> _fillBasics(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'Mom');
  await tester.enterText(find.byType(TextField).at(1), '1990-01-01');
}

Future<void> _tapContinue(WidgetTester tester) async {
  final cont = find.text('Continue');
  await tester.ensureVisible(cont);
  await tester.tap(cont);
}

void main() {
  group('Parent PIN setup', () {
    testWidgets('parent must set a 4-digit PIN', (tester) async {
      await _pumpSetup(tester);
      expect(find.text('Parent PIN'), findsOneWidget);

      await _fillBasics(tester);
      await _tapContinue(tester);
      await tester.pump();
      expect(find.text('Set a 4-digit Parent PIN.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(2), '12');
      await _tapContinue(tester);
      await tester.pump();
      expect(find.text('Set a 4-digit Parent PIN.'), findsOneWidget);
    });

    testWidgets('valid PIN completes signup into the dashboard',
        (tester) async {
      await _pumpSetup(tester);

      await _fillBasics(tester);
      await tester.enterText(find.byType(TextField).at(2), '4321');
      await _tapContinue(tester);
      await tester.pumpAndSettle();

      expect(find.text('Hello, Mom!'), findsOneWidget);
    });

    testWidgets('child role hides the PIN field', (tester) async {
      await _pumpSetup(tester);

      await tester.tap(find.text('Child'));
      await tester.pump();

      expect(find.text('Parent PIN'), findsNothing);
    });
  });
}
