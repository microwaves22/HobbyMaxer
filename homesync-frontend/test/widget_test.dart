import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/main.dart';

Future<void> _pumpToWelcome(WidgetTester tester) async {
  await tester.pumpWidget(const HomeSyncApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Welcome shows Get Started and Login', (tester) async {
    await _pumpToWelcome(tester);

    expect(find.text('Welcome to HomeSync'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Get Started'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Get Started leads straight to profile setup', (tester) async {
    await _pumpToWelcome(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Focus-area picker is shelved: signup starts at the profile form.
    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(find.text('I am a…'), findsOneWidget);
  });

  testWidgets('Login button opens the login screen', (tester) async {
    await _pumpToWelcome(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Signup enables all features by default', (tester) async {
    await _pumpToWelcome(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Mom');
    await tester.enterText(find.byType(TextField).at(1), '1990-01-01');
    await tester.enterText(find.byType(TextField).at(2), '4321');
    final cont = find.text('Continue');
    await tester.ensureVisible(cont);
    await tester.tap(cont);
    await tester.pumpAndSettle();

    expect(find.text('Hello, Mom!'), findsOneWidget);
    for (final area in [
      'Calendar coordination',
      'Chore distribution',
      'Task rewards',
      'Homework tracking',
    ]) {
      expect(find.text(area), findsOneWidget);
    }
  });
}
