import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/notifications_api.dart';

/// Family notification preferences: one toggle per notification type.
///
/// Parents only; changes save immediately and revert with a message
/// when the backend rejects them.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _rows = [
    ('review_needed', 'Review needed', 'When a child submits work for review'),
    ('approved', 'Approvals', 'When the other parent approves a chore'),
    ('member_joined', 'New members', 'When someone joins the family'),
  ];

  Map<String, bool>? _prefs;
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
      final prefs = await NotificationsApi(client).fetchPreferences();
      if (!mounted) return;
      setState(() => _prefs = {
            for (final row in _rows)
              row.$1: prefs[row.$1] as bool? ?? true,
          });
    } on ApiException {
      if (!mounted) return;
      setState(() => _error = "Couldn't load preferences.");
    }
  }

  Future<void> _toggle(String key, bool value) async {
    final prefs = _prefs;
    final session = AuthScope.maybeOf(context);
    if (prefs == null || session == null) return;
    final previous = prefs[key]!;
    setState(() => prefs[key] = value);
    try {
      final saved = await NotificationsApi(session.client)
          .updatePreferences(Map.of(prefs));
      if (!mounted) return;
      setState(() => _prefs = {
            for (final row in _rows)
              row.$1: saved[row.$1] as bool? ?? true,
          });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => prefs[key] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notification preferences')),
      body: SafeArea(child: _body(text)),
    );
  }

  Widget _body(TextTheme text) {
    final error = _error;
    if (error != null) return Center(child: Text(error));
    final prefs = _prefs;
    if (prefs == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (key, title, subtitle) in _rows)
          SwitchListTile(
            key: Key('pref-$key'),
            title: Text(title),
            subtitle: Text(subtitle, style: text.bodyMedium),
            value: prefs[key]!,
            onChanged: (value) => _toggle(key, value),
          ),
      ],
    );
  }
}
