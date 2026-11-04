import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/views/rewards/request_custom_reward_screen.dart';
import 'package:homesync/views/rewards/rewards_routes.dart';

List<TextField> _fields(WidgetTester tester) =>
    tester.widgetList<TextField>(find.byType(TextField)).toList();

void main() {
  testWidgets('send pops back to the store with confirmation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  RewardsRoutes.openRequestCustomReward(context),
              child: const Text('open store'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open store'));
    await tester.pumpAndSettle();
    expect(find.byType(RequestCustomRewardScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Send Request'));
    await tester.tap(find.text('Send Request'));
    await tester.pumpAndSettle();

    expect(find.byType(RequestCustomRewardScreen), findsNothing);
    expect(
      find.text('Request sent — Sarah will review it'),
      findsOneWidget,
    );
    expect(find.text('open store'), findsOneWidget);
  });

  testWidgets('failed submit stays on the form with input intact',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RequestCustomRewardScreen(
          submitRequest: (_) async => throw Exception('offline'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final perk = _fields(tester).firstWhere(
      (f) => f.controller?.text == 'Go to trampoline park',
    );
    await tester.enterText(find.byWidget(perk), 'Extra game time');

    await tester.ensureVisible(find.text('Send Request'));
    await tester.tap(find.text('Send Request'));
    await tester.pumpAndSettle();

    expect(find.byType(RequestCustomRewardScreen), findsOneWidget);
    expect(
      find.text('Could not send request. Exception: offline'),
      findsOneWidget,
    );
    expect(
      _fields(tester).any((f) => f.controller?.text == 'Extra game time'),
      isTrue,
    );
  });

  testWidgets('double taps submit at most once', (tester) async {
    var calls = 0;
    final gate = Completer<void>();

    RequestCustomRewardScreen requestScreen() => RequestCustomRewardScreen(
          submitRequest: (_) async {
            calls++;
            await gate.future;
          },
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => requestScreen()),
              ),
              child: const Text('open store'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open store'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Send Request'));
    await tester.tap(find.text('Send Request'));
    await tester.pump();
    await tester.tap(find.text('Send Request'));
    await tester.pump();
    expect(calls, 1);

    gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.byType(RequestCustomRewardScreen), findsNothing);
    expect(
      find.text('Request sent — Sarah will review it'),
      findsOneWidget,
    );
  });
}
