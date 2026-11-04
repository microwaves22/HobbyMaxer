import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/liquid_glass_card.dart';
import '../../../core/widgets/member_avatar.dart';
import '../models/chore_task.dart';
import '../tasks_controller.dart';

/// Parent dashboard section listing tasks awaiting review, with
/// per-task approve/request-changes actions plus a batch approve for
/// simple (no-photo) tasks.
class ReviewQueueSection extends StatelessWidget {
  const ReviewQueueSection({super.key, required this.controller});

  final TasksController controller;

  void _zoomPhoto(BuildContext context, Uint8List bytes) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _snack(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final queue = controller.pendingReview;
        final simpleCount = queue.where((t) => t.isSimple).length;
        final batchEnabled = queue.isNotEmpty && simpleCount > 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Review queue (${queue.length})',
                    style: text.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: !batchEnabled
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final approved =
                            await controller.approveAllSimple();
                        _snack(
                          messenger,
                          'Approved $approved simple '
                          'task${approved == 1 ? '' : 's'}.',
                        );
                      } on ApiException catch (e) {
                        _snack(messenger, e.message);
                      }
                    },
              child: const Text('Approve All Simple Tasks'),
            ),
            const SizedBox(height: 12),
            if (queue.isEmpty)
              LiquidGlassCard(
                child: Text(
                  'All caught up — nothing waiting for review.',
                  style: text.bodyMedium,
                ),
              )
            else ...[
              for (final task in queue) ...[
                _ReviewCard(
                  task: task,
                  balance: controller.balanceFor(task.childName),
                  avatarUrl: controller.avatarFor(task.childName),
                  onZoomPhoto: task.photoBytes == null
                      ? null
                      : () => _zoomPhoto(context, task.photoBytes!),
                  onApprove: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await controller.approve(task.id);
                    } on ApiException catch (e) {
                      _snack(messenger, e.message);
                      return;
                    }
                    _snack(
                      messenger,
                      'Approved — +${task.points} pts to ${task.childName}.',
                    );
                  },
                  onRequestChanges: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await controller.requestChanges(task.id);
                    } on ApiException catch (e) {
                      _snack(messenger, e.message);
                      return;
                    }
                    _snack(
                      messenger,
                      'Changes requested for ${task.childName}.',
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.task,
    required this.balance,
    required this.avatarUrl,
    required this.onZoomPhoto,
    required this.onApprove,
    required this.onRequestChanges,
  });

  final ChoreTask task;
  final int balance;
  final String? avatarUrl;
  final VoidCallback? onZoomPhoto;
  final VoidCallback onApprove;
  final VoidCallback onRequestChanges;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MemberAvatar(
                imageUrl: avatarUrl,
                name: task.childName,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.childName} · $balance pts',
                      style: text.titleLarge,
                    ),
                    Text(task.title, style: text.bodyMedium),
                  ],
                ),
              ),
              Chip(label: Text('${task.points} pts')),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.details, style: text.bodyMedium),
          const SizedBox(height: 12),
          if (task.photoBytes != null)
            GestureDetector(
              onTap: onZoomPhoto,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  task.photoBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Theme.of(context).disabledColor,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            )
          else if (task.photoPath != null)
            _PhotoPlaceholder(
              icon: Icons.photo_outlined,
              label: 'Photo unavailable on this device',
            )
          else if (task.remotePhoto == null)
            _PhotoPlaceholder(
              icon: Icons.image_outlined,
              label: 'No photo attached',
            )
          else
            _PhotoPlaceholder(
              icon: Icons.cloud_outlined,
              label: 'Evidence stored on server',
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Approve & Award Points'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRequestChanges,
                  child: const Text('Request Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
