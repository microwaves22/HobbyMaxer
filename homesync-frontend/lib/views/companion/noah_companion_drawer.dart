import 'dart:ui';

import 'package:flutter/material.dart';

import 'noah_companion_data.dart';

const String _kFont = 'Nunito';

/// Figma "Noah Companion Drawer" (node 62:5907): Ember the baby dragon's
/// care drawer over the teen home screen.
///
/// LAYERING: render inside a `Stack` over the dashboard. Scrim from top
/// 142 (height 838). Panel geometry mirrors Ava's drawer (left 12 /
/// width 363, right corners 0 so it clips at the 375-wide right edge)
/// with its own radius-28 left corners, near-white border, and 12px
/// blur — panel position, fill, and shadow are INFERRED (the spec pins
/// only radius/border/blur/padding/gap): top 145 (scrim top + 3, as on
/// Ava's), white 0.95 fill, bottom-anchored, NO shadow (spec-literal).
///
/// Sections, in order: identity header, habitat panel, wellbeing pills,
/// care stats, horizontal care actions, earn line, armor unlock card,
/// "Make Ember yours" collection. Do NOT copy Ava's drawer styling —
/// this panel deliberately differs (mute eyebrow, sage stat fills,
/// horizontal actions, no Play, armor + collection instead of a
/// chore card).
///
/// Local mock content: no API calls, no persistence. Tapping the scrim
/// also closes (standard drawer dismiss; INFERRED).
class NoahCompanionDrawer extends StatelessWidget {
  const NoahCompanionDrawer({
    super.key,
    this.onCloseDrawer,
    this.onCareAction,
    this.onEquipArmor,
    this.onCollectionItemPress,
  });

  /// Close button / scrim tap. Placeholder.
  final VoidCallback? onCloseDrawer;

  /// Called with the care action id ('feed' or 'interact'). Placeholder.
  final ValueChanged<String>? onCareAction;

  /// Armor "Equip" button. Placeholder.
  final VoidCallback? onEquipArmor;

  /// Called with the collection item id, locked or not (the parent
  /// decides the feedback — e.g. a "locked" hint). Placeholder.
  final ValueChanged<String>? onCollectionItemPress;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 142,
          height: 838,
          child: GestureDetector(
            onTap: onCloseDrawer,
            behavior: HitTestBehavior.opaque,
            child: Container(
              key: const Key('noah-scrim'),
              color: const Color.fromRGBO(38, 57, 44, 0.14),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 145,
          width: 363,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                key: const Key('noah-panel'),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.93),
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderRow(onClose: onCloseDrawer),
                      const SizedBox(height: 11),
                      const _HabitatPanel(),
                      const SizedBox(height: 11),
                      const _WellbeingPills(),
                      const SizedBox(height: 11),
                      const _CareStats(),
                      const SizedBox(height: 11),
                      _CareActions(onCareAction: onCareAction),
                      const SizedBox(height: 11),
                      const Text(
                        'Approved chores earn points + care items for Ember.',
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF7C877A),
                        ),
                      ),
                      const SizedBox(height: 11),
                      _ArmorCard(onEquip: onEquipArmor),
                      const SizedBox(height: 11),
                      _CollectionGrid(
                        onItemPress: onCollectionItemPress,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Identity header: mute eyebrow, then name + white "120 pts" pill
/// (NO star) + 32px sageLight close button. Pill type and X color are
/// INFERRED.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NOAH'S COMPANION",
          style: TextStyle(
            fontFamily: _kFont,
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: Color(0xFF7C877A),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'Ember',
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                height: 1.2,
                color: Color(0xFF2B3A2B),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              key: const Key('noah-points-pill'),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '120 pts',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: Color(0xFF4A6A41),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              key: const Key('noah-close'),
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EBDC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF2B3A2B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Habitat panel: 167px tall, radius 22, sageLight behind the Ember art.
///
/// TODO(asset): no Ember dragon PNG exists in `assets/` yet — the paw
/// glyph below is a stand-in. Drop the export in and render it here
/// (fit + alignment from the frame).
class _HabitatPanel extends StatelessWidget {
  const _HabitatPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('noah-habitat'),
      height: 167,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE4EBDC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.pets_rounded,
        size: 48,
        color: Color(0xFF4A6A41),
      ),
    );
  }
}

/// Wellbeing pills from [kNoahCompanionPills]. Pill text size/weight
/// and padding are INFERRED (11px ExtraBold, repo pill norm).
class _WellbeingPills extends StatelessWidget {
  const _WellbeingPills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < kNoahCompanionPills.length; i++)
          Container(
            key: Key('noah-pill-$i'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kNoahCompanionPills[i].background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              kNoahCompanionPills[i].label,
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: kNoahCompanionPills[i].foreground,
              ),
            ),
          ),
      ],
    );
  }
}

/// Care stat bars from [kNoahCareStats]: sage fills on 7px sageLight
/// tracks (NOT Ava's 14px coral), widths driven by the percentages.
/// Label type is INFERRED.
class _CareStats extends StatelessWidget {
  const _CareStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kNoahCareStats.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    kNoahCareStats[i].label,
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF2B3A2B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${kNoahCareStats[i].percent}%',
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFF2B3A2B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                key: Key('noah-stat-${kNoahCareStats[i].id}-track'),
                height: 7,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EBDC),
                  borderRadius: BorderRadius.circular(3.5),
                ),
                child: FractionallySizedBox(
                  widthFactor: kNoahCareStats[i].percent / 100,
                  child: Container(
                    key: Key('noah-stat-${kNoahCareStats[i].id}-fill'),
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5F7F55),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Horizontal care actions: two 50px buttons side by side (NOT
/// Ava's stacked tiles) and NO Play action. Both show a title plus a
/// detail line: Feed with "3 emberberries" (no emoji), Interact with
/// "Bond with Ember".
///
/// Button radius, gaps, icon sizes, and all button type are INFERRED.
class _CareActions extends StatelessWidget {
  const _CareActions({required this.onCareAction});

  final ValueChanged<String>? onCareAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            key: const Key('noah-action-feed'),
            onTap: () => onCareAction?.call('feed'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF5F7F55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🍎', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feed',
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      Text(
                        '3 emberberries',
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.2,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            key: const Key('noah-action-interact'),
            onTap: () => onCareAction?.call('interact'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE4EBDC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 22,
                    color: Color(0xFF4A6A41),
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interact',
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                          color: Color(0xFF4A6A41),
                        ),
                      ),
                      Text(
                        'Bond with Ember',
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.2,
                          color: Color(0xFF4A6A41),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Armor unlock card. The card fill is INFERRED (sageLight — the white
/// preview tile needs contrast), as are card radius/padding, all card
/// type, the shield color, and the Equip button's padding/type.
class _ArmorCard extends StatelessWidget {
  const _ArmorCard({required this.onEquip});

  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('noah-armor-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EBDC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 27,
              color: Color(0xFF5F7F55),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEWLY UNLOCKED · OWNED',
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: Color(0xFF5F7F55),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Scout armor',
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.25,
                    color: Color(0xFF2B3A2B),
                  ),
                ),
                Text(
                  'Custom armor · Chore streak reward',
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF7C877A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            key: const Key('noah-armor-equip'),
            onTap: onEquip,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF5F7F55),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Equip',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Make Ember yours" 2×2 collection grid from [kNoahCollection].
/// Unlocked tiles are white; the locked tile is #EDEEE8 with mute
/// state text (its name stays ink — spec-literal). Names are
/// ExtraBold 11, states Medium 9, all tiles have 1px line borders.
/// Grid spacing, tile radius/padding/layout, and icon size/colors are
/// INFERRED. Locked tiles still report taps (with their id).
class _CollectionGrid extends StatelessWidget {
  const _CollectionGrid({required this.onItemPress});

  final ValueChanged<String>? onItemPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Make Ember yours',
          style: TextStyle(
            fontFamily: _kFont,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            height: 1.3,
            color: Color(0xFF2B3A2B),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in kNoahCollection)
              GestureDetector(
                key: Key('noah-collection-${item.id}'),
                onTap: () => onItemPress?.call(item.id),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.locked
                        ? const Color(0xFFEDEEE8)
                        : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: const Border.fromBorderSide(
                      BorderSide(color: Color(0xFFE8E4D8)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: item.locked
                            ? const Color(0xFF7C877A)
                            : const Color(0xFF5F7F55),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1.25,
                          color: Color(0xFF2B3A2B),
                        ),
                      ),
                      Text(
                        item.state,
                        style: TextStyle(
                          fontFamily: _kFont,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                          height: 1.3,
                          color: item.locked
                              ? const Color(0xFF7C877A)
                              : const Color(0xFF5F7F55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
