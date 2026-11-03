import 'package:flutter/material.dart';

import '../../../core/widgets/liquid_glass_card.dart';
import '../models/chore_task.dart';
import '../tasks_controller.dart';

/// Parent dashboard section for personal to-dos: add, edit, complete,
/// delete, and reorder — separate from child-assigned chores.
class ParentTodoSection extends StatelessWidget {
  const ParentTodoSection({super.key, required this.controller});

  final TasksController controller;

  Future<void> _editTodo(BuildContext context, [ChoreTask? todo]) async {
    final draft = await showDialog<_TodoDraft>(
      context: context,
      builder: (_) => _TodoDialog(initial: todo),
    );
    if (draft == null) return;
    if (todo == null) {
      controller.addParentTodo(title: draft.title, details: draft.details);
    } else {
      controller.updateParentTodo(
        todo.id,
        title: draft.title,
        details: draft.details,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final todos = controller.parentTodos;
        final open =
            todos.where((t) => t.state != TaskState.approved).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Parent To-Do ($open open)',
                    style: text.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Add to-do',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _editTodo(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (todos.isEmpty)
              LiquidGlassCard(
                child: Text(
                  'No to-dos yet — add your first above.',
                  style: text.bodyMedium,
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: controller.moveParentTodo,
                children: [
                  for (final todo in todos)
                    _TodoTile(
                      key: ValueKey(todo.id),
                      todo: todo,
                      onToggle: () => controller.toggleParentTodo(todo.id),
                      onEdit: () => _editTodo(context, todo),
                      onDelete: () => controller.removeParentTodo(todo.id),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final ChoreTask todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final done = todo.state == TaskState.approved;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(value: done, onChanged: (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: text.titleLarge?.copyWith(
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                      color: done
                          ? Theme.of(context).disabledColor
                          : null,
                    ),
                  ),
                  if (todo.details.isNotEmpty)
                    Text(todo.details, style: text.bodySmall),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit to-do',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete to-do',
              icon: const Icon(Icons.delete_outlined),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoDraft {
  const _TodoDraft({required this.title, required this.details});

  final String title;
  final String details;
}

class _TodoDialog extends StatefulWidget {
  const _TodoDialog({this.initial});

  final ChoreTask? initial;

  @override
  State<_TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<_TodoDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title);
    _detailsController =
        TextEditingController(text: widget.initial?.details);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Enter a title.');
      return;
    }
    Navigator.of(context).pop(
      _TodoDraft(title: title, details: _detailsController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return AlertDialog(
      title: Text(editing ? 'Edit to-do' : 'Add to-do'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Title',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Details (optional)',
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
          child: Text(editing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
