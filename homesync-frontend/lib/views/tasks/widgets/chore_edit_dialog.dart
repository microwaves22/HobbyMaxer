import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chore_task.dart';

/// Parent's edits to a chore: point value, details/description, and
/// whether a photo is required.
class ChoreEditResult {
  const ChoreEditResult({this.points, this.details, this.requiresPhoto});

  final int? points;
  final String? details;
  final bool? requiresPhoto;
}

/// Request-changes submission: chore edits plus the feedback note the
/// child will see on retry.
class RequestChangesResult {
  const RequestChangesResult({required this.edit, required this.feedback});

  final ChoreEditResult edit;
  final String feedback;
}

/// Opens the edit-chore dialog for [task]. Returns the parent's edits,
/// or null when dismissed.
Future<ChoreEditResult?> showChoreEditDialog(
  BuildContext context,
  ChoreTask task,
) {
  return showDialog<ChoreEditResult>(
    context: context,
    builder: (_) => _ChoreRevisionDialog(task: task),
  );
}

/// Opens the request-changes dialog for [task]: chore edits plus a
/// required feedback note. Returns the submission, or null when
/// dismissed.
Future<RequestChangesResult?> showRequestChangesDialog(
  BuildContext context,
  ChoreTask task,
) {
  return showDialog<RequestChangesResult>(
    context: context,
    builder: (_) => _ChoreRevisionDialog(task: task, requireFeedback: true),
  );
}

/// One dialog for both flows: editing a chore (points, details, photo
/// requirement) and requesting changes (those edits plus feedback).
class _ChoreRevisionDialog extends StatefulWidget {
  const _ChoreRevisionDialog({required this.task, this.requireFeedback = false});

  final ChoreTask task;
  final bool requireFeedback;

  @override
  State<_ChoreRevisionDialog> createState() => _ChoreRevisionDialogState();
}

class _ChoreRevisionDialogState extends State<_ChoreRevisionDialog> {
  late final TextEditingController _pointsController;
  late final TextEditingController _detailsController;
  late final TextEditingController _feedbackController;
  late bool _requiresPhoto;
  String? _pointsError;
  String? _detailsError;
  String? _feedbackError;

  @override
  void initState() {
    super.initState();
    _pointsController =
        TextEditingController(text: widget.task.points.toString());
    _detailsController = TextEditingController(text: widget.task.details);
    _feedbackController = TextEditingController();
    _requiresPhoto = widget.task.requiresPhoto;
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _detailsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    final points = int.tryParse(_pointsController.text.trim());
    final details = _detailsController.text.trim();
    final feedback = _feedbackController.text.trim();
    setState(() {
      _pointsError =
          points == null || points < 0 ? 'Enter points (0 or more).' : null;
      _detailsError = details.isEmpty ? 'Describe the chore.' : null;
      _feedbackError =
          widget.requireFeedback && feedback.isEmpty ? 'Tell them what to change.' : null;
    });
    if (_pointsError != null ||
        _detailsError != null ||
        _feedbackError != null) {
      return;
    }
    final edit = ChoreEditResult(
      points: points,
      details: details,
      requiresPhoto: _requiresPhoto,
    );
    if (widget.requireFeedback) {
      Navigator.of(context).pop(RequestChangesResult(
        edit: edit,
        feedback: feedback,
      ));
    } else {
      Navigator.of(context).pop(edit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.requireFeedback ? 'Request changes' : 'Edit chore'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.task.title} · for ${widget.task.childName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Points',
                errorText: _pointsError,
              ),
              onChanged: (_) => setState(() => _pointsError = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Details',
                errorText: _detailsError,
              ),
              onChanged: (_) => setState(() => _detailsError = null),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Photo required'),
              value: _requiresPhoto,
              onChanged: (value) => setState(() => _requiresPhoto = value),
            ),
            if (widget.requireFeedback) ...[
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  hintText: 'e.g. Fold the sleeves too.',
                  errorText: _feedbackError,
                ),
                onChanged: (_) => setState(() => _feedbackError = null),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.requireFeedback ? 'Send feedback' : 'Save'),
        ),
      ],
    );
  }
}
