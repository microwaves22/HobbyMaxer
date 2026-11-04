import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/auth_session.dart';
import '../../../core/network/notifications_api.dart';
import '../../notifications/notifications_screen.dart';

/// Dashboard bell with an unread-count badge (parents only).
///
/// The count loads with the dashboard and refreshes whenever the
/// inbox screen closes; failures leave a plain bell behind.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int? _unread;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    try {
      final items = await NotificationsApi(session.client)
          .fetchNotifications(unreadOnly: true);
      if (!mounted) return;
      setState(() => _unread = items.length);
    } on ApiException {
      return;
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (!mounted) return;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final unread = _unread ?? 0;
    final button = IconButton(
      key: const Key('notifications-bell'),
      tooltip: 'Notifications',
      onPressed: _open,
      icon: const Icon(Icons.notifications_outlined),
    );
    if (unread == 0) return button;
    return Badge(label: Text('$unread'), child: button);
  }
}
