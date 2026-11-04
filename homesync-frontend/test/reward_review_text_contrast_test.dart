import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/theme/app_theme.dart';
import 'package:homesync/views/rewards/parent_review_queue_screen.dart';
import 'package:homesync/views/rewards/request_custom_reward_screen.dart';

/// Regression coverage for the review-flow text contrast bug: the
/// borderless cost fields inherited the theme's input fill, which is
/// near-black in dark mode — dark text on a dark fill. Both fields now
/// carry an explicit light fill so typed text stays visible in either
/// theme.
void main() {
  group('Review-flow cost field contrast', () {
    testWidgets('review queue cost field stays readable in dark mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const ParentReviewQueueScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // The review queue has exactly one text field: the editable cost.
      expect(find.byType(TextField), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      final decoration = field.decoration!;
      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, isNotNull);
      expect(
        decoration.fillColor!.computeLuminance(),
        greaterThan(0.5),
        reason: 'cost field fill must stay light in dark mode',
      );
      expect(field.style, isNotNull);
      expect(
        field.style!.color!.computeLuminance(),
        lessThan(0.5),
        reason: 'typed text must stay dark on the light fill',
      );

      await tester.enterText(find.byType(TextField), '90 points');
      await tester.pumpAndSettle();
      expect(find.text('90 points'), findsOneWidget);
    });

    testWidgets('request cost field stays readable in dark mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const RequestCustomRewardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // The cost field is the one showing the " points" suffix.
      final fields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      final cost = fields.firstWhere(
        (f) => f.controller?.text.endsWith('points') ?? false,
      );
      final decoration = cost.decoration!;
      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, isNotNull);
      expect(
        decoration.fillColor!.computeLuminance(),
        greaterThan(0.5),
        reason: 'cost field fill must stay light in dark mode',
      );
      expect(cost.style, isNotNull);
      expect(
        cost.style!.color!.computeLuminance(),
        lessThan(0.5),
        reason: 'typed text must stay dark on the light fill',
      );
    });
  });
}
