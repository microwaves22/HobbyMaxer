import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/notifications_api.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../home/widgets/household_bottom_nav.dart';

/// In-app notification inbox: unread dots, tap-to-read, mark-all-read.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>>? _items;
  bool _loaded = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _loaded = true;
    _load(session.client);
  }

  Future<void> _load(ApiClient client) async {
    try {
      final items = await NotificationsApi(client).fetchNotifications();
      if (!mounted) return;
      setState(() => _items = items.cast<Map<String, dynamic>>());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    if (item['is_read'] == true) return;
    final session = AuthScope.maybeOf(context);
    if (session == null) return;
    try {
      await NotificationsApi(session.client).markRead(item['id'] as int);
    } on ApiException {
      return;
    }
    if (!mounted) return;
    setState(() => item['is_read'] = true);
  }

  Future<void> _markAllRead() async {
    final session = AuthScope.maybeOf(context);
    if (session == null) return;
    try {
      await NotificationsApi(session.client).markAllRead();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      for (final item in _items ?? const <Map<String, dynamic>>[]) {
        item['is_read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _items == null ? null : _markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      bottomNavigationBar:
          const HouseholdBottomNav(activeTabId: 'home'),
      body: SafeArea(child: _body(text)),
    );
  }

  Widget _body(TextTheme text) {
    final error = _error;
    if (error != null) return Center(child: Text(error));
    final items = _items;
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text("You're all caught up.", style: text.bodyMedium),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final body = item['body'] as String?;
        return LiquidGlassCard(
          onTap: () => _markRead(item),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: item['is_read'] == true
                ? const SizedBox(width: 10)
                : Container(
                    key: const Key('unread-dot'),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
            title: Text(item['title'] as String? ?? ''),
            subtitle: body == null ? null : Text(body),
          ),
        );
      },
    );
  }
}
