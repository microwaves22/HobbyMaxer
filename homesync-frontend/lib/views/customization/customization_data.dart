import 'package:flutter/material.dart';

import '../../core/theme/figma_tokens.dart';

/// Data for Figma "10 Customization" (node 5:248).
///
/// Local state only: the screen reads the defaults from [avatarOptions]
/// and [backgroundOptions] and keeps the current choice in widget state.
/// Nothing here touches the backend.
enum CustomizationSegment { forYou, settings }

extension CustomizationSegmentLabel on CustomizationSegment {
  /// Verbatim segment labels.
  String get label => switch (this) {
        CustomizationSegment.forYou => 'For You',
        CustomizationSegment.settings => 'Settings',
      };
}

/// One avatar option. [selected] marks the default selection.
class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.background,
    this.selected = false,
  });

  final String id;
  final Color background;
  final bool selected;
}

/// Avatar options in design order: cat (default), fox, bunny, person.
const List<AvatarOption> avatarOptions = [
  AvatarOption(
    id: 'cat',
    background: FigmaColors.pastelPink,
    selected: true,
  ),
  AvatarOption(
    id: 'fox',
    background: FigmaColors.pastelPeach,
  ),
  AvatarOption(
    id: 'bunny',
    background: FigmaColors.pastelBlue,
  ),
  AvatarOption(
    id: 'person',
    background: FigmaColors.pastelLavender,
  ),
];

/// One background tile. Gradients run top -> bottom ([gradientFrom] at
/// the top). [selected] marks the default selection.
class BackgroundOption {
  const BackgroundOption({
    required this.id,
    required this.gradientFrom,
    required this.gradientTo,
    this.selected = false,
  });

  final String id;
  final Color gradientFrom;
  final Color gradientTo;
  final bool selected;
}

/// Background tiles in design order: sky, meadow (default), sunset, night.
const List<BackgroundOption> backgroundOptions = [
  BackgroundOption(
    id: 'sky',
    gradientFrom: FigmaColors.skyTop,
    gradientTo: FigmaColors.skyBottom,
  ),
  BackgroundOption(
    id: 'meadow',
    gradientFrom: FigmaColors.meadowTop,
    gradientTo: FigmaColors.meadowBottom,
    selected: true,
  ),
  BackgroundOption(
    id: 'sunset',
    gradientFrom: FigmaColors.sunsetTop,
    gradientTo: FigmaColors.sunsetBottom,
  ),
  BackgroundOption(
    id: 'night',
    gradientFrom: FigmaColors.nightTop,
    gradientTo: FigmaColors.nightBottom,
  ),
];

/// Current local selections, delivered to `onSaveChanges`.
@immutable
class CustomizationSelection {
  const CustomizationSelection({
    required this.segment,
    required this.avatarId,
    required this.backgroundId,
  });

  final CustomizationSegment segment;
  final String avatarId;
  final String backgroundId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizationSelection &&
          other.segment == segment &&
          other.avatarId == avatarId &&
          other.backgroundId == backgroundId;

  @override
  int get hashCode => Object.hash(segment, avatarId, backgroundId);

  @override
  String toString() =>
      'CustomizationSelection(segment: ${segment.name}, '
      'avatarId: $avatarId, backgroundId: $backgroundId)';
}
