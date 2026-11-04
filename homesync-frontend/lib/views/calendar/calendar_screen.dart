import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../home/household_routes.dart';
import 'calendar_api.dart';
import 'calendar_data.dart';
import 'models/calendar_event.dart';

// Figma tokens (screen-only): hard-coded here because they differ from the
// shared theme (`AppColors` cream/sage/ink predate this design). Do not move
// them into the theme files: no other screen uses these values.
const _cream = Color(0xFFFBF7EF);
const _ink = Color(0xFF2B3A2B);
const _mute = Color(0xFF7C877A);
const _sage = Color(0xFF5F7F55);
const _sageDark = Color(0xFF4A6A41);
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
/// Explicit callbacks override the defaults; otherwise the header +
/// button opens an add-event form and tapping a block opens its detail,
/// both persisted to the backend when signed in. Day/Month timetable
/// content stays out of scope: the card always shows the week grid.
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

  /// Called with the tapped event id. Defaults to the detail dialog.
  final ValueChanged<String>? onEventPress;

  /// Called from the header "+" button. Defaults to the add-event form.
  final VoidCallback? onAddEvent;

  /// Called with the tapped bottom-nav tab id. When null, tabs switch
  /// with replacement (no-op for the calendar tab itself).
  final ValueChanged<String>? onNavigate;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _weekStart = CalendarData.designedWeekStart;
  DateTime _selectedDay = CalendarData.designedSelectedDay;
  CalendarView _view = CalendarView.week;

  /// Backend + locally added events, merged over the design timetable.
  List<CalendarEvent> _extraEvents = [];
  bool _remoteLoaded = false;

  /// Design events the user deleted locally (never on the server).
  final Set<String> _hiddenIds = {};

  /// Design fills reused for synced events, cycling by server id.
  static const _remotePalette = [
    Color(0xFFCFE0EE),
    Color(0xFFDDD5EE),
    Color(0xFFFDF0C8),
    Color(0xFFF6D9C4),
    Color(0xFFF4C9C9),
    Color(0xFF5F7F55),
    Color(0xFFE4EBDC),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_remoteLoaded) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _remoteLoaded = true;
    _loadRemote(session.client);
  }

  Future<void> _loadRemote(ApiClient client) async {
    try {
      final raw = await CalendarApi(client).fetchEvents();
      if (!mounted) return;
      final mapped = <CalendarEvent>[];
      for (final json in raw) {
        final event = _mapRemote(json);
        if (event != null) mapped.add(event);
      }
      setState(() => _extraEvents = mapped);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  /// Maps one backend event onto the week grid. Returns null when the
  /// event falls fully outside the 8 AM - 8 PM window.
  static CalendarEvent? _mapRemote(Map<String, dynamic> json) {
    final startsAt = DateTime.parse(json['starts_at'] as String).toLocal();
    final endsRaw = json['ends_at'] as String?;
    final endsAt = endsRaw == null
        ? startsAt.add(const Duration(hours: 1))
        : DateTime.parse(endsRaw).toLocal();
    final id = json['id'] as int;
    var start = startsAt.hour * 60 + startsAt.minute;
    var end = endsAt.hour * 60 + endsAt.minute;
    start = start.clamp(
        CalendarData.gridStartHour * 60, CalendarData.gridEndHour * 60);
    end = end.clamp(
        CalendarData.gridStartHour * 60, CalendarData.gridEndHour * 60);
    if (end <= start) return null;
    final color = _remotePalette[id % _remotePalette.length];
    return CalendarEvent(
      id: 'srv-$id',
      serverId: id,
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      date: DateTime(startsAt.year, startsAt.month, startsAt.day),
      startMinutes: start,
      endMinutes: end,
      color: color,
      textColor: color == _sage ? _white : _ink,
    );
  }

  List<CalendarEvent> _eventsForDay(DateTime day) => [
        ...CalendarData.eventsForDay(day).where((e) => !_hiddenIds.contains(e.id)),
        ..._extraEvents.where((e) => CalendarData.isSameDay(e.date, day)),
      ];

  CalendarEvent? _findEvent(String id) {
    for (final event in CalendarData.events) {
      if (event.id == id) return event;
    }
    for (final event in _extraEvents) {
      if (event.id == id) return event;
    }
    return null;
  }

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
    HouseholdRoutes.openTab(context, tabId);
  }

  Future<void> _defaultAddEvent() async {
    final draft = await showDialog<_EventDraft>(
      context: context,
      builder: (_) => _AddEventDialog(day: _selectedDay),
    );
    if (draft == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final session = AuthScope.maybeOf(context);
    final day = _selectedDay;
    final startsAt = DateTime(
        day.year, day.month, day.day, draft.start.hour, draft.start.minute);
    final endsAt = DateTime(
        day.year, day.month, day.day, draft.end.hour, draft.end.minute);
    if (session != null && session.isAuthenticated) {
      try {
        final json = await CalendarApi(session.client).createEvent(
          title: draft.title,
          startsAt: startsAt,
          endsAt: endsAt,
        );
        final event = _mapRemote(json);
        if (event != null && mounted) setState(() => _extraEvents.add(event));
      } on ApiException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
    } else {
      setState(() => _extraEvents.add(CalendarEvent(
            id: 'local-${DateTime.now().microsecondsSinceEpoch}',
            title: draft.title,
            date: DateTime(day.year, day.month, day.day),
            startMinutes: draft.start.hour * 60 + draft.start.minute,
            endMinutes: draft.end.hour * 60 + draft.end.minute,
            color: const Color(0xFFCFE0EE),
            textColor: _ink,
          )));
    }
    messenger.showSnackBar(const SnackBar(content: Text('Event added.')));
  }

  Future<void> _defaultEventPress(String id) async {
    final event = _findEvent(id);
    if (event == null) return;
    final delete = await showDialog<bool>(
      context: context,
      builder: (_) => _EventDetailDialog(event: event),
    );
    if (delete != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final session = AuthScope.maybeOf(context);
    final serverId = event.serverId;
    if (session != null && session.isAuthenticated && serverId != null) {
      try {
        await CalendarApi(session.client).deleteEvent(serverId);
      } on ApiException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
    }
    setState(() {
      _extraEvents.removeWhere((e) => e.id == id);
      _hiddenIds.add(id);
    });
    messenger.showSnackBar(const SnackBar(content: Text('Event deleted.')));
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
              _HeaderRow(onAddEvent: widget.onAddEvent ?? _defaultAddEvent),
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
                onEventPress: widget.onEventPress ?? _defaultEventPress,
                eventsForDay: _eventsForDay,
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
              fontSize: 26,
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
              width: 38,
              height: 38,
              child: Icon(Icons.add, size: 20, color: _white),
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
    this.eventsForDay,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<String>? onEventPress;
  final List<CalendarEvent> Function(DateTime)? eventsForDay;

  static const double _hourHeight = 21;
  static const double _gutterWidth = 44;

  List<CalendarEvent> _resolve(DateTime day) =>
      eventsForDay?.call(day) ?? CalendarData.eventsForDay(day);

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
                                events: _resolve(day),
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
/// The design shows no greying of adjacent-month days and no today
/// marker, so every number renders the same unless selected (sage fill).
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
    return Row(
      children: [
        SizedBox(width: gutterWidth),
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: _DayCell(
              name: CalendarData.weekdayNames[i],
              day: days[i],
              selected: CalendarData.isSameDay(days[i], selectedDay),
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
    required this.onTap,
  });

  final String name;
  final DateTime day;
  final bool selected;
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
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
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
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.3,
                    color: _sageDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  CalendarData.plannerBody,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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

/// Draft for the add-event form: title plus start/end times on the day.
class _EventDraft {
  const _EventDraft({required this.title, required this.start, required this.end});

  final String title;
  final TimeOfDay start;
  final TimeOfDay end;
}

/// Add-event form for the selected day. Times stay inside the 8 AM -
/// 8 PM grid window so the new block always renders.
class _AddEventDialog extends StatefulWidget {
  const _AddEventDialog({required this.day});

  final DateTime day;

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleController = TextEditingController();
  TimeOfDay _start = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 19, minute: 0);
  String? _error;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pick(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
        _error = null;
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final start = _minutes(_start);
    final end = _minutes(_end);
    final lo = CalendarData.gridStartHour * 60;
    final hi = CalendarData.gridEndHour * 60;
    String? error;
    if (title.isEmpty) {
      error = 'Enter an event title.';
    } else if (start < lo || end > hi) {
      error = 'Keep times between 8:00 AM and 8:00 PM.';
    } else if (end <= start) {
      error = 'End time must be after the start.';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_EventDraft(title: title, start: _start, end: _end));
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    return AlertDialog(
      title: const Text('Add event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}'),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Event title'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pick(true),
                  child: Text(_start.format(context)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(''),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pick(false),
                  child: Text(_end.format(context)),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

/// Event detail with its time range and a delete action.
class _EventDetailDialog extends StatelessWidget {
  const _EventDetailDialog({required this.event});

  final CalendarEvent event;

  static String _clock(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final twelve = hour % 12 == 0 ? 12 : hour % 12;
    return '$twelve:${minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final description = event.description;
    return AlertDialog(
      title: Text(event.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text('${_clock(event.startMinutes)}  ${_clock(event.endMinutes)}'),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
