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
  group('AppBar home title', () {
    testWidgets('tapping Tasks title returns to the dashboard',
        (tester) async {
      await _pumpHome(tester);

      final chores = find.text('Chore distribution');
      await tester.ensureVisible(chores);
      await tester.tap(chores);
      await tester.pumpAndSettle();
      expect(find.text('Tasks'), findsOneWidget);

      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Mom!'), findsOneWidget);
    });

    testWidgets('tapping Reward Store title returns to the dashboard',
        (tester) async {
      await _pumpHome(tester);

      final rewards = find.text('Task rewards');
      await tester.ensureVisible(rewards);
      await tester.tap(rewards);
      await tester.pumpAndSettle();
      expect(find.text('Reward Store'), findsOneWidget);

      await tester.tap(find.text('Reward Store'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Mom!'), findsOneWidget);
    });
  });
}
