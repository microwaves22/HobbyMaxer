import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../models/chore_task.dart';
import '../tasks_controller.dart';

/// Opens the submission sheet for [task]. Returns `true` when the child
/// submitted, `false`/`null` when dismissed.
Future<bool?> showSubmissionSheet(
  BuildContext context,
  ChoreTask task,
  TasksController controller,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SubmissionSheet(task: task, controller: controller),
  );
}

/// Child submission modal: attach a photo (camera or gallery), preview
/// it, then submit the task for parent review.
class SubmissionSheet extends StatefulWidget {
  const SubmissionSheet({
    super.key,
    required this.task,
    required this.controller,
  });

  final ChoreTask task;
  final TasksController controller;

  @override
  State<SubmissionSheet> createState() => _SubmissionSheetState();
}

class _SubmissionSheetState extends State<SubmissionSheet> {
  final _picker = ImagePicker();
  String? _photoPath;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _photoPath = widget.task.photoPath;
    _photoBytes = widget.task.photoBytes;
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1600);
      // Cancelled picks return null and are silently ignored.
      if (file == null) return;
      // Web-safe: keep bytes, never a dart:io File.
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _photoBytes = bytes;
          _photoPath = null;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open camera/gallery.')),
      );
    }
  }

  void _chooseSource() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Attach photo'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _pick(ImageSource.camera);
            },
            child: const Row(
              children: [
                Icon(Icons.photo_camera_outlined),
                SizedBox(width: 12),
                Text('Take a photo'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _pick(ImageSource.gallery);
            },
            child: const Row(
              children: [
                Icon(Icons.photo_library_outlined),
                SizedBox(width: 12),
                Text('Choose from gallery'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    try {
      await widget.controller.submitPhoto(
        widget.task.id,
        _photoPath,
        photoBytes: _photoBytes,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final task = widget.task;
    final canSubmit =
        !task.requiresPhoto || _photoBytes != null || _photoPath != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(task.title, style: text.headlineMedium),
            const SizedBox(height: 4),
            Text(task.details, style: text.bodyMedium),
            if (task.feedback != null && task.feedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Parent feedback: ${task.feedback!}',
                  style: text.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${task.points} points'
              '${task.requiresPhoto ? ' · photo required' : ''}',
              style: text.labelSmall,
            ),
            const SizedBox(height: 16),
            if (_photoBytes == null && _photoPath == null)
              OutlinedButton.icon(
                onPressed: _chooseSource,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Attach photo'),
              )
            else
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _photoBytes != null
                        ? Image.memory(
                            _photoBytes!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 96,
                              height: 96,
                              color: Theme.of(context).disabledColor,
                              child: const Icon(
                                  Icons.broken_image_outlined),
                            ),
                          )
                        : Container(
                            width: 96,
                            height: 96,
                            color: Theme.of(context).disabledColor,
                            child: const Icon(Icons.photo_outlined),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: _chooseSource,
                          child: const Text('Retake'),
                        ),
                        TextButton(
                          onPressed: task.requiresPhoto
                              ? null
                              : () => setState(() {
                                    _photoPath = null;
                                    _photoBytes = null;
                                  }),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              child: Text(
                task.state == TaskState.changesRequested
                    ? 'Resubmit for review'
                    : 'Submit for review',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
