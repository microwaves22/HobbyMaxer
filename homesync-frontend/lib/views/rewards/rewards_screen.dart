import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/widgets/home_title.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../home/household_routes.dart';
import '../onboarding/models/user_profile.dart';
import 'models/reward_item.dart';
import 'rewards_controller.dart';

/// Reward store with Digital Rewards and Parent Perks tabs.
///
/// Children redeem with their points balance (shown live at the top);
/// parents can add new real-world perks from the Perks tab.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({
    super.key,
    required this.controller,
    required this.profile,
    this.onNavigate,
  });

  final RewardsController controller;
  final UserProfile profile;

  /// Called with the tapped bottom-nav tab id. When null, tabs switch
  /// with replacement navigation.
  final ValueChanged<String>? onNavigate;

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _synced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_synced) return;
    _synced = true;
    if (!widget.controller.isSynced) return;
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      await widget.controller.refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _handleNavigate(BuildContext context, String tabId) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(tabId);
      return;
    }
    HouseholdRoutes.openTab(context, tabId);
  }

  Future<void> _redeem(BuildContext context, RewardItem reward) async {
    final messenger = ScaffoldMessenger.of(context);
    late final RedeemResult result;
    try {
      result = await widget.controller.redeemAsync(
        widget.profile.name,
        reward.id,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    final message = switch (result) {
      RedeemResult.success => 'Redeemed ${reward.title}!',
      RedeemResult.insufficient =>
        'Not enough points for ${reward.title}.',
      RedeemResult.notFound => 'That reward is no longer available.',
    };
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addPerk(BuildContext context) async {
    final draft = await showDialog<_PerkDraft>(
      context: context,
      builder: (_) => const _AddPerkDialog(),
    );
    if (draft == null || !context.mounted) return;
    try {
      await widget.controller.addPerkAsync(
        title: draft.title,
        description: draft.description,
        cost: draft.cost,
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added perk: ${draft.title}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: _BottomNav(
          onNavigate: (tabId) => _handleNavigate(context, tabId),
        ),
        appBar: AppBar(
          title: const HomeTitle(label: 'Reward Store'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Digital Rewards'),
              Tab(text: 'Parent Perks'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([widget.controller, widget.controller.tasks]),
          builder: (context, _) {
            final text = Theme.of(context).textTheme;
            final balance = widget.controller.balanceFor(widget.profile.name);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: LiquidGlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${widget.profile.name}'s balance",
                            style: text.titleLarge,
                          ),
                        ),
                        Text(
                          '$balance pts',
                          key: const ValueKey('balance-pts'),
                          style: text.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RewardList(
                        rewards: widget.controller.rewardsOf(RewardKind.digital),
                        balance: balance,
                        redeemLabel: true,
                        onRedeem: widget.profile.isParent
                            ? null
                            : (reward) => _redeem(context, reward),
                      ),
                      _RewardList(
                        rewards:
                            widget.controller.rewardsOf(RewardKind.parentPerk),
                        balance: balance,
                        redeemLabel: true,
                        onRedeem: widget.profile.isParent
                            ? null
                            : (reward) => _redeem(context, reward),
                        header: widget.profile.isParent
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OutlinedButton.icon(
                                  onPressed: () => _addPerk(context),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add perk'),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const _navFill = Color.fromRGBO(255, 255, 255, 0.8);
const _navMuted = Color(0xFF7C877A);

class _NavTab {
  const _NavTab({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

const _navTabs = <_NavTab>[
  _NavTab(id: 'home', label: 'Home', icon: Icons.home_rounded),
  _NavTab(
      id: 'calendar', label: 'Calendar', icon: Icons.calendar_month_rounded),
  _NavTab(id: 'tasks', label: 'Tasks', icon: Icons.checklist_rounded),
  _NavTab(id: 'family', label: 'Family', icon: Icons.group_rounded),
];

/// Household bottom navigation (Home / Calendar / Tasks / Family),
/// matching the calendar, family-time, and hub bars. No tab is active:
/// Rewards is not a household destination.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: _navFill,
        padding:
            const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final tab in _navTabs)
              _NavTabButton(
                tab: tab,
                onTap: () => onNavigate(tab.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// One bottom-navigation tab: 64px wide, icon over label.
class _NavTabButton extends StatelessWidget {
  const _NavTabButton({required this.tab, required this.onTap});

  final _NavTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 23, color: _navMuted),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: _navMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardList extends StatelessWidget {
  const _RewardList({
    required this.rewards,
    required this.balance,
    required this.redeemLabel,
    this.onRedeem,
    this.header,
  });

  final List<RewardItem> rewards;
  final int balance;
  final bool redeemLabel;
  final ValueChanged<RewardItem>? onRedeem;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (rewards.isEmpty && header == null) {
      return Center(
        child: Text('Nothing here yet.', style: text.bodyMedium),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (header != null) header!,
        for (final reward in rewards) ...[
          LiquidGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Icon(reward.icon)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reward.title, style: text.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            reward.description,
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(label: Text('${reward.cost} pts')),
                    const Spacer(),
                    if (onRedeem != null)
                      ElevatedButton(
                        onPressed: balance >= reward.cost
                            ? () => onRedeem!(reward)
                            : null,
                        child: Text(
                          redeemLabel && balance < reward.cost
                              ? 'Need ${reward.cost - balance} more'
                              : 'Redeem',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PerkDraft {
  const _PerkDraft({
    required this.title,
    required this.description,
    required this.cost,
  });

  final String title;
  final String description;
  final int cost;
}

class _AddPerkDialog extends StatefulWidget {
  const _AddPerkDialog();

  @override
  State<_AddPerkDialog> createState() => _AddPerkDialogState();
}

class _AddPerkDialogState extends State<_AddPerkDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  String? _titleError;
  String? _costError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final cost = int.tryParse(_costController.text.trim());
    setState(() {
      _titleError = title.isEmpty ? 'Enter a perk name.' : null;
      _costError =
          cost == null || cost <= 0 ? 'Enter a points cost.' : null;
    });
    if (title.isEmpty || cost == null || cost <= 0) return;
    Navigator.of(context).pop(
      _PerkDraft(
        title: title,
        description: _descriptionController.text.trim(),
        cost: cost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add parent perk'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Perk name',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Description (optional)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Cost in points',
              errorText: _costError,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
