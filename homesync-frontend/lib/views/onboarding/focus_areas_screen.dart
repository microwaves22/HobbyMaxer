import 'package:flutter/material.dart';

import 'family_setup_screen.dart';

const List<String> kFocusAreas = [
  'Calendar coordination',
  'Chore distribution',
  'Task rewards',
  'Homework tracking',
];

/// Multi-select interest picker. At least one tag is required to continue.
class FocusAreasScreen extends StatefulWidget {
  const FocusAreasScreen({super.key});

  @override
  State<FocusAreasScreen> createState() => _FocusAreasScreenState();
}

class _FocusAreasScreenState extends State<FocusAreasScreen> {
  final Set<String> _selected = {};

  void _toggle(String area) {
    setState(() {
      if (_selected.contains(area)) {
        _selected.remove(area);
      } else {
        _selected.add(area);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Getting started')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What would you like to use HomeSync for?',
                style: text.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick all that apply — you can change this later.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final area in kFocusAreas)
                    FilterChip(
                      label: Text(area),
                      selected: _selected.contains(area),
                      showCheckmark: false,
                      onSelected: (_) => _toggle(area),
                    ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FamilySetupScreen(
                              focusAreas: _selected.toList(),
                            ),
                          ),
                        ),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
