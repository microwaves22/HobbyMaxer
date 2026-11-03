import 'dart:ui';

import 'package:flutter/material.dart';

/// Noah companion drawer (Figma node 62:5907).
///
/// All values below are the real design — deliberately DIFFERENT from
/// Ava's drawer (62:6040), so this panel must not copy her styling:
/// 0.14 scrim from top 142, the left-rounded panel (blur 12, padding
/// 16, section gap 11), mute eyebrow, sageLight close button, sageLight
/// habitat, white wellbeing pills, 7px sage care bars, horizontal Feed
/// / Interact buttons, the single earn line, the Scout armor unlock,
/// and the 4-item "Make Ember yours" collection.
///
/// Layering: drop [NoahCompanionDrawer] over the Teen Home dashboard in
/// a [Stack] (it returns a [Stack] sized by its parent). No backend, no
/// persistence: actions only fire their handlers.
class NoahCompanionDrawer extends StatelessWidget {
  const NoahCompanionDrawer({
    super.key,
    this.nourishmentPercent = kNoahNourishmentPercent,
    this.energyPercent = kNoahEnergyPercent,
    this.carePercent = kNoahCarePercent,
    this.points = kNoahPoints,
    this.emberberries = kNoahEmberberries,
    this.collection = kNoahCollection,
    this.onCloseDrawer,
    this.onCareAction,
    this.onEquipArmor,
    this.onCollectionItemPress,
  });

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _mute = Color(0xFF7C877A);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _line = Color(0xFFE8E4D8);
  static const Color _lockedFill = Color(0xFFEDEEE8);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _scrim = Color.fromRGBO(38, 57, 44, 0.14);

  /// Panel surface: near-white with backdrop blur (the teen-context
  /// equivalent of Ava's frosted panel).
  static const Color _panelFill = Color.fromRGBO(255, 255, 255, 0.95);

  static const String _font = 'Nunito';

  /// Care percentages driving the pills and bars.
  final int nourishmentPercent;
  final int energyPercent;
  final int carePercent;

  /// Points balance shown in the header pill.
  final int points;

  /// Feed-button detail count.
  final int emberberries;

  /// Customization collection (default: the 4 real items).
  final List<NoahCollectionItem> collection;

  /// Called from the close button (and scrim tap).
  final VoidCallback? onCloseDrawer;

  /// Called with the care action id ('feed' or 'interact').
  final ValueChanged<String>? onCareAction;

  /// Called from the armor "Equip" button.
  final VoidCallback? onEquipArmor;

  /// Called with the collection item id.
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
            child: Container(color: _scrim),
          ),
        ),
        Positioned(
          left: 12,
          top: 145,
          width: 363,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _panelFill,
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.93),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 11),
                    _buildHabitat(),
                    const SizedBox(height: 11),
                    _buildWellbeing(),
                    const SizedBox(height: 11),
                    _buildStats(),
                    const SizedBox(height: 11),
                    _buildCareActions(),
                    const SizedBox(height: 11),
                    const Text(
                      'Approved chores earn points + care items for Ember.',
                      style: TextStyle(
                        fontFamily: _font,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: _mute,
                      ),
                    ),
                    const SizedBox(height: 11),
                    _buildArmorCard(),
                    const SizedBox(height: 11),
                    _buildCollection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NOAH'S COMPANION",
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: _mute,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Ember',
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$points pts',
                      style: const TextStyle(
                        fontFamily: _font,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCloseDrawer,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _sageLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: _ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitat() {
    return Container(
      height: 167,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _sageLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text('🐉', style: TextStyle(fontSize: 84)),
    );
  }

  Widget _buildWellbeing() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Thriving',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _sage,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '☾ Rested',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _sage,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$carePercent% care',
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _sage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStat('Nourishment', nourishmentPercent),
        const SizedBox(height: 8),
        _buildStat('Energy', energyPercent),
      ],
    );
  }

  Widget _buildStat(String label, int percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _ink,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 7,
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: _sage,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCareActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onCareAction == null
                ? null
                : () => onCareAction!('feed'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _sage,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍎', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Feed',
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.2,
                            color: _white,
                          ),
                        ),
                        Text(
                          '$emberberries emberberries',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            height: 1.2,
                            color: _white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onCareAction == null
                ? null
                : () => onCareAction!('interact'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _sageLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: _ink,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Interact',
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.2,
                            color: _ink,
                          ),
                        ),
                        Text(
                          'Bond with Ember',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _font,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            height: 1.2,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArmorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 27,
              color: _ink,
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
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: _sage,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Scout armor',
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
                Text(
                  'Custom armor · Chore streak reward',
                  style: TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: _mute,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEquipArmor,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _sage,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Equip',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Make Ember yours',
          style: TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: _ink,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
          children: [
            for (final item in collection) _buildCollectionItem(item),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionItem(NoahCollectionItem item) {
    return GestureDetector(
      onTap: onCollectionItemPress == null
          ? null
          : () => onCollectionItemPress!(item.id),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: item.locked ? _lockedFill : _white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: item.locked ? _mute : _ink,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: item.locked ? _mute : _ink,
                    ),
                  ),
                  Text(
                    item.state,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                      color: _mute,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One customization collection item.
class NoahCollectionItem {
  const NoahCollectionItem({
    required this.id,
    required this.name,
    required this.state,
    required this.icon,
    required this.locked,
  });

  final String id;
  final String name;
  final String state;
  final IconData icon;
  final bool locked;
}

/// Noah companion data (Figma 62:5907).
const int kNoahNourishmentPercent = 90;
const int kNoahEnergyPercent = 98;
const int kNoahCarePercent = 94;
const int kNoahPoints = 120;
const int kNoahEmberberries = 3;

/// Customization collection (Figma 62:5907): 4 items in a 2×2 grid.
const List<NoahCollectionItem> kNoahCollection = [
  NoahCollectionItem(
    id: 'forest-skin',
    name: 'Forest skin',
    state: 'Skin · Equipped',
    icon: Icons.palette_outlined,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'moss-copper',
    name: 'Moss & copper',
    state: 'Palette · Owned',
    icon: Icons.style_outlined,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'woodland-den',
    name: 'Woodland den',
    state: 'Background · Equipped',
    icon: Icons.home_outlined,
    locked: false,
  ),
  NoahCollectionItem(
    id: 'moonstone-den',
    name: 'Moonstone den',
    state: 'Locked · 180 pts',
    icon: Icons.lock_outline_rounded,
    locked: true,
  ),
];
