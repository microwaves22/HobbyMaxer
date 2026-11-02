import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../../core/widgets/profile_avatar_dropdown.dart';
import '../onboarding/models/family_member.dart';

/// Minimal landing screen after onboarding. Shows the active profile in
/// the top-right corner and a summary of the onboarding choices.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.members = const [],
    this.focusAreas = const [],
  });

  final List<FamilyMember> members;
  final List<String> focusAreas;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProfileOption _active;

  @override
  void initState() {
    super.initState();
    _active = _options().first;
  }

  List<ProfileOption> _options() {
    if (widget.members.isEmpty) {
      return const [
        ProfileOption(name: 'Parent', roleLabel: 'Parent'),
      ];
    }
    return [
      for (final member in widget.members)
        ProfileOption(
          name: member.name,
          roleLabel: '${member.role.label} · Age ${member.age}',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = _options();
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeSync'),
        actions: [
          ProfileAvatarDropdown(
            active: _active,
            profiles: options,
            onSwitchProfile: (profile) =>
                setState(() => _active = profile),
            onAccountSettings: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account settings coming soon.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hello, ${_active.name.split(' ').first}!',
                  style: text.headlineMedium),
              const SizedBox(height: 16),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your focus areas', style: text.titleLarge),
                    const SizedBox(height: 12),
                    if (widget.focusAreas.isEmpty)
                      Text('Nothing selected yet.',
                          style: text.bodyMedium)
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final area in widget.focusAreas)
                            Chip(
                              label: Text(area),
                              backgroundColor: AppColors.sageLight,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family members', style: text.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      widget.members.isEmpty
                          ? 'Skipped for now — add members later in settings.'
                          : '${widget.members.length} '
                              'member${widget.members.length == 1 ? '' : 's'} '
                              'ready to go.',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
