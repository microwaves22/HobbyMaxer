import 'package:flutter/material.dart';

/// Data shapes for the "07 Family Time" screen (Figma node 4:246).
///
/// Sample values live in `family_time_data.dart`; these types only describe
/// the shape. Member identity reuses `FamilyMember` from the 06 Calendar
/// screen (`views/calendar/models/calendar_event.dart`).

/// One activity type: a chip in the suggested card and an icon in the
/// category strip above it.
class ActivityType {
  const ActivityType({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;

  /// Verbatim chip label from the design.
  final String label;

  /// Material-icon mapping of the design's category glyph (the Figma
  /// asset was not available for export; see the delivery report).
  final IconData icon;
}

/// One row in the "Other Options" section.
class FamilyTimeOption {
  const FamilyTimeOption({
    required this.id,
    required this.dayLabel,
    required this.timeLabel,
    this.memberIds = const [],
  });

  final String id;

  /// Verbatim day label from the design (e.g. 'Sat, Nov 7').
  final String dayLabel;

  /// Verbatim time label from the design (e.g. '5:00 – 6:00 PM').
  final String timeLabel;

  /// People shown on the row. Empty: the design shows no people on
  /// option rows.
  final List<String> memberIds;
}
