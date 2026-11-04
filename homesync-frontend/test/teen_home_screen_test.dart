import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/home/teen_home_screen.dart';

Future<void> _pumpTeenHome(
  WidgetTester tester, {
  TeenHomeScreen Function()? build,
}) async {
  await tester.pumpWidget(
    MaterialApp(home: build?.call() ?? const TeenHomeScreen()),
  );
  await tester.pumpAndSettle();
}

TextStyle _styleOf(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final style = widget.style;
  expect(style, isNotNull, reason: '$text has an explicit style');
  return style!;
}

/// Finds a [Text.rich] by its plain-text content.
Finder _richText(String plain) {
  return find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText() == plain,
  );
}

void main() {
  group('Teen Home (Figma 7:320)', () {
    testWidgets('uses the teen background, greeting, and two-run points pill',
        (tester) async {
      await _pumpTeenHome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF4F3EF));

      expect(find.text('Hey, Noah'), findsOneWidget);
      expect(find.text('Saturday, Oct 31'), findsOneWidget);

      // Points pill: white with a line border, NO star, two text runs.
      expect(_richText('120 pts'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(_richText('Teen Mode · simplified view'), findsOneWidget);
    });

    testWidgets('renders the Ember companion widget', (tester) async {
      await _pumpTeenHome(tester);

      expect(find.text('COMPANION'), findsOneWidget);
      expect(find.text('Ember'), findsOneWidget);
      expect(find.text('Thriving'), findsOneWidget);
      expect(find.text('Rested · 94% care'), findsOneWidget);
      expect(find.text('Armor'), findsOneWidget);
      expect(find.text('Skin'), findsOneWidget);
      expect(find.text('Den'), findsOneWidget);
      expect(find.text('Companion details'), findsOneWidget);
      expect(find.text('Skins, armor, den themes'), findsOneWidget);
    });

    testWidgets('renders due-today tasks and upcoming events',
        (tester) async {
      await _pumpTeenHome(tester);

      expect(teenTasks.map((t) => t.title), [
        'Math homework',
        'Vacuum living room',
        'Take out recycling',
      ]);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
      expect(find.text('Photo/video'), findsNWidgets(2));
      expect(find.text('Approved'), findsOneWidget);

      expect(find.text('Soccer practice'), findsOneWidget);
      expect(find.text('Thu · 4:30 PM'), findsOneWidget);
      expect(find.text('Family dinner'), findsOneWidget);
      expect(find.text('Fri · 6:00 PM'), findsOneWidget);

      // No progress ring or mini bars on this screen.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('bottom nav has Home active', (tester) async {
      await _pumpTeenHome(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(
        _styleOf(tester, 'Home').color,
        const Color(0xFF5F7F55),
      );
    });

    testWidgets('handlers fire with task and tab ids', (tester) async {
      final calls = <String>[];
      await _pumpTeenHome(
        tester,
        build: () => TeenHomeScreen(
          onTaskPress: (id) => calls.add('task:$id'),
          onProofPress: (id) => calls.add('proof:$id'),
          onCompanionPress: () => calls.add('companion'),
          onTabPress: (id) => calls.add('tab:$id'),
        ),
      );

      await tester.tap(find.text('Photo/video').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Companion details'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Take out recycling'));
      await tester.tap(find.text('Take out recycling'));
      await tester.pumpAndSettle();

      // Proof taps don't bubble to the row handler (nested detector).
      expect(calls, contains('proof:math-homework'));
      expect(calls, contains('companion'));
      expect(calls, contains('task:recycling'));
    });
  });
}
