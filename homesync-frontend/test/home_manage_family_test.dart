import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/onboarding/link_kids_screen.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: FocusAreasScope(
        controller: FocusAreasController(FocusAreas.all),
        child: HomeScreen(
          profile: UserProfile(
            name: 'Mom',
            birthday: DateTime(1990, 1, 1),
            role: FamilyRole.parent,
            mode: FamilyMode.parent,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Manage family opens the link kids screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();
    expect(find.text('Manage family'), findsOneWidget);

    await tester.tap(find.text('Manage family'));
    await tester.pumpAndSettle();

    expect(find.byType(LinkKidsScreen), findsOneWidget);
  });
}
