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

  testWidgets('Get Started leads to the focus areas picker', (tester) async {
    await _pumpToWelcome(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(
      find.text('What would you like to use HomeSync for?'),
      findsOneWidget,
    );

    // Next stays disabled until at least one tag is picked.
    final next = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(next).onPressed, isNull);
    await tester.tap(find.text('Task rewards'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(next).onPressed, isNotNull);
  });

  testWidgets('Login button opens the login screen', (tester) async {
    await _pumpToWelcome(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Focus areas Next opens single-profile setup', (tester) async {
    await _pumpToWelcome(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chore distribution'));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(find.text('I am a…'), findsOneWidget);
  });
}
