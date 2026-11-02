import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/liquid_glass_card.dart';
import '../home/home_screen.dart';
import 'models/family_member.dart';

/// Dynamic list for adding family members during onboarding.
class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key, this.focusAreas = const []});

  final List<String> focusAreas;

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  FamilyRole _role = FamilyRole.child;
  final List<FamilyMember> _members = [];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    if (name.isEmpty || age == null || age <= 0) return;
    setState(() {
      _members.add(FamilyMember(name: name, age: age, role: _role));
      _nameController.clear();
      _ageController.clear();
    });
  }

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          members: _members,
          focusAreas: widget.focusAreas,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final canAdd =
        _nameController.text.trim().isNotEmpty; // re-checked on submit too
    return Scaffold(
      appBar: AppBar(title: const Text('Your family')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Who is joining HomeSync?', style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Add parents and kids to set up their profiles.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 20),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Enter name',
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _addMember(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Age',
                            ),
                            onSubmitted: (_) => _addMember(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SegmentedButton<FamilyRole>(
                          segments: const [
                            ButtonSegment(
                              value: FamilyRole.parent,
                              label: Text('Parent'),
                            ),
                            ButtonSegment(
                              value: FamilyRole.child,
                              label: Text('Child'),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (selected) =>
                              setState(() => _role = selected.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: canAdd ? _addMember : null,
                      child: const Text('Add Member'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _members.isEmpty
                    ? Center(
                        child: Text(
                          'No members yet — add your first above.',
                          style: text.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _members.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return LiquidGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    member.name.characters.first
                                        .toUpperCase(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name,
                                        style: text.titleLarge,
                                      ),
                                      Text(
                                        '${member.role.label} · Age ${member.age}',
                                        style: text.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                  onPressed: () => setState(
                                    () => _members.removeAt(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _finish,
                child: Text(
                  _members.isEmpty ? 'Later' : 'Done',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
