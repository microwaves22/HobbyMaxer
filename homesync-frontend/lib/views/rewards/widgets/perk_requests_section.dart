import 'package:flutter/material.dart';

import '../../../core/widgets/liquid_glass_card.dart';
import '../rewards_controller.dart';

/// Parent dashboard section listing redeemed perks awaiting real-world
/// fulfillment. Hidden while the queue is empty.
class PerkRequestsSection extends StatelessWidget {
  const PerkRequestsSection({super.key, required this.controller});

  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final requests = controller.perkRequests;
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Perk requests (${requests.length})',
              style: text.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final request in requests) ...[
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            request.childName.characters.first,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.perkTitle,
                                style: text.titleLarge,
                              ),
                              Text(
                                '${request.childName} · '
                                '${_timeAgo(request.requestedAt)}',
                                style: text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Chip(label: Text('${request.cost} pts')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        controller.fulfillRequest(request.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fulfilled ${request.perkTitle} '
                              'for ${request.childName}.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Mark Fulfilled'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

String _timeAgo(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
