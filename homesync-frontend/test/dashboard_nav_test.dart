import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/state/focus_areas.dart';
import 'package:homesync/views/calendar/calendar_screen.dart';
import 'package:homesync/views/home/home_screen.dart';
import 'package:homesync/views/home/household_routes.dart';
import 'package:homesync/views/onboarding/models/user_profile.dart';
import 'package:homesync/views/rewards/kids_reward_store_screen.dart';
import 'package:homesync/views/rewards/request_custom_reward_screen.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';
import 'package:homesync/views/tasks/teen_todo_list_screen.dart';

UserProfile _kids() => UserProfile(
      name: 'Ava',
      birthday: DateTime(2018, 5, 2),
      role: FamilyRole.child,
      mode: FamilyMode.kids,
    );

UserProfile _teen() => UserProfile(
      name: 'Noah',
      birthday: DateTime(2012, 9, 14),
      role: FamilyRole.child,
      mode: FamilyMode.teen,
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

Future<void> _openRewards(WidgetTester tester) async {
  final rewards = find.text('Task rewards');
  await tester.ensureVisible(rewards);
  await tester.tap(rewards);
  await tester.pumpAndSettle();
}

// The dashboard chores card was removed in favor of the bottom nav;
// push the teen list directly with the dashboard's old wiring.
Future<void> _openTeenTodo(WidgetTester tester, UserProfile profile) async {
  final context = tester.element(find.byType(HomeScreen));
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TeenTodoListScreen(
        controller: TasksController.forProfile(profile),
        profile: profile,
        onNavigateHome: () => Navigator.of(context).pop(),
        onNavigateCalendar: () =>
            HouseholdRoutes.openTab(context, 'calendar'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Dashboard nav bars', () {
    testWidgets('kids store Calendar opens the Calendar view',
        (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);
      expect(find.byType(KidsRewardStoreScreen), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.byType(KidsRewardStoreScreen), findsNothing);
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('request form Home returns to the dashboard', (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);
      await tester.ensureVisible(find.text('+ Request Custom Reward'));
      await tester.tap(find.text('+ Request Custom Reward'));
      await tester.pumpAndSettle();
      expect(find.byType(RequestCustomRewardScreen), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(RequestCustomRewardScreen), findsNothing);
      expect(find.text('Hello, Ava!'), findsOneWidget);
    });

    testWidgets('request form Calendar opens the Calendar view',
        (tester) async {
      await _pumpHome(tester, _kids());
      await _openRewards(tester);
      await tester.ensureVisible(find.text('+ Request Custom Reward'));
      await tester.tap(find.text('+ Request Custom Reward'));
      await tester.pumpAndSettle();
      expect(find.byType(RequestCustomRewardScreen), findsOneWidget);

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.byType(RequestCustomRewardScreen), findsNothing);
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    testWidgets('teen todo Home returns to the dashboard', (tester) async {
      await _pumpHome(tester, _teen());
      await _openTeenTodo(tester, _teen());
      expect(find.byType(TeenTodoListScreen), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('teen-nav-home')));
      await tester.tap(find.byKey(const ValueKey('teen-nav-home')));
      await tester.pumpAndSettle();

      expect(find.byType(TeenTodoListScreen), findsNothing);
      expect(find.text('Hello, Noah!'), findsOneWidget);
    });

    testWidgets('teen todo Calendar opens the Calendar view', (tester) async {
      await _pumpHome(tester, _teen());
      await _openTeenTodo(tester, _teen());
      expect(find.byType(TeenTodoListScreen), findsOneWidget);

      await tester
          .ensureVisible(find.byKey(const ValueKey('teen-nav-calendar')));
      await tester.tap(find.byKey(const ValueKey('teen-nav-calendar')));
      await tester.pumpAndSettle();

      expect(find.byType(TeenTodoListScreen), findsNothing);
      expect(find.byType(CalendarScreen), findsOneWidget);
    });
  });
}
