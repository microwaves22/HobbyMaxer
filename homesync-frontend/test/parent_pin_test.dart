import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homesync/core/widgets/profile_avatar_dropdown.dart';

const _child = ProfileOption(
  name: 'Maya',
  roleLabel: 'Child',
);
const _sibling = ProfileOption(
  name: 'Leo',
  roleLabel: 'Child',
);
const _parent = ProfileOption(
  name: 'Mom',
  roleLabel: 'Parent',
  isParent: true,
);

Future<void> _pumpDropdown(
  WidgetTester tester, {
  required ProfileOption active,
  ValueChanged<ProfileOption>? onSwitchProfile,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProfileAvatarDropdown(
          active: active,
          profiles: const [_child, _sibling, _parent],
          parentPin: '1234',
          onSwitchProfile: onSwitchProfile,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester) async {
  // The header avatar (MemberAvatar) opens the profile menu.
  await tester.tap(find.byTooltip('Profile'));
  await tester.pumpAndSettle();
}

void main() {
  group('Parent PIN gate', () {
    testWidgets('parent rows show a lock for child users', (tester) async {
      await _pumpDropdown(tester, active: _child);
      await _openMenu(tester);

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('child-to-child switch needs no PIN', (tester) async {
      ProfileOption? switched;
      await _pumpDropdown(
        tester,
        active: _child,
        onSwitchProfile: (p) => switched = p,
      );
      await _openMenu(tester);

      await tester.tap(find.text('Leo'));
      await tester.pumpAndSettle();

      expect(switched, _sibling);
      expect(find.text('Parent PIN required'), findsNothing);
    });

    testWidgets('wrong PIN blocks the switch with an error', (tester) async {
      ProfileOption? switched;
      await _pumpDropdown(
        tester,
        active: _child,
        onSwitchProfile: (p) => switched = p,
      );
      await _openMenu(tester);

      await tester.tap(find.text('Mom'));
      await tester.pumpAndSettle();
      expect(find.text('Parent PIN required'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('Unlock'));
      await tester.pump();

      expect(find.text('Incorrect PIN. Try again.'), findsOneWidget);
      expect(switched, isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Parent PIN required'), findsNothing);
      expect(switched, isNull);
    });

    testWidgets('correct PIN allows the switch', (tester) async {
      ProfileOption? switched;
      await _pumpDropdown(
        tester,
        active: _child,
        onSwitchProfile: (p) => switched = p,
      );
      await _openMenu(tester);

      await tester.tap(find.text('Mom'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(switched, _parent);
    });

    testWidgets('parent switching down needs no PIN', (tester) async {
      ProfileOption? switched;
      await _pumpDropdown(
        tester,
        active: _parent,
        onSwitchProfile: (p) => switched = p,
      );
      await _openMenu(tester);

      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();

      expect(switched, _child);
      expect(find.text('Parent PIN required'), findsNothing);
    });
  });
}
