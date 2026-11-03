import 'package:flutter/material.dart';

import 'models/calendar_event.dart';

/// Sample data + date helpers for the "06 Calendar" screen.
///
/// Provenance per value:
/// - Titles, day columns, and relative block positions are transcribed from
///   the node 4:121 design screenshot. Start/end times are read from the
///   grid positions (2-hour grid lines) and are estimates.
/// - Event colors reuse verified sibling-screen tokens where the design
///   system already defines the shade (profile hub, node 62:5787);
///   Work blue and Dr. purple have no precedent and are estimates.
abstract final class CalendarData {
  /// Monday of the designed week. Oct 26, 2026 is a Monday.
  static final DateTime designedWeekStart = DateTime(2026, 10, 26);

  /// Selected day in the design: Saturday, Oct 31, 2026.
  static final DateTime designedSelectedDay = DateTime(2026, 10, 31);

  /// Visible grid window, from the time gutter (8 AM – 8 PM).
  static const int gridStartHour = 8;
  static const int gridEndHour = 20;

  /// Gutter labels, verbatim from the design.
  static const List<String> gutterLabels = [
    '8 AM',
    '10 AM',
    '12 PM',
    '2 PM',
    '4 PM',
    '6 PM',
    '8 PM',
  ];

  /// Weekday names, verbatim from the design (Monday first).
  static const List<String> weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// The only person named in the design (Smart Planner copy).
  /// Color: no member color is shown; sage is an estimate.
  static const List<FamilyMember> members = [
    FamilyMember(
      id: 'noah',
      name: 'Noah',
      initials: 'N',
      color: Color(0xFF5F7F55),
    ),
  ];

  /// Timetable blocks in design order. Times are estimated from the
  /// block positions on the 2-hour grid.
  static final List<CalendarEvent> events = [
    CalendarEvent(
      id: 'work',
      title: 'Work',
      date: DateTime(2026, 10, 27),
      startMinutes: 10 * 60,
      endMinutes: 12 * 60,
      color: const Color(0xFFD4E2F1), // Estimated: no precedent.
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'dr',
      title: 'Dr.',
      // Estimated column: the block sits on the Tue/Wed boundary.
      date: DateTime(2026, 10, 28),
      startMinutes: 12 * 60,
      endMinutes: 14 * 60,
      color: const Color(0xFFDCD5F1), // Estimated: no precedent.
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'school-wed',
      title: 'School',
      date: DateTime(2026, 10, 28),
      startMinutes: 9 * 60,
      endMinutes: 11 * 60,
      color: const Color(0xFFFDF0C8), // Sibling token (profile hub).
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'school-thu',
      title: 'School',
      date: DateTime(2026, 10, 29),
      startMinutes: 9 * 60,
      endMinutes: 11 * 60,
      color: const Color(0xFFFDF0C8), // Sibling token (profile hub).
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'piano',
      title: 'Piano',
      date: DateTime(2026, 10, 30),
      startMinutes: 10 * 60,
      endMinutes: 12 * 60,
      color: const Color(0xFFF4C9C9), // Sibling token (profile hub).
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'soccer',
      title: 'Soccer',
      date: DateTime(2026, 10, 29),
      startMinutes: 16 * 60,
      endMinutes: 18 * 60,
      color: const Color(0xFFF6D9C4), // Sibling token (profile hub).
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'chores',
      title: 'Chores',
      date: DateTime(2026, 10, 31),
      startMinutes: 14 * 60,
      endMinutes: 16 * 60,
      color: const Color(0xFFE4EBDC), // Sibling token (profile hub).
      textColor: const Color(0xFF2B3A2B),
    ),
    CalendarEvent(
      id: 'dinner-fri',
      title: 'Dinner',
      date: DateTime(2026, 10, 30),
      startMinutes: 18 * 60,
      endMinutes: 20 * 60,
      color: const Color(0xFF4A6A41), // Sibling token (profile hub).
      textColor: const Color(0xFFFFFFFF),
    ),
    CalendarEvent(
      id: 'dinner-sat',
      title: 'Dinner',
      date: DateTime(2026, 10, 31),
      startMinutes: 18 * 60,
      endMinutes: 20 * 60,
      color: const Color(0xFF4A6A41), // Sibling token (profile hub).
      textColor: const Color(0xFFFFFFFF),
    ),
  ];

  /// Smart Planner copy, verbatim from the design.
  static const String plannerTitle = 'Smart Planner';
  static const String plannerBody =
      "Thursday is overloaded. Move Noah's vacuuming to Friday?";

  /// Monday-to-Sunday dates for the week starting [weekStart] (a Monday).
  ///
  /// Calendar arithmetic (not [Duration]) so DST transitions never shift
  /// the wall-clock time.
  static List<DateTime> weekDays(DateTime weekStart) {
    final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  /// Monday of the week [weeks] after [weekStart], at midnight.
  /// Calendar arithmetic (not [Duration]) so DST transitions never shift
  /// the day: Oct 26 + 1 week is Nov 2 even across the Nov 1 fallback.
  static DateTime shiftWeek(DateTime weekStart, int weeks) {
    return DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 7 * weeks,
    );
  }

  /// Events on [day], in design order.
  static List<CalendarEvent> eventsForDay(DateTime day) {
    return events
        .where(
          (e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day,
        )
        .toList();
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// "Oct 26 – Nov 1, 2026" for the designed week. Same-month weeks
  /// render as "Nov 2 – 8, 2026" (format assumed; only the designed
  /// week string is verified).
  static String weekRangeLabel(DateTime weekStart) {
    final start = weekStart;
    final end = weekStart.add(const Duration(days: 6));
    final startPart = '${_months[start.month - 1]} ${start.day}';
    final endPart = start.month == end.month
        ? '${end.day}, ${end.year}'
        : '${_months[end.month - 1]} ${end.day}, ${end.year}';
    return '$startPart – $endPart';
  }

  /// True when [a] and [b] are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
