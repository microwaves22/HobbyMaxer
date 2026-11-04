import 'package:flutter/material.dart';

/// Data shapes for the "06 Calendar" screen (Figma node 4:121).
///
/// Sample values live in `calendar_data.dart`; these types only describe
/// the shape. Field meanings follow the screen spec; types are adapted to
/// Dart conventions (`DateTime` + `Color` instead of raw strings).

/// One household member, as named in the design.
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });

  final String id;
  final String name;
  final String initials;
  final Color color;
}

/// One timetable block on the week grid.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    this.serverId,
    required this.title,
    this.description,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    this.memberIds = const [],
    required this.color,
    required this.textColor,
  });

  final String id;

  /// Backend event id once synced; null for design and local events.
  final int? serverId;

  /// Verbatim title from the design.
  final String title;

  /// Optional longer description (backend events only).
  final String? description;

  /// Day the event belongs to (midnight, local).
  final DateTime date;

  /// Minutes from midnight, read from the block position on the grid.
  final int startMinutes;

  /// Minutes from midnight, read from the block position on the grid.
  final int endMinutes;

  /// People shown on the event. Empty: the design shows no people on
  /// event blocks.
  final List<String> memberIds;

  /// Block fill, from the design.
  final Color color;

  /// Block label color, from the design.
  final Color textColor;
}

/// Day / Week / Month view switcher options.
enum CalendarView { day, week, month }

/// Segment labels, verbatim from the design, in design order.
const calendarViewLabels = <CalendarView, String>{
  CalendarView.day: 'Day',
  CalendarView.week: 'Week',
  CalendarView.month: 'Month',
};
