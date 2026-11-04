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

UserProfile _child() => UserProfile(
      name: 'Maya',
      birthday: DateTime(2016, 4, 23),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

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

Finder _dialogField(String label) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == label,
    );

void main() {
  group('Parent review queue', () {
    testWidgets('shows pending tasks with review actions', (tester) async {
      await _pumpHome(tester, _parent());

      expect(find.text('Review queue (2)'), findsOneWidget);
      expect(find.text('Approve All Simple Tasks'), findsOneWidget);
      expect(find.text('Approve & Award Points'), findsNWidgets(2));
      expect(find.text('Request Changes'), findsNWidgets(2));
    });

    testWidgets('batch approve clears only simple tasks', (tester) async {
      await _pumpHome(tester, _parent());

      await tester.tap(find.text('Approve All Simple Tasks'));
      await tester.pumpAndSettle();

      expect(find.text('Review queue (1)'), findsOneWidget);
      expect(find.text('Approve & Award Points'), findsOneWidget);
      expect(find.text('Approved 1 simple task.'), findsOneWidget);
    });

    testWidgets('approve awards points with confirmation', (tester) async {
      await _pumpHome(tester, _parent());

      await tester.tap(find.text('Approve & Award Points').first);
      await tester.pumpAndSettle();

      expect(find.text('Review queue (1)'), findsOneWidget);
      expect(find.text('Approved — +10 pts to Maya.'), findsOneWidget);
    });

    testWidgets('request changes sends feedback through the popup',
        (tester) async {
      await _pumpHome(tester, _parent());

      await tester.ensureVisible(find.text('Request Changes').first);
      await tester.tap(find.text('Request Changes').first);
      await tester.pumpAndSettle();

      expect(find.text('Request changes'), findsOneWidget);
      await tester.enterText(_dialogField('Feedback'), 'Try again.');
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(find.text('Review queue (1)'), findsOneWidget);
      expect(find.text('Needs revision (1)'), findsOneWidget);
    });

    testWidgets('child dashboard hides the review queue', (tester) async {
      await _pumpHome(tester, _child());

      expect(find.textContaining('Review queue'), findsNothing);
      expect(find.text('Approve All Simple Tasks'), findsNothing);
    });
  });
}
