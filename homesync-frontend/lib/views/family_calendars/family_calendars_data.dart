import 'package:flutter/material.dart';

import '../calendar/models/calendar_event.dart' show FamilyMember;

/// Sample data for the "Family calendars" screen.
///
/// Transcribed from the reference image (node 37:635). Provenance per value:
/// - All copy (names, owners, labels, timeline) is verbatim from the design.
/// - Member colors: Sarah's sage reuses the Figma sage used across sibling
///   screens; Ava's peach has no precedent and is an estimate.
/// - Noah's avatar is dark ink in this reference, which MISMATCHES 06
///   Calendar's Noah (sage #5F7F55). The reference value is kept here; the
///   mismatch is flagged in the delivery report instead of changing either.
/// - Roles ("Parent"/"Child") are design copy; 06's [FamilyMember] carries no
///   role, so they live in [memberRoles] without touching that class.

/// Members who can own a calendar, in chip order.
const List<FamilyMember> familyCalendarMembers = <FamilyMember>[
  FamilyMember(id: 'sarah', name: 'Sarah', initials: 'S', color: _sage),
  // Estimated: no peach precedent in the design system.
  FamilyMember(id: 'ava', name: 'Ava', initials: 'A', color: _avaPeach),
  // Reference value; mismatches 06 Calendar's Noah (sage). See doc above.
  FamilyMember(id: 'noah', name: 'Noah', initials: 'N', color: _ink),
];

const Color _sage = Color(0xFF5F7F55);
const Color _ink = Color(0xFF2B3A2B);
const Color _avaPeach = Color(0xFFE8A06F);

/// Role line per member id, verbatim ("Parent" / "Child").
const Map<String, String> memberRoles = <String, String>{
  'sarah': 'Parent',
  'ava': 'Child',
  'noah': 'Child',
};

/// Owner-chip labels per member id, verbatim.
const Map<String, String> memberChipLabels = <String, String>{
  'sarah': 'Sarah (you)',
  'ava': 'Ava',
  'noah': 'Noah',
};

FamilyMember memberById(String id) =>
    familyCalendarMembers.firstWhere((FamilyMember m) => m.id == id);

/// Selection control shown on a calendar row.
enum CalendarControl { toggle, checkbox, radio, none }

/// One calendar in the Family calendars list.
///
/// Shape follows the screen spec; adapted to Dart conventions ([Color]
/// instead of a raw string, matching 06's `CalendarEvent`). No
/// `accountLabel`: the design shows no account/email line.
class FamilyCalendar {
  const FamilyCalendar({
    required this.id,
    required this.name,
    this.ownerMemberId,
    this.providerLabel,
    required this.color,
    required this.control,
    required this.isOn,
  });

  final String id;
  final String name;
  final String? ownerMemberId;
  final String? providerLabel;
  final Color color;
  final CalendarControl control;
  final bool isOn;
}

/// Calendars in reference order. The design shows no per-row control, so
/// every row is [CalendarControl.none] and listed as on. Tiles are the
/// exact Figma fills (sageLight / pink / blue) with a ".ics" label.
const List<FamilyCalendar> familyCalendars = <FamilyCalendar>[
  FamilyCalendar(
    id: 'personal-work',
    name: 'Personal & work',
    ownerMemberId: 'sarah',
    providerLabel: '.ics',
    color: Color(0xFFE4EBDC),
    control: CalendarControl.none,
    isOn: true,
  ),
  FamilyCalendar(
    id: 'piano-lessons',
    name: 'Piano lessons',
    ownerMemberId: 'ava',
    providerLabel: '.ics',
    color: Color(0xFFF4C9C9),
    control: CalendarControl.none,
    isOn: true,
  ),
  FamilyCalendar(
    id: 'soccer-club',
    name: 'Soccer club',
    ownerMemberId: 'noah',
    providerLabel: '.ics',
    color: Color(0xFFCFE0EE),
    control: CalendarControl.none,
    isOn: true,
  ),
];

/// Sample-day preview copy, verbatim.
const String sampleDayTitle = 'Monday, November 2';
const String sampleDaySubtitle = 'Sample day · Everyone · 9 AM–6 PM';
const String sampleFreeBanner = '4 hours free together · 2 windows';

/// One block in the sample-day preview timeline, in reference order.
class SampleTimelineEntry {
  const SampleTimelineEntry({
    required this.id,
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.isFreeWindow,
    this.ownerMemberId,
  });

  final String id;
  final String timeLabel;
  final String title;
  final String subtitle;
  final bool isFreeWindow;
  final String? ownerMemberId;
}

const List<SampleTimelineEntry> sampleTimeline = <SampleTimelineEntry>[
  SampleTimelineEntry(
    id: 'work-planning',
    timeLabel: '9 AM–12 PM',
    title: 'Work planning',
    subtitle: 'Sarah · Scheduled',
    isFreeWindow: false,
    ownerMemberId: 'sarah',
  ),
  SampleTimelineEntry(
    id: 'free-midday',
    timeLabel: '12–2 PM',
    title: 'Available',
    subtitle: 'Everyone is free',
    isFreeWindow: true,
  ),
  SampleTimelineEntry(
    id: 'piano-lesson',
    timeLabel: '2–3 PM',
    title: 'Piano lesson',
    subtitle: 'Ava · Scheduled',
    isFreeWindow: false,
    ownerMemberId: 'ava',
  ),
  SampleTimelineEntry(
    id: 'soccer-practice',
    timeLabel: '3–4 PM',
    title: 'Soccer practice',
    subtitle: 'Noah · Scheduled',
    isFreeWindow: false,
    ownerMemberId: 'noah',
  ),
  SampleTimelineEntry(
    id: 'free-afternoon',
    timeLabel: '4–6 PM',
    title: 'Available',
    subtitle: 'Everyone is free',
    isFreeWindow: true,
  ),
];
