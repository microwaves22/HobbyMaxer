import 'package:flutter/material.dart';

import 'family_calendars_data.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _cream = Color(0xFFF9F8F6);
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF7A9A85);
const _sageDark = Color(0xFF4A6A41);
const _line = Color(0xFFE8E4D8);
const _white = Color(0xFFFFFFFF);
const _importFill = Color.fromRGBO(228, 235, 220, 0.66);
const _availableFill = Color.fromRGBO(228, 235, 220, 0.66);
const _scheduledFill = Color.fromRGBO(255, 255, 255, 0.44);
const _icsMute = Color(0xFF667361);

// Borrowed from the sibling screens (06 Calendar / profile hub): the same
// design system already defines this sage tint, reused here for the import
// card, the free-time banner, the available rows, and the SAMPLE DATA pill.
const _sageLight = Color(0xFFE4EBDC);

TextStyle _style(
  double size,
  FontWeight weight,
  Color color, {
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Figma "Family calendars" (node 37:635): a settings-style screen reached
/// from Parent settings (back link, no bottom nav) with an .ics import card,
/// the family calendar list, and a sample-day free-time preview.
///
/// Content is transcribed from the reference image. Text sizes, gaps, and
/// radii are read from the screenshot (no Inspect values available); see the
/// delivery report for the flagged estimates.
///
/// All callbacks are placeholders: local UI state only, no backend, no file
/// import, no OAuth, no persistence.
class FamilyCalendarsScreen extends StatefulWidget {
  const FamilyCalendarsScreen({
    super.key,
    this.onBack,
    this.onSelectOwner,
    this.onChooseFile,
    this.onPreviousDay,
    this.onNextDay,
  });

  /// Called from the "Parent settings" back link. Defaults to popping.
  final VoidCallback? onBack;

  /// Called with the newly selected owner member id.
  final ValueChanged<String>? onSelectOwner;

  /// Called from the "Choose .ics file" button. No picker exists yet.
  final VoidCallback? onChooseFile;

  /// Called from the sample-day "<" chevron. The design shows one sample day.
  final VoidCallback? onPreviousDay;

  /// Called from the sample-day ">" chevron. The design shows one sample day.
  final VoidCallback? onNextDay;

  @override
  State<FamilyCalendarsScreen> createState() => _FamilyCalendarsScreenState();
}

class _FamilyCalendarsScreenState extends State<FamilyCalendarsScreen> {
  String _selectedOwnerId = familyCalendarMembers.first.id;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleSelectOwner(String memberId) {
    setState(() => _selectedOwnerId = memberId);
    widget.onSelectOwner?.call(memberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _BackLink(onTap: _handleBack),
              const SizedBox(height: 8),
              Text(
                'Family calendars',
                style: _style(26, FontWeight.w800, _ink, height: 1.15),
              ),
              const SizedBox(height: 4),
              Text(
                "Everyone's plans, and a little room to breathe.",
                style: _style(14, FontWeight.w400, _mute),
              ),
              const SizedBox(height: 20),
              _AddCalendarCard(
                selectedOwnerId: _selectedOwnerId,
                onSelectOwner: _handleSelectOwner,
                onChooseFile: widget.onChooseFile,
              ),
              const SizedBox(height: 20),
              const _CalendarsSection(),
              const SizedBox(height: 20),
              _SampleDaySection(
                onPrevious: widget.onPreviousDay,
                onNext: widget.onNextDay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.chevron_left, size: 20, color: _ink),
              const SizedBox(width: 2),
              Text(
                'Parent settings',
                style: _style(14, FontWeight.w700, _sageDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCalendarCard extends StatelessWidget {
  const _AddCalendarCard({
    required this.selectedOwnerId,
    required this.onSelectOwner,
    required this.onChooseFile,
  });

  final String selectedOwnerId;
  final ValueChanged<String> onSelectOwner;
  final VoidCallback? onChooseFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _importFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.calendar_today, size: 26, color: _ink),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Add a calendar',
                      style: _style(16, FontWeight.w800, _ink),
                    ),
                    Text(
                      'Import a calendar file (.ics)',
                      style: _style(13, FontWeight.w500, _icsMute),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Whose calendar is this?',
            style: _style(14, FontWeight.w700, _ink),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (final member in familyCalendarMembers)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: member.id == familyCalendarMembers.last.id ? 0 : 8,
                    ),
                    child: _OwnerChip(
                      label: memberChipLabels[member.id]!,
                      selected: member.id == selectedOwnerId,
                      onTap: () => onSelectOwner(member.id),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onChooseFile ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _sage,
                foregroundColor: _white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: _style(15, FontWeight.w800, _white),
              ),
              child: const Text('Choose .ics file'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No file chosen · Preview events before adding',
            textAlign: TextAlign.center,
            style: _style(12, FontWeight.w500, _mute),
          ),
        ],
      ),
    );
  }
}

class _OwnerChip extends StatelessWidget {
  const _OwnerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _sage : _line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: _sage),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: _style(13, FontWeight.w700, _ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarsSection extends StatelessWidget {
  const _CalendarsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Family calendars',
              style: _style(18, FontWeight.w800, _ink),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _sageLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SAMPLE DATA',
                style: _style(11, FontWeight.w800, _sage, letterSpacing: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < familyCalendars.length; i++)
                _CalendarRow(
                  calendar: familyCalendars[i],
                  showDivider: i < familyCalendars.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Example calendars below. Nothing imported yet.',
          style: _style(12, FontWeight.w500, _mute),
        ),
      ],
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({required this.calendar, required this.showDivider});

  final FamilyCalendar calendar;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final owner = memberById(calendar.ownerMemberId!);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: calendar.color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  owner.initials,
                  style: _style(15, FontWeight.w800, _sageDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      calendar.name,
                      style: _style(15, FontWeight.w800, _ink),
                    ),
                    Text(
                      '${owner.name} · ${memberRoles[owner.id]}',
                      style: _style(13, FontWeight.w500, _mute),
                    ),
                  ],
                ),
              ),
              if (calendar.providerLabel != null)
                Text(
                  calendar.providerLabel!,
                  style: _style(12, FontWeight.w500, _mute),
                ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: _line),
      ],
    );
  }
}

class _SampleDaySection extends StatelessWidget {
  const _SampleDaySection({required this.onPrevious, required this.onNext});

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              sampleDayTitle,
              style: _style(18, FontWeight.w800, _ink),
            ),
            const Spacer(),
            _DayChevron(icon: Icons.chevron_left, onTap: onPrevious),
            _DayChevron(icon: Icons.chevron_right, onTap: onNext),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          sampleDaySubtitle,
          style: _style(13, FontWeight.w500, _mute),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.schedule_outlined, size: 20, color: _ink),
              const SizedBox(width: 10),
              Text(
                sampleFreeBanner,
                style: _style(14, FontWeight.w700, _ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < sampleTimeline.length; i++)
                _TimelineRow(
                  entry: sampleTimeline[i],
                  showDivider: i < sampleTimeline.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Free time is based on the calendars shown, within the hours above.',
          style: _style(12, FontWeight.w500, _mute),
        ),
      ],
    );
  }
}

class _DayChevron extends StatelessWidget {
  const _DayChevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: _ink),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.showDivider});

  final SampleTimelineEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 84,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    entry.timeLabel,
                    style: _style(
                      12,
                      FontWeight.w700,
                      entry.isFreeWindow ? _sage : _mute,
                    ),
                  ),
                ),
              ),
              Expanded(child: _TimelineBody(entry: entry)),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: _line),
      ],
    );
  }
}

class _TimelineBody extends StatelessWidget {
  const _TimelineBody({required this.entry});

  final SampleTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.isFreeWindow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _availableFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title,
                    style: _style(15, FontWeight.w800, _ink),
                  ),
                  Text(
                    entry.subtitle,
                    style: _style(13, FontWeight.w500, _mute),
                  ),
                ],
              ),
            ),
            const Icon(Icons.wb_sunny_outlined, size: 20, color: _sage),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _scheduledFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: _sage,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.title,
                  style: _style(15, FontWeight.w800, _ink),
                ),
                Text(
                  entry.subtitle,
                  style: _style(13, FontWeight.w500, _mute),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
