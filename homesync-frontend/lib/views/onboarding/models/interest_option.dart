import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// One selectable interest on the onboarding interests screen.
class InterestOption {
  const InterestOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.selected = false,
  });

  final String id;
  final String title;
  final String description;

  /// Icon from the project's existing icon sets (Material / Cupertino).
  final IconData icon;

  /// Initial selection state; the screen copies this into live state.
  final bool selected;
}

/// The four interests, rendered in order. Rows 1-2 start selected.
const kInterestOptions = <InterestOption>[
  InterestOption(
    id: 'calendar',
    title: 'Calendar coordination',
    description: 'Keep everyone on the same page.',
    icon: Icons.calendar_month_rounded,
    selected: true,
  ),
  InterestOption(
    id: 'chores',
    title: 'Chore distribution',
    description: 'Share the load, fairly.',
    icon: Icons.checklist_rounded,
    selected: true,
  ),
  InterestOption(
    id: 'rewards',
    title: 'Task rewards',
    description: 'Celebrate the everyday wins.',
    icon: CupertinoIcons.gift,
  ),
  InterestOption(
    id: 'homework',
    title: 'Homework tracking',
    description: 'Make room for learning.',
    icon: Icons.menu_book_rounded,
  ),
];
