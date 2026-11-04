import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';
import '../../core/network/families_api.dart';

/// Parent-managed child login PINs: per-child status with set/clear.
///
/// PINs are optional; a child without one logs in and switches
/// freely, while a set PIN is required instead of any parent PIN.
class ChildPinScreen extends StatefulWidget {
  const ChildPinScreen({super.key});

  @override
  State<ChildPinScreen> createState() => _ChildPinScreenState();
}

class _ChildPinScreenState extends State<ChildPinScreen> {
  List<Map<String, dynamic>>? _kids;
  int? _familyId;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_kids != null || _error != null) return;
    final session = AuthScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) return;
    _load(session.client);
  }

  Future<void> _load(ApiClient client, {bool silent = false}) async {
    try {
      final family = await FamiliesApi(client).myFamily();
      if (!mounted) return;
      final List<dynamic> members = family['members'] ?? const [];
      final kids = <Map<String, dynamic>>[];
      for (final member in members) {
        final user = member as Map<String, dynamic>;
        if (user['role'] != 'parent') kids.add(user);
      }
      setState(() {
        _familyId = family['id'] as int?;
        _kids = kids;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (silent) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _promptPin(Map<String, dynamic> kid) async {
    final hasPin = kid['has_child_pin'] == true;
    final controller = TextEditingController();
    String? error;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('PIN for ${kid['display_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('pin-field'),
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '4+ characters',
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            if (hasPin)
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(true),
                child: const Text('Remove PIN'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.length < 4) {
                  setDialogState(
                    () => error = 'Enter at least 4 characters.',
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    // Dialog dismissed: nothing to do. "Remove PIN" and "Save" both
    // pop true; distinguish by whether a PIN was typed.
    if (saved != true || !mounted) return;
    final session = AuthScope.maybeOf(context);
    final familyId = _familyId;
    if (session == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FamiliesApi(session.client).setChildPin(
        familyId: familyId!,
        childId: kid['id'] as int,
        pin: controller.text.isEmpty ? null : controller.text,
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await _load(session.client, silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Child PINs')),
      body: SafeArea(child: _body(text)),
    );
  }

  Widget _body(TextTheme text) {
    final error = _error;
    if (error != null) return Center(child: Text(error));
    final kids = _kids;
    if (kids == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (kids.isEmpty) {
      return Center(
        child: Text('No child profiles yet.', style: text.bodyMedium),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kids.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final kid = kids[index];
        final hasPin = kid['has_child_pin'] == true;
        return Card(
          child: ListTile(
            title: Text(kid['display_name'] as String? ?? 'Kid'),
            subtitle: Text(hasPin ? 'PIN set' : 'No PIN'),
            trailing: TextButton(
              key: Key('pin-action-${kid['id']}'),
              onPressed: () => _promptPin(kid),
              child: Text(hasPin ? 'Change' : 'Set'),
            ),
          ),
        );
      },
    );
  }
}
