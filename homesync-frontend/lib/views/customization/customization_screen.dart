import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/figma_tokens.dart';
import '../home/widgets/household_bottom_nav.dart';
import 'avatar_art.dart';
import 'customization_controller.dart';
import 'customization_data.dart';
import 'customization_store.dart';

/// Figma "10 Customization" (node 5:248): avatar ("For You") and
/// background ("Settings") pickers.
///
/// Sections, in order: Top Bar, Segmented Control, the active segment's
/// card (Profile Card for "For You", Background Card for "Settings"),
/// flexible spacer, Save Changes button, and the household bottom nav.
/// No inputs, no other cards.
///
/// Styling follows the Figma-screen precedent in this project: Nunito via
/// `fontFamily`, colors/shadows from [FigmaColors]/[FigmaShadows], a 38px
/// white-circle back button, and the Splash 54px primary-button pattern.
/// No status bar or phone frame is built here (device UI, like the other
/// HomeSync screens).
///
/// Selections persist locally via [CustomizationStore] and are published
/// to [CustomizationScope] when available, so applied surfaces (the
/// dashboard background) update live. Every handler is an optional
/// placeholder callback — this screen makes no API calls.
class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({
    super.key,
    this.onBack,
    this.onSegmentChange,
    this.onSelectAvatar,
    this.onSelectBackground,
    this.onSaveChanges,
    this.store,
  });

  /// Back button placeholder. Falls back to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Fires with the newly selected segment; state-only for now.
  final ValueChanged<CustomizationSegment>? onSegmentChange;

  /// Fires with the avatar id (`cat`, `fox`, `bunny`, `person`).
  final ValueChanged<String>? onSelectAvatar;

  /// Fires with the background id (`sky`, `meadow`, `sunset`, `night`).
  final ValueChanged<String>? onSelectBackground;

  /// Fires with the current [CustomizationSelection] placeholder.
  final ValueChanged<CustomizationSelection>? onSaveChanges;

  /// Local persistence. Defaults to [PrefsCustomizationStore]; inject
  /// [InMemoryCustomizationStore] in tests to avoid the prefs plugin.
  final CustomizationStore? store;

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  static const String _font = 'Nunito';

  late final CustomizationStore _store;

  CustomizationSegment _segment = CustomizationSegment.forYou;
  String _avatarId =
      avatarOptions.firstWhere((o) => o.selected, orElse: () => avatarOptions.first).id;
  String _backgroundId = backgroundOptions
      .firstWhere((o) => o.selected, orElse: () => backgroundOptions.first)
      .id;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? PrefsCustomizationStore();
    unawaited(_restore());
  }

  bool _scopeSynced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scopeSynced) return;
    _scopeSynced = true;
    // Prefer the live app-wide selection over the store so this screen
    // always opens on what is currently applied.
    final applied = CustomizationScope.maybeOf(context)?.selection;
    if (applied != null) {
      _segment = applied.segment;
      _avatarId = applied.avatarId;
      _backgroundId = applied.backgroundId;
    }
  }

  /// Applies the saved selection over the design defaults. Missing or
  /// corrupt data resolves to null and silently keeps the defaults.
  Future<void> _restore() async {
    final saved = await _store.load();
    if (!mounted || saved == null) return;
    setState(() {
      _segment = saved.segment;
      _avatarId = saved.avatarId;
      _backgroundId = saved.backgroundId;
    });
  }

  CustomizationSelection get _currentSelection => CustomizationSelection(
        segment: _segment,
        avatarId: _avatarId,
        backgroundId: _backgroundId,
      );

  /// Saves on every change without blocking the UI; failures are silent
  /// (the screen stays fully usable without persistence).
  Future<void> _persist() async {
    try {
      await _store.save(_currentSelection);
    } catch (_) {
      // Silent: the live defaults remain for this session.
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// Publishes the current selection app-wide so applied surfaces
  /// update live. No-op without a [CustomizationScope] (tests).
  void _publish() {
    final controller = CustomizationScope.maybeOf(context);
    if (controller != null) {
      unawaited(controller.update(_currentSelection));
    }
  }

  void _handleSegmentChange(CustomizationSegment segment) {
    setState(() => _segment = segment);
    unawaited(_persist());
    _publish();
    widget.onSegmentChange?.call(segment);
  }

  void _handleSelectAvatar(String avatarId) {
    setState(() => _avatarId = avatarId);
    unawaited(_persist());
    _publish();
    widget.onSelectAvatar?.call(avatarId);
  }

  void _handleSelectBackground(String backgroundId) {
    setState(() => _backgroundId = backgroundId);
    unawaited(_persist());
    _publish();
    widget.onSelectBackground?.call(backgroundId);
  }

  void _handleSave() {
    final selection = CustomizationSelection(
      segment: _segment,
      avatarId: _avatarId,
      backgroundId: _backgroundId,
    );
    _publish();
    if (widget.onSaveChanges != null) {
      widget.onSaveChanges!(selection);
    } else {
      unawaited(_persist());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customization saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.cream,
      bottomNavigationBar: const HouseholdBottomNav(activeTabId: null),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                    left: 20,
                    right: 20,
                    bottom: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(onBack: _handleBack),
                      const SizedBox(height: 12),
                      _SegmentedControl(
                        selected: _segment,
                        onSegmentChange: _handleSegmentChange,
                      ),
                      const SizedBox(height: 12),
                      // Each segment owns its card: avatar on "For You",
                      // background on "Settings".
                      if (_segment == CustomizationSegment.forYou)
                        _ProfileCard(
                          avatarId: _avatarId,
                          onSelectAvatar: _handleSelectAvatar,
                        )
                      else
                        _BackgroundCard(
                          backgroundId: _backgroundId,
                          onSelectBackground: _handleSelectBackground,
                        ),
                      const SizedBox(height: 12),
                      const Spacer(),
                      const SizedBox(height: 12),
                      _SaveButton(onSave: _handleSave),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White card with this screen's exact shadow
/// (`0px 5px 16px -4px rgba(59,77,56,0.09)`).
BoxDecoration _cardDecoration() => FigmaCards.whiteCard(radius: 24).copyWith(
      boxShadow: const [FigmaShadows.cardDeep],
    );

/// Top Bar: 38px white-circle back button, centered title, 38px spacer.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          key: const Key('customization-back'),
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FigmaColors.white,
              borderRadius: BorderRadius.circular(19),
              boxShadow: const [FigmaShadows.small],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: FigmaColors.ink,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Customization',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _CustomizationScreenState._font,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.3,
              color: FigmaColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 38, height: 38),
      ],
    );
  }
}

/// Segmented control: sagelight track, "For You" / "Settings".
class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onSegmentChange,
  });

  final CustomizationSegment selected;
  final ValueChanged<CustomizationSegment> onSegmentChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customization-segments'),
      decoration: BoxDecoration(
        color: FigmaColors.sageLight,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final segment in CustomizationSegment.values)
            Expanded(
              child: GestureDetector(
                key: Key('segment-${segment.name}'),
                onTap: () => onSegmentChange(segment),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    color: segment == selected
                        ? FigmaColors.sage
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    segment.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _CustomizationScreenState._font,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.3,
                      color: segment == selected
                          ? FigmaColors.white
                          : FigmaColors.sageDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Profile Card: heading, subtitle, crown + main avatar, avatar options.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.avatarId,
    required this.onSelectAvatar,
  });

  final String avatarId;
  final ValueChanged<String> onSelectAvatar;

  @override
  Widget build(BuildContext context) {
    final selected =
        avatarOptions.firstWhere((o) => o.id == avatarId);
    return Container(
      key: const Key('customization-profile-card'),
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _CustomizationScreenState._font,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.3,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Change your avatar and look!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _CustomizationScreenState._font,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.4,
              color: FigmaColors.mute,
            ),
          ),
          const SizedBox(height: 6),
          const CrownArt(),
          const SizedBox(height: 6),
          Container(
            key: const Key('customization-main-avatar'),
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: selected.background,
              borderRadius: BorderRadius.circular(56),
              border: Border.all(color: FigmaColors.sage, width: 4),
            ),
            alignment: Alignment.center,
            child: AvatarArt(avatarId: avatarId, size: 62),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < avatarOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => onSelectAvatar(avatarOptions[i].id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    key: Key('avatar-option-${avatarOptions[i].id}'),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: avatarOptions[i].background,
                      borderRadius: BorderRadius.circular(25),
                      border: avatarOptions[i].id == avatarId
                          ? Border.all(
                              color: FigmaColors.sage,
                              width: 3,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AvatarArt(
                      avatarId: avatarOptions[i].id,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Background Card: heading + four gradient tiles, one selected.
class _BackgroundCard extends StatelessWidget {
  const _BackgroundCard({
    required this.backgroundId,
    required this.onSelectBackground,
  });

  final String backgroundId;
  final ValueChanged<String> onSelectBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customization-background-card'),
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Background',
            style: TextStyle(
              fontFamily: _CustomizationScreenState._font,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.3,
              color: FigmaColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < backgroundOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        onSelectBackground(backgroundOptions[i].id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      key: Key(
                        'background-tile-${backgroundOptions[i].id}',
                      ),
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            backgroundOptions[i].gradientFrom,
                            backgroundOptions[i].gradientTo,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: backgroundOptions[i].id == backgroundId
                            ? Border.all(
                                color: FigmaColors.sage,
                                width: 3,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: backgroundOptions[i].id == backgroundId
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: FigmaColors.sage,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: FigmaColors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Primary action, following the Splash button pattern (54px tall,
/// radius 18, sage fill, white Nunito ExtraBold 16, sage shadow).
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customization-save'),
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [FigmaShadows.primaryButton],
      ),
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaColors.sage,
          foregroundColor: FigmaColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: _CustomizationScreenState._font,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontFamily: _CustomizationScreenState._font,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: FigmaColors.white,
          ),
        ),
      ),
    );
  }
}
