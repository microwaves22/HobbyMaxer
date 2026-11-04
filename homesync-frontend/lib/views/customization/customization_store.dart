import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'customization_data.dart';

/// Local persistence for [CustomizationSelection] behind an abstraction,
/// so a remote save endpoint can replace the storage later without
/// touching the screen.
///
/// Contract: [load] returns null when nothing was saved, the payload is
/// corrupt, or the schema version mismatches — the screen then keeps its
/// design defaults. [save] never throws for missing keys; implementations
/// decide their own error policy (the screen also guards the call).
abstract class CustomizationStore {
  Future<CustomizationSelection?> load();
  Future<void> save(CustomizationSelection selection);
}

/// Production store backed by shared_preferences.
class PrefsCustomizationStore implements CustomizationStore {
  PrefsCustomizationStore({SharedPreferences? prefs})
      : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const String storageKey = 'customization_selection';
  static const String schemaVersion = 'customization_selection_v1';

  Future<SharedPreferences> _prefs() async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  @override
  Future<CustomizationSelection?> load() async {
    try {
      final prefs = await _prefs();
      final raw = prefs.getString(storageKey);
      if (raw == null) return null;
      return CustomizationSelectionCodec.decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(CustomizationSelection selection) async {
    final prefs = await _prefs();
    await prefs.setString(
      storageKey,
      CustomizationSelectionCodec.encode(selection),
    );
  }
}

/// Non-persistent store for tests and previews.
class InMemoryCustomizationStore implements CustomizationStore {
  CustomizationSelection? _selection;

  @override
  Future<CustomizationSelection?> load() async => _selection;

  @override
  Future<void> save(CustomizationSelection selection) async {
    _selection = selection;
  }
}

/// JSON codec for [CustomizationSelection] with a schema version key.
/// Unknown enum values or option ids decode to null (treated as corrupt).
abstract final class CustomizationSelectionCodec {
  static String encode(CustomizationSelection selection) => jsonEncode({
        'version': PrefsCustomizationStore.schemaVersion,
        'segment': selection.segment.name,
        'avatarId': selection.avatarId,
        'backgroundId': selection.backgroundId,
      });

  static CustomizationSelection? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != PrefsCustomizationStore.schemaVersion) return null;
      final segmentName = map['segment'] as String?;
      final avatarId = map['avatarId'] as String?;
      final backgroundId = map['backgroundId'] as String?;
      if (segmentName == null || avatarId == null || backgroundId == null) {
        return null;
      }
      CustomizationSegment? segment;
      for (final candidate in CustomizationSegment.values) {
        if (candidate.name == segmentName) segment = candidate;
      }
      if (segment == null) return null;
      if (!avatarOptions.any((o) => o.id == avatarId)) return null;
      if (!backgroundOptions.any((o) => o.id == backgroundId)) return null;
      return CustomizationSelection(
        segment: segment,
        avatarId: avatarId,
        backgroundId: backgroundId,
      );
    } catch (_) {
      return null;
    }
  }
}
