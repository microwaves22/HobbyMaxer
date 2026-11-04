import 'dart:ui';

import 'package:flutter/material.dart';

import 'ava_companion_data.dart';

const String _kFont = 'Nunito';

/// Figma "Ava Companion Drawer" (node 62:6040): Sparkle the unicorn's
/// care drawer over the kids dashboard.
///
/// LAYERING: render inside a `Stack` over the dashboard. Coordinates are
/// the 375-wide design values: scrim from top 145 (height 755), panel at
/// left 12 / top 148 / width 363 — the panel intentionally clips at the
/// right edge (right corners are 0). The panel runs to the overlay
/// bottom (INFERRED: the spec gives no panel height).
///
/// Sections, in order: identity header + close button, mood pills, care
/// stats, stacked care buttons, chore-care card, footer line. Spec
/// values are exact; anything the spec did not pin (panel padding/gaps,
/// pill/stat/subline text sizes, card radius, footer alignment) follows
/// the sibling-screen norms and is marked INFERRED.
///
/// This drawer is local mock content: no API calls, no persistence.
/// Tapping the scrim also closes (standard drawer dismiss; INFERRED).
class AvaCompanionDrawer extends StatelessWidget {
  const AvaCompanionDrawer({
    super.key,
    this.onCloseDrawer,
    this.onCareAction,
  });

  /// Close button / scrim tap. Placeholder.
  final VoidCallback? onCloseDrawer;

  /// Called with the care action id ('feed' or 'play'). Placeholder.
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
            behavior: HitTestBehavior.opaque,
            child: Container(
              key: const Key('ava-scrim'),
              color: const Color.fromRGBO(38, 57, 44, 0.14),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 148,
          width: 363,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
              child: Container(
                key: const Key('ava-panel'),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 252, 245, 0.95),
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0xFFFFFFFF)),
                  ),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderRow(onClose: onCloseDrawer),
                      const SizedBox(height: 12),
                      const _MoodPills(),
                      const SizedBox(height: 12),
                      const _CareStats(),
                      const SizedBox(height: 12),
                      _CareButtons(onCareAction: onCareAction),
                      const SizedBox(height: 12),
                      const _ChoreCareCard(),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Sparkle loves spending time with you. 💛',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: _kFont,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF7A9A85),
                          ),
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
}

/// Identity header: eyebrow + name left, 44px lavender close circle
/// right. The X color is INFERRED (ink).
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AVA'S COMPANION",
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: Color(0xFF7A9A85),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Meet Sparkle! ✨',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                  height: 1.2,
                  color: Color(0xFF2B3A2B),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          key: const Key('ava-close'),
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDDD5EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: Color(0xFF2B3A2B),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mood pills from [kAvaCompanionPills]. Pill text size/weight and
/// padding are INFERRED (11px ExtraBold, repo pill norm).
class _MoodPills extends StatelessWidget {
  const _MoodPills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < kAvaCompanionPills.length; i++)
          Container(
            key: Key('ava-pill-$i'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kAvaCompanionPills[i].background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              kAvaCompanionPills[i].label,
              style: TextStyle(
                fontFamily: _kFont,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: kAvaCompanionPills[i].foreground,
              ),
            ),
          ),
      ],
    );
  }
}

/// Care stat bars from [kAvaCareStats]: coral fills on 14px sageLight
/// tracks, widths driven by the percentages. Label type is INFERRED.
class _CareStats extends StatelessWidget {
  const _CareStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < kAvaCareStats.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    kAvaCareStats[i].label,
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF2B3A2B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${kAvaCareStats[i].percent}%',
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
                key: Key('ava-stat-${kAvaCareStats[i].id}-track'),
                height: 14,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EBDC),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: FractionallySizedBox(
                  widthFactor: kAvaCareStats[i].percent / 100,
                  child: Container(
                    key: Key('ava-stat-${kAvaCareStats[i].id}-fill'),
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE58B6D),
                      borderRadius: BorderRadius.circular(7),
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

/// Stacked care buttons from [kAvaCareActions]: min-height 86, radius
/// 23, ExtraBold 19 titles. Feed is sage with white text; Play is
/// lavender (ink text INFERRED). Icons: the apple has no Material
/// glyph, so the 🍎 glyph stands in; heart is `favorite_rounded`.
class _CareButtons extends StatelessWidget {
  const _CareButtons({required this.onCareAction});

  final ValueChanged<String>? onCareAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < kAvaCareActions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _CareButton(
            action: kAvaCareActions[i],
            onTap: () => onCareAction?.call(kAvaCareActions[i].id),
          ),
        ],
      ],
    );
  }
}

class _CareButton extends StatelessWidget {
  const _CareButton({required this.action, required this.onTap});

  final AvaCareAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFeed = action.id == 'feed';
    return GestureDetector(
      key: Key('ava-action-${action.id}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFeed
              ? const Color(0xFF7A9A85)
              : const Color(0xFFDDD5EE),
          borderRadius: BorderRadius.circular(23),
        ),
        child: Row(
          children: [
            if (isFeed)
              const Text('🍎', style: TextStyle(fontSize: 30))
            else
              const Icon(
                Icons.favorite_rounded,
                size: 30,
                color: Color(0xFF2B3A2B),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      height: 1.25,
                      color: isFeed
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF2B3A2B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subline,
                    style: TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isFeed
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF2B3A2B),
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

/// Yellow chore-care card with inventory pills. Card radius/padding,
/// heading/body type, and pill fills are INFERRED (sibling norms).
class _ChoreCareCard extends StatelessWidget {
  const _ChoreCareCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ava-chore-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0C8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Little chores, big magic!',
            style: TextStyle(
              fontFamily: _kFont,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.3,
              color: Color(0xFF2B3A2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Approved chores earn points and yummy care items for Sparkle.',
            style: TextStyle(
              fontFamily: _kFont,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF2B3A2B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < kAvaInventoryPills.length; i++)
                Container(
                  key: Key('ava-inventory-$i'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    kAvaInventoryPills[i],
                    style: const TextStyle(
                      fontFamily: _kFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF2B3A2B),
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
