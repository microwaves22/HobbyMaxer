import 'package:flutter/material.dart';

import '../../core/network/ai_api.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_session.dart';

/// Meta AI quick-add: the parent types (or pastes a voice transcript
/// into) one message, reviews the draft events/tasks, then taps
/// Confirm to save the selected ones. Nothing is saved before Confirm.
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _controller = TextEditingController();
  bool _parsing = false;
  bool _confirming = false;
  bool _parsed = false;
  String? _error;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _tasks = [];
  List<String> _warnings = [];
  List<bool> _eventSelected = [];
  List<bool> _taskSelected = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _parsing || _confirming) return;
    setState(() {
      _parsing = true;
      _error = null;
    });
    try {
      final session = AuthScope.of(context);
      final drafts = await AiApi(session.client).quickAdd(text);
      if (!mounted) return;
      final events = [
        for (final item in (drafts['events'] as List? ?? []))
          Map<String, dynamic>.from(item as Map),
      ];
      final tasks = [
        for (final item in (drafts['tasks'] as List? ?? []))
          Map<String, dynamic>.from(item as Map),
      ];
      setState(() {
        _parsed = true;
        _events = events;
        _tasks = tasks;
        _warnings = [
          for (final item in (drafts['warnings'] as List? ?? []))
            item.toString(),
        ];
        _eventSelected = List.filled(events.length, true);
        _taskSelected = List.filled(tasks.length, true);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _parsed = true;
        _events = [];
        _tasks = [];
        _warnings = [];
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  Map<String, dynamic> _eventBody(Map<String, dynamic> draft) {
    return {
      'title': draft['title'],
      'starts_at': draft['starts_at'],
      if (draft['ends_at'] != null) 'ends_at': draft['ends_at'],
    };
  }

  Map<String, dynamic> _taskBody(Map<String, dynamic> draft) {
    return {
      'title': draft['title'],
      if (draft['description'] != null) 'description': draft['description'],
      'task_type': draft['task_type'] ?? 'chore',
      'points_reward': draft['points_reward'] ?? 0,
      'requires_photo': draft['requires_photo'] ?? false,
      if (draft['assigned_to_user_id'] != null)
        'assigned_to_user_id': draft['assigned_to_user_id'],
      if (draft['due_date'] != null) 'due_date': draft['due_date'],
      if (draft['repeat_rule'] != null) 'repeat_rule': draft['repeat_rule'],
    };
  }

  Future<void> _confirm() async {
    if (_confirming || _parsing) return;
    setState(() {
      _confirming = true;
      _error = null;
    });
    try {
      final client = AuthScope.of(context).client;
      for (var i = 0; i < _events.length; i++) {
        if (!_eventSelected[i]) continue;
        await client.post('/calendar/events', body: _eventBody(_events[i]));
      }
      for (var i = 0; i < _tasks.length; i++) {
        if (!_taskSelected[i]) continue;
        await client.post('/tasks/', body: _taskBody(_tasks[i]));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDrafts = _events.isNotEmpty || _tasks.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick add')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _parse(),
              decoration: const InputDecoration(
                hintText: 'e.g. Noah has soccer Thursday 5-6, '
                    'Ava empties the dishwasher daily for 10 pts',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _parsing || _confirming ? null : _parse,
              child: Text(_parsing ? 'Parsing…' : 'Parse'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_parsed && !hasDrafts && !_parsing) ...[
              const SizedBox(height: 12),
              const Text(
                "Couldn't understand that — try rephrasing with names, days, and times.",
              ),
            ],
            if (hasDrafts && _warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final warning in _warnings) Text(warning),
            ],
            if (_events.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (var i = 0; i < _events.length; i++)
                Row(
                  children: [
                    Checkbox(
                      value: _eventSelected[i],
                      onChanged: _confirming
                          ? null
                          : (value) => setState(
                                () => _eventSelected[i] = value ?? false,
                              ),
                    ),
                    Expanded(
                      child: Text(
                        _events[i]['title']?.toString() ?? 'Untitled',
                      ),
                    ),
                  ],
                ),
            ],
            if (_tasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (var i = 0; i < _tasks.length; i++)
                Row(
                  children: [
                    Checkbox(
                      value: _taskSelected[i],
                      onChanged: _confirming
                          ? null
                          : (value) => setState(
                                () => _taskSelected[i] = value ?? false,
                              ),
                    ),
                    Expanded(
                      child: Text(
                        _tasks[i]['title']?.toString() ?? 'Untitled',
                      ),
                    ),
                  ],
                ),
            ],
            if (hasDrafts) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirming || _parsing ? null : _confirm,
                child: Text(_confirming ? 'Saving…' : 'Confirm'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
