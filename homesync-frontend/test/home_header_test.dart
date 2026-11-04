import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

Future<void> _pumpHome(WidgetTester tester, UserProfile profile) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(profile: profile),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Home header role label', () {
    testWidgets('shows the role once when role and mode match', (tester) async {
      final profile = UserProfile(
        name: 'Mom',
        birthday: DateTime(1990, 1, 1),
        role: FamilyRole.parent,
        mode: FamilyMode.parent,
      );
      await _pumpHome(tester, profile);

      expect(find.text('Hello, Mom!'), findsOneWidget);
      expect(find.text('Parent · Age ${profile.age()}'), findsOneWidget);
      expect(find.textContaining('Parent · Parent'), findsNothing);
    });

    testWidgets('keeps distinct role and mode labels', (tester) async {
      final profile = UserProfile(
        name: 'Noah',
        birthday: DateTime(2012, 5, 6),
        role: FamilyRole.child,
        mode: FamilyMode.teen,
      );
      await _pumpHome(tester, profile);

      expect(find.text('Hello, Noah!'), findsOneWidget);
      expect(
        find.text('Kid · Teens · Age ${profile.age()}'),
        findsOneWidget,
      );
    });
  });
}
