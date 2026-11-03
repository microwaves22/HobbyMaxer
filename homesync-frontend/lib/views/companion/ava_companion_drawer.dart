import 'dart:ui';

import 'package:flutter/material.dart';

/// Ava companion drawer (Figma node 62:6040).
///
/// All values below are the real design: 0.14 scrim from top 145, the
/// left-rounded panel (left 12 / top 148 / width 363, right edge
/// clipped), lavender close button, mood pills, coral care bars, the
/// Feed/Play buttons, the yellow chore-care card, and the verbatim
/// footer.
///
/// Layering: drop [AvaCompanionDrawer] over the dashboard in a [Stack]
/// (it returns a [Stack] sized by its parent). No backend, no
/// persistence: care actions only fire [onCareAction].
class AvaCompanionDrawer extends StatelessWidget {
  const AvaCompanionDrawer({
    super.key,
    this.carePercent = kAvaCarePercent,
    this.energyPercent = kAvaEnergyPercent,
    this.points = kAvaPoints,
    this.apples = kAvaApples,
    this.toys = kAvaToys,
    this.onCloseDrawer,
    this.onCareAction,
  });

  static const Color _ink = Color(0xFF2B3A2B);
  static const Color _sage = Color(0xFF5F7F55);
  static const Color _sageLight = Color(0xFFE4EBDC);
  static const Color _yellowLight = Color(0xFFFDF0C8);
  static const Color _lavender = Color(0xFFDDD5EE);
  static const Color _coral = Color(0xFFE58B6D);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _scrim = Color.fromRGBO(38, 57, 44, 0.14);
  static const Color _panelFill = Color.fromRGBO(255, 252, 245, 0.95);

  static const String _font = 'Nunito';

  /// Care + energy percentages driving the pills and bars.
  final int carePercent;
  final int energyPercent;

  /// Points balance shown in the mood pills.
  final int points;

  /// Inventory counts driving the chore-care pills.
  final int apples;
  final int toys;

  /// Called from the close button (and scrim tap).
  final VoidCallback? onCloseDrawer;

  /// Called with the care action id ('feed' or 'play').
  final ValueChanged<String>? onCareAction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 145,
          height: 755,
          child: GestureDetector(
            onTap: onCloseDrawer,
            child: Container(color: _scrim),
          ),
        ),
        Positioned(
          left: 12,
          top: 148,
          width: 363,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(38, 57, 44, 0.15),
                  offset: Offset(0, 8),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _panelFill,
                    border: Border.all(color: _white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildPills(),
                      const SizedBox(height: 16),
                      _buildStats(),
                      const SizedBox(height: 16),
                      _buildCareButtons(),
                      const SizedBox(height: 16),
                      _buildChoreCard(),
                      const SizedBox(height: 16),
                      const Text(
                        'Sparkle loves spending time with you. 💛',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: _sage,
                        ),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AVA'S COMPANION",
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: _sage,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Meet Sparkle! ✨',
                style: TextStyle(
                  fontFamily: _font,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCloseDrawer,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _lavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: _ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPills() {
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
          child: Text(
            'Care $carePercent%',
            style: const TextStyle(
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
            color: _yellowLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '😊 Happy',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _yellowLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '★ $points pts',
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _ink,
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
        _buildStat('Care', carePercent),
        const SizedBox(height: 10),
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
                fontSize: 13,
                color: _ink,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: _font,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: _sageLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: _coral,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCareButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onCareAction == null
              ? null
              : () => onCareAction!('feed'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 86),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _sage,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                const Text('🍎', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Feed',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          color: _white,
                        ),
                      ),
                      Text(
                        '🍎 $apples apples',
                        style: const TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
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
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onCareAction == null
              ? null
              : () => onCareAction!('play'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 86),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 28,
                  color: _ink,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Play',
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          color: _ink,
                        ),
                      ),
                      Text(
                        "Let's have fun!",
                        style: TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
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
      ],
    );
  }

  Widget _buildChoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _yellowLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Little chores, big magic!',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Approved chores earn points and yummy care items for Sparkle.',
            style: TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.4,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
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
                  '🍎 Apples ×$apples',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _ink,
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
                  '🧸 Toys ×$toys',
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
    );
  }
}

/// Ava companion data (Figma 62:6040).
const int kAvaCarePercent = 80;
const int kAvaEnergyPercent = 90;
const int kAvaPoints = 120;
const int kAvaApples = 3;
const int kAvaToys = 2;
