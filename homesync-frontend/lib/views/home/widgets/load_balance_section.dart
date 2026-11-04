import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/auth_session.dart';
import '../../../core/network/families_api.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../tasks/tasks_controller.dart';

/// Parent dashboard section: week-to-week workload split per parent.
///
/// Loads `GET /families/load-balance` (trailing 7 days, equal weights)
/// and renders the `Mom 72% / Dad 28%` split with a proportional bar
/// and per-parent counts. Hides while loading, when signed out, and
/// when the backend is unreachable; a quiet week shows an explicit
/// empty state instead of hiding.
///
/// Pass the dashboard's [TasksController] as [refreshTrigger] so the
/// card loads once first-run sync lands and stays fresh as reviews
/// complete; failed reloads keep the last good data.
class LoadBalanceSection extends StatefulWidget {
  const LoadBalanceSection({super.key, this.refreshTrigger});

  final TasksController? refreshTrigger;

  @override
  State<LoadBalanceSection> createState() => _LoadBalanceSectionState();
}

class _LoadBalanceSectionState extends State<LoadBalanceSection> {
  static const _barColors = [
    Color(0xFF5F7F55),
    Color(0xFF7FA6C9),
    Color(0xFFF0B429),
    Color(0xFFC97F8A),
  ];

  Map<String, dynamic>? _balance;
  ApiClient? _client;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.refreshTrigger?.addListener(_reload);
  }

  @override
  void didUpdateWidget(LoadBalanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      oldWidget.refreshTrigger?.removeListener(_reload);
      widget.refreshTrigger?.addListener(_reload);
    }
  }

  @override
  void dispose() {
    widget.refreshTrigger?.removeListener(_reload);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _client = session.client;
    if (_balance == null) _reload();
  }

  /// Single-attempt load; errors keep the last good data (or stay
  /// hidden) so offline dashboards never break on this card.
  Future<void> _reload() async {
    final client = _client;
    if (!mounted || client == null || _loading) return;
    _loading = true;
    try {
      final balance = await FamiliesApi(client).loadBalance();
      if (!mounted) return;
      setState(() => _balance = balance);
    } on ApiException {
      return;
    } finally {
      _loading = false;
    }
  }

  static String _count(int value, String unit) =>
      '$value $unit${value == 1 ? '' : 's'}';

  @override
  Widget build(BuildContext context) {
    final balance = _balance;
    if (balance == null) return const SizedBox.shrink();
    final shares =
        (balance['shares'] as List).cast<Map<String, dynamic>>();
    final text = Theme.of(context).textTheme;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Load Balance', style: text.titleLarge),
          Text('Last 7 days', style: text.bodyMedium),
          const SizedBox(height: 12),
          if ((balance['total'] as int? ?? 0) == 0)
            Text(
              'No activity in the last 7 days.',
              style: text.bodyMedium,
            )
          else ...[
            Text(
              shares
                  .map((s) => "${s['display_name']} ${s['percent']}%")
                  .join(' / '),
              style: text.titleMedium,
            ),
            const SizedBox(height: 8),
            _Bar(
              key: const Key('load-balance-bar'),
              shares: shares,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < shares.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _barColors[i % _barColors.length],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${shares[i]['display_name']} · "
                        "${_count(shares[i]['tasks_created'] as int? ?? 0, 'task')} · "
                        "${_count(shares[i]['approvals'] as int? ?? 0, 'approval')} · "
                        "${_count(shares[i]['events_added'] as int? ?? 0, 'event')}",
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Proportional workload bar: one segment per parent with a nonzero
/// share, in roster order.
class _Bar extends StatelessWidget {
  const _Bar({super.key, required this.shares});

  final List<Map<String, dynamic>> shares;

  @override
  Widget build(BuildContext context) {
    final segments = [
      for (var i = 0; i < shares.length; i++)
        if ((shares[i]['percent'] as int? ?? 0) > 0)
          Expanded(
            flex: shares[i]['percent'] as int,
            child: Container(
              height: 12,
              color: _LoadBalanceSectionState
                  ._barColors[i % _LoadBalanceSectionState._barColors.length],
            ),
          ),
    ];
    if (segments.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(children: segments),
    );
  }
}
