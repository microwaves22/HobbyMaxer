import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homesync/views/customization/customization_data.dart';
import 'package:homesync/views/customization/customization_screen.dart';
import 'package:homesync/views/customization/customization_store.dart';

const _selection = CustomizationSelection(
  segment: CustomizationSegment.settings,
  avatarId: 'fox',
  backgroundId: 'night',
);

void main() {
  test('codec round-trips a selection', () {
    final decoded =
        CustomizationSelectionCodec.decode(CustomizationSelectionCodec.encode(
      _selection,
    ));
    expect(decoded, _selection);
  });

  test('codec rejects corrupt payloads', () {
    String payload(Map<String, Object?> map) => jsonEncode(map);
    const version = PrefsCustomizationStore.schemaVersion;

    expect(CustomizationSelectionCodec.decode('not json'), isNull);
    expect(CustomizationSelectionCodec.decode('[]'), isNull);
    expect(
      CustomizationSelectionCodec.decode(payload({
        'version': 'something_else',
        'segment': 'settings',
        'avatarId': 'fox',
        'backgroundId': 'night',
      })),
      isNull,
    );
    expect(
      CustomizationSelectionCodec.decode(payload({
        'version': version,
        'segment': 'nope',
        'avatarId': 'fox',
        'backgroundId': 'night',
      })),
      isNull,
    );
    expect(
      CustomizationSelectionCodec.decode(payload({
        'version': version,
        'segment': 'settings',
        'avatarId': 'dragon',
        'backgroundId': 'night',
      })),
      isNull,
    );
    expect(
      CustomizationSelectionCodec.decode(payload({
        'version': version,
        'segment': 'settings',
        'avatarId': 'fox',
        'backgroundId': 'volcano',
      })),
      isNull,
    );
    expect(
      CustomizationSelectionCodec.decode(payload({'version': version})),
      isNull,
    );
  });

  test('prefs store round-trips and tolerates corrupt data', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsCustomizationStore(prefs: prefs);

    expect(await store.load(), isNull);
    await store.save(_selection);
    expect(await store.load(), _selection);

    await prefs.setString(PrefsCustomizationStore.storageKey, 'garbage');
    expect(await store.load(), isNull);
  });

  testWidgets('restores a saved selection over the design defaults',
      (tester) async {
    final store = InMemoryCustomizationStore();
    await store.save(_selection);

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: CustomizationScreen(store: store)),
    );
    await tester.pumpAndSettle();

    // Segment restored: the Settings label renders selected (white).
    final settingsStyle = tester.widget<Text>(find.text('Settings')).style!;
    expect(settingsStyle.color, const Color(0xFFFFFFFF));

    // Avatar restored: the main avatar shows the fox background.
    final mainAvatar = tester.widget<Container>(
      find.byKey(const Key('customization-main-avatar')),
    );
    expect(
      (mainAvatar.decoration! as BoxDecoration).color,
      const Color(0xFFF6D9C4),
    );

    // Background restored: the night tile carries the check badge.
    expect(
      find.descendant(
        of: find.byKey(const Key('background-tile-night')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('saves every selection change', (tester) async {
    final store = InMemoryCustomizationStore();

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: CustomizationScreen(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('avatar-option-fox')));
    await tester.tap(find.byKey(const Key('background-tile-night')));
    await tester.tap(find.byKey(const Key('segment-settings')));
    await tester.pumpAndSettle();

    expect(await store.load(), _selection);
  });
}
