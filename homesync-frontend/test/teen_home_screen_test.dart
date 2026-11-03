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

void main() {
  group('Teen Home TODO shell (Figma 7:320, specs not retrieved)', () {
    testWidgets('scaffold uses the verified cream background', (tester) async {
      await _pumpTeenHome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFBF7EF));
    });

    testWidgets('renders TODO placeholders, no invented content',
        (tester) async {
      await _pumpTeenHome(tester);

      expect(find.textContaining('TODO(Figma 7:320)'), findsWidgets);
      expect(find.text('TODO(Figma 7:320): header greeting + name'),
          findsOneWidget);
      expect(
          find.text(
              'TODO(Figma 7:320): task/chore list — names, points, due times'),
          findsOneWidget);
      expect(find.text('TODO(Figma 7:320): progress / streak / rewards widgets'),
          findsOneWidget);
      expect(find.text('TODO(Figma 7:320): bottom navigation tabs'),
          findsOneWidget);
    });

    testWidgets('placeholder text uses Nunito + verified tokens',
        (tester) async {
      await _pumpTeenHome(tester);

      final header = tester.widget<Text>(
          find.text('TODO(Figma 7:320): header greeting + name'));
      expect(header.style?.fontFamily, 'Nunito');
      expect(header.style?.color, const Color(0xFF7C877A));

      final tasks = tester.widget<Text>(find.text(
          'TODO(Figma 7:320): task/chore list — names, points, due times'));
      expect(tasks.style?.fontFamily, 'Nunito');
      expect(tasks.style?.color, const Color(0xFF5F7F55));
    });

    testWidgets('task list renders from the (empty) data array',
        (tester) async {
      expect(teenTasks, isEmpty);
      await _pumpTeenHome(tester);

      // Empty array -> only the empty-state placeholder, no progress widgets.
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('placeholder handlers fire', (tester) async {
      final calls = <String>[];
      await _pumpTeenHome(
        tester,
        build: () => TeenHomeScreen(
          onAvatarPress: () => calls.add('avatar'),
          onRewardsPress: () => calls.add('rewards'),
        ),
      );

      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.tap(
          find.text('TODO(Figma 7:320): progress / streak / rewards widgets'));
      await tester.pumpAndSettle();

      expect(calls, ['avatar', 'rewards']);
    });
  });
}
