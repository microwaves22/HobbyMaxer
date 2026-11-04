import 'package:flutter/material.dart';

import '../calendar/models/calendar_event.dart';
import 'models/family_time_option.dart';

/// Sample data + verbatim strings for the "07 Family Time" screen.
///
/// Provenance per value:
/// - Every string is transcribed from the node 4:246 design screenshot.
/// - Member colors reuse verified sibling-screen tokens (profile hub,
///   family setup, link kids). The design shows four avatar circles but
///   only three members are named anywhere in the project (Sarah, Ava,
///   Noah), so the fourth circle is an explicitly marked placeholder.
/// - The category glyphs are multicolor Figma assets; [activityTypes]
///   maps each to the closest Material icon (no Figma export available).
abstract final class FamilyTimeData {
  /// Header copy, verbatim.
  static const String title = 'Family Time';
  static const String subtitle = 'Find a time for the whole family!';

  /// Suggested card copy, verbatim.
  static const String suggestedLabel = '✨ Suggested Time';
  static const String bestMatchLabel = 'Best match';
  static const String suggestedDay = 'Friday, Nov 6';
  static const String suggestedTime = '6:00 – 7:00 PM';
  static const String availabilityLabel = 'Everyone is available!';

  /// Primary button + secondary section copy, verbatim.
  static const String confirmLabel = 'Confirm Family Time';
  static const String otherOptionsLabel = 'Other Options';
  static const String seeAllLabel = 'See All';

  /// The four availability avatars, in design order (peach, blue, pink,
  /// yellowLight). Sarah/Ava/Noah reuse their sibling-screen identities;
  /// the yellow circle's owner is not named in any design or code, so it
  /// is a placeholder awaiting the Figma value.
  static const List<FamilyMember> members = [
    FamilyMember(
      id: 'sarah',
      name: 'Sarah',
      initials: 'S',
      color: Color(0xFFF6D9C4),
    ),
    FamilyMember(
      id: 'noah',
      name: 'Noah',
      initials: 'N',
      color: Color(0xFFCFE0EE),
    ),
    FamilyMember(
      id: 'ava',
      name: 'Ava',
      initials: 'A',
      color: Color(0xFFF4C9C9),
    ),
    FamilyMember(
      id: 'member-4',
      name: 'Member 4',
      initials: 'M4',
      color: Color(0xFFFDF0C8),
    ),
  ];

  /// Activity-type chips, in design order, with verbatim labels.
  static const List<ActivityType> activityTypes = [
    ActivityType(
      id: 'dinner',
      label: 'Dinner',
      icon: Icons.restaurant_rounded,
    ),
    ActivityType(
      id: 'game-night',
      label: 'Game Night',
      icon: Icons.casino_rounded,
    ),
    ActivityType(
      id: 'movie',
      label: 'Movie',
      icon: Icons.movie_rounded,
    ),
    ActivityType(
      id: 'walk',
      label: 'Walk',
      icon: Icons.directions_walk_rounded,
    ),
  ];

  /// Category strip icons, in design order. The strip order differs from
  /// the chip order in the design (dice, popcorn, walker, plate).
  static const List<String> stripTypeIds = [
    'game-night',
    'movie',
    'walk',
    'dinner',
  ];

  /// Selected chip in the design.
  static const String defaultActivityTypeId = 'game-night';

  /// "Other Options" rows, in design order. Both rows are unselected in
  /// the design.
  static const List<FamilyTimeOption> options = [
    FamilyTimeOption(
      id: 'sat-nov-7',
      dayLabel: 'Sat, Nov 7',
      timeLabel: '5:00 – 6:00 PM',
    ),
    FamilyTimeOption(
      id: 'sun-nov-8',
      dayLabel: 'Sun, Nov 8',
      timeLabel: '4:00 – 5:00 PM',
    ),
  ];

  /// Looks up an activity type by id.
  static ActivityType activityTypeById(String id) {
    return activityTypes.firstWhere((type) => type.id == id);
  }
}
