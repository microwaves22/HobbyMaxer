import 'package:flutter/material.dart';

import 'calendar_data.dart';
import 'models/calendar_event.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _cream = Color(0xFFFBF7EF);
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF5F7F55);
const _line = Color(0xFFE8E4D8);
const _white = Color(0xFFFFFFFF);

// Borrowed from the sibling Figma screen (profile hub, node 62:5787): the
// same design system already defines these shades.
const _sageLight = Color(0xFFE4EBDC);
const _navFill = Color.fromRGBO(255, 255, 255, 0.8);

// Estimated from the design screenshot (no Inspect values available):
// timetable card fill, Work blue, Dr. purple, planner sparkle gold.
const _gridCard = Color(0xFFF3EDE0);
const _sparkGold = Color(0xFFE0A83C);

/// Figma "06 Calendar" (node 4:121): week timetable with a Day/Week/Month
/// switcher, week navigation, event blocks, a Smart Planner note, and the
/// household bottom navigation with the calendar tab active.
///
/// Content (titles, days, labels, copy) is transcribed from the design.
/// Sizes, gaps, and the estimated colors above are read from the design
/// screenshot; see the delivery report for the flagged estimates.
///
/// All callbacks are placeholders: local UI state only, no backend, no
/// persistence. Day/Month timetable content is out of scope (separate
/// screens); the card always shows the week grid.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.onSelectDay,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onViewChange,
    this.onEventPress,
    this.onAddEvent,
    this.onNavigate,
  });

  /// Called with the tapped day. Updates the selected state.
  final ValueChanged<DateTime>? onSelectDay;

  /// Called after moving to the previous week.
  final VoidCallback? onPreviousWeek;

  /// Called after moving to the next week.
  final VoidCallback? onNextWeek;

  /// Called with the newly selected Day/Week/Month view.
  final ValueChanged<CalendarView>? onViewChange;

  /// Called with the tapped event id. No detail screen exists yet.
  final ValueChanged<String>? onEventPress;

  /// Called from the header "+" button. No event form exists yet.
  final VoidCallback? onAddEvent;

  /// Called with the tapped bottom-nav tab id. Defaults to a no-op for
  /// the calendar tab and a placeholder for the other tabs.
  final ValueChanged<String>? onNavigate;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _weekStart = CalendarData.designedWeekStart;
  DateTime _selectedDay = CalendarData.designedSelectedDay;
  CalendarView _view = CalendarView.week;

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
    widget.onSelectDay?.call(day);
  }

  void _previousWeek() {
    setState(() => _weekStart = CalendarData.shiftWeek(_weekStart, -1));
    widget.onPreviousWeek?.call();
  }

  void _nextWeek() {
    setState(() => _weekStart = CalendarData.shiftWeek(_weekStart, 1));
    widget.onNextWeek?.call();
  }

  void _changeView(CalendarView view) {
    setState(() => _view = view);
    widget.onViewChange?.call(view);
  }

  void _handleNavigate(String tabId) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(tabId);
      return;
    }
    if (tabId == 'calendar') return; // Already on Calendar.
    // TODO: push the Home/Tasks/Family screen once wired from here.
  }

  @override
  Widget build(BuildContext context) {
    final days = CalendarData.weekDays(_weekStart);
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderRow(onAddEvent: widget.onAddEvent),
              const SizedBox(height: 16),
              _ViewSwitcher(
                activeView: _view,
                onViewChange: _changeView,
              ),
              const SizedBox(height: 14),
              _WeekNavRow(
                weekStart: _weekStart,
                onPrevious: _previousWeek,
                onNext: _nextWeek,
              ),
              const SizedBox(height: 12),
              _WeekCard(
                days: days,
                selectedDay: _selectedDay,
                onSelectDay: _selectDay,
                onEventPress: widget.onEventPress,
              ),
              const SizedBox(height: 16),
              const _SmartPlannerCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _BottomNav(onNavigate: _handleNavigate),
      ),
    );
  }
}

/// Header: "Calendar" title plus the circular add-event button.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onAddEvent});

  final VoidCallback? onAddEvent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Calendar',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.25,
              color: _ink,
            ),
          ),
        ),
        Material(
          color: _sage,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAddEvent,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.add, size: 26, color: _white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Day / Week / Month segmented control. Week is selected in the design.
class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.activeView,
    required this.onViewChange,
  });

  final CalendarView activeView;
  final ValueChanged<CalendarView> onViewChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final view in CalendarView.values)
            Expanded(
              child: _ViewSegment(
                view: view,
                selected: view == activeView,
                onTap: () => onViewChange(view),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewSegment extends StatelessWidget {
  const _ViewSegment({
    required this.view,
    required this.selected,
    required this.onTap,
  });

  final CalendarView view;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _sage : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          calendarViewLabels[view]!,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.3,
            color: selected ? _white : _ink,
          ),
        ),
      ),
    );
  }
}

/// Week navigation: previous chevron, centered range label, next chevron.
class _WeekNavRow extends StatelessWidget {
  const _WeekNavRow({
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ChevronButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
        ),
        Expanded(
          child: Text(
            CalendarData.weekRangeLabel(weekStart),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.3,
              color: _ink,
            ),
          ),
        ),
        _ChevronButton(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 32,
        child: Icon(icon, size: 22, color: _ink),
      ),
    );
  }
}

/// Timetable card: weekday header plus the 8 AM – 8 PM week grid.
/// The grid is generated from [days] and [CalendarData.events]; no
/// hard-coded day or event widgets.
class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.days,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onEventPress,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<String>? onEventPress;

  static const double _hourHeight = 30;
  static const double _gutterWidth = 44;

  double get _gridHeight =>
      (CalendarData.gridEndHour - CalendarData.gridStartHour) *
      _hourHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: _gridCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WeekdayHeader(
            days: days,
            selectedDay: selectedDay,
            gutterWidth: _gutterWidth,
            onSelectDay: onSelectDay,
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: _line),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimeGutter(
                width: _gutterWidth,
                height: _gridHeight,
                hourHeight: _hourHeight,
              ),
              Expanded(
                child: SizedBox(
                  height: _gridHeight,
                  child: Stack(
                    children: [
                      for (
                        var hour = CalendarData.gridStartHour;
                        hour <= CalendarData.gridEndHour;
                        hour += 2
                      )
                        Positioned(
                          top:
                              (hour - CalendarData.gridStartHour) *
                              _hourHeight,
                          left: 0,
                          right: 0,
                          child: Container(height: 1, color: _line),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final day in days)
                            Expanded(
                              child: _DayColumn(
                                events: CalendarData.eventsForDay(day),
                                hourHeight: _hourHeight,
                                onEventPress: onEventPress,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Weekday names over day numbers; tapping a number selects the day.
/// The design shows no greying of adjacent-month days, so every number
/// renders the same unless selected (sage fill) or today (sage ring).
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({
    required this.days,
    required this.selectedDay,
    required this.gutterWidth,
    required this.onSelectDay,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final double gutterWidth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Row(
      children: [
        SizedBox(width: gutterWidth),
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: _DayCell(
              name: CalendarData.weekdayNames[i],
              day: days[i],
              selected: CalendarData.isSameDay(days[i], selectedDay),
              isToday: CalendarData.isSameDay(days[i], today),
              onTap: () => onSelectDay(days[i]),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.name,
    required this.day,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final String name;
  final DateTime day;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final numberColor = selected ? _white : _ink;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.3,
              color: _mute,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? _sage : Colors.transparent,
              border: !selected && isToday
                  ? Border.all(color: _sage, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
                color: numberColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Time gutter: "8 AM" … "8 PM" labels aligned to the grid lines.
class _TimeGutter extends StatelessWidget {
  const _TimeGutter({
    required this.width,
    required this.height,
    required this.hourHeight,
  });

  final double width;
  final double height;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          for (
            var hour = CalendarData.gridStartHour;
            hour <= CalendarData.gridEndHour;
            hour += 2
          )
            Positioned(
              top:
                  (hour - CalendarData.gridStartHour) * hourHeight -
                  8,
              left: 0,
              child: Text(
                CalendarData.gutterLabels[(hour -
                        CalendarData.gridStartHour) ~/
                    2],
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.45,
                  color: _mute,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One day column of the grid: the day's event blocks positioned by time.
class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.events,
    required this.hourHeight,
    required this.onEventPress,
  });

  final List<CalendarEvent> events;
  final double hourHeight;
  final ValueChanged<String>? onEventPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final event in events)
          Positioned(
            top:
                (event.startMinutes -
                        CalendarData.gridStartHour * 60) /
                    60 *
                    hourHeight,
            left: 2,
            right: 2,
            height:
                (event.endMinutes - event.startMinutes) /
                    60 *
                    hourHeight -
                3,
            child: _EventBlock(
              event: event,
              onTap: onEventPress == null
                  ? null
                  : () => onEventPress!(event.id),
            ),
          ),
      ],
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({required this.event, required this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          color: event.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.3,
            color: event.textColor,
          ),
        ),
      ),
    );
  }
}

/// Smart Planner note card, verbatim copy from the design.
class _SmartPlannerCard extends StatelessWidget {
  const _SmartPlannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _white,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 24,
              color: _sparkGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  CalendarData.plannerTitle,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.3,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  CalendarData.plannerBody,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One bottom-navigation tab.
class _NavTab {
  const _NavTab({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

/// Bottom-nav tabs, copied from the existing household navigation
/// (profile hub): same items, order, icons, and labels.
const _navTabs = <_NavTab>[
  _NavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(
    id: 'calendar',
    label: 'Calendar',
    icon: Icons.calendar_month_rounded,
  ),
  _NavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// Bottom navigation, replicating the existing household bar
/// (profile hub `_BottomNav`): same fill, padding, icon size, label
/// style, and active/inactive colors. Calendar is the active tab.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navFill,
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final tab in _navTabs)
            _NavTabButton(
              tab: tab,
              active: tab.id == 'calendar',
              onTap: () => onNavigate(tab.id),
            ),
        ],
      ),
    );
  }
}

/// One bottom-navigation tab: 64px wide, icon over label.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _sage : _mute;
    return Semantics(
      label: tab.label,
      button: true,
      selected: active,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 23, color: color),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                    height: 1.35,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
