import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/calendar/calendar_screen.dart';
import 'package:homesync/views/family_time/family_time_screen.dart';
import 'package:homesync/views/home/profile_hub_screen.dart';
import 'package:homesync/views/settings/account_settings_screen.dart';
import 'package:homesync/views/tasks/tasks_screen.dart';

const _sage = Color(0xFF5F7F55);

/// True when the [label] tab renders in the active color. Labels are
/// screen-unique except for screen titles, which never use sage.
bool _tabActive(WidgetTester tester, String label) {
  return tester
      .widgetList<Text>(find.text(label))
      .any((text) => text.style?.color == _sage);
}

void main() {
  testWidgets('calendar tabs replace with home/tasks/family', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalendarScreen()));
    await tester.pumpAndSettle();

    // Own tab is a no-op (icon: the label duplicates the title).
    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
    expect(find.byType(ProfileHubScreen), findsOneWidget);
    expect(_tabActive(tester, 'Home'), isTrue);

    // Round-trip through the hub: no stacked duplicates.
    await tester.ensureVisible(find.text('Calendar'));
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileHubScreen), findsNothing);
    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(_tabActive(tester, 'Calendar'), isTrue);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
    expect(find.byType(FamilyTimeScreen), findsOneWidget);
    expect(_tabActive(tester, 'Family'), isTrue);
  });

  testWidgets('calendar tasks tab opens the tasks screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalendarScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('family tabs replace with home/calendar/tasks', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FamilyTimeScreen()));
    await tester.pumpAndSettle();

    // Own tab is a no-op.
    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyTimeScreen), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyTimeScreen), findsNothing);
    expect(find.byType(ProfileHubScreen), findsOneWidget);
    expect(_tabActive(tester, 'Home'), isTrue);

    await tester.ensureVisible(find.text('Calendar'));
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileHubScreen), findsNothing);
    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(_tabActive(tester, 'Calendar'), isTrue);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('hub tabs replace with calendar/tasks/family', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileHubScreen()));
    await tester.pumpAndSettle();

    // Own tab is a no-op.
    await tester.ensureVisible(find.text('Home'));
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileHubScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Calendar'));
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileHubScreen), findsNothing);
    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(_tabActive(tester, 'Calendar'), isTrue);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarScreen), findsNothing);
    expect(find.byType(FamilyTimeScreen), findsOneWidget);
    expect(_tabActive(tester, 'Family'), isTrue);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyTimeScreen), findsNothing);
    expect(find.byType(TasksScreen), findsOneWidget);
  });

  testWidgets('account settings pushes and back returns to the hub',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileHubScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account settings'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountSettingsScreen), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-settings-back')));
    await tester.pumpAndSettle();
    expect(find.byType(AccountSettingsScreen), findsNothing);
    expect(find.byType(ProfileHubScreen), findsOneWidget);
  });
}
