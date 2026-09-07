import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../models/health_profile.dart';
import '../services/health_profile_service.dart';

/// Create or edit the health profile.
///
/// One screen for both cases. In setup mode it offers a skip, because
/// someone who feels unwell should be able to reach the microphone without
/// completing a form first.
class HealthProfileScreen extends StatefulWidget {
  final bool isSetup;

  const HealthProfileScreen({super.key, this.isSetup = false});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _service = HealthProfileService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _allergyController = TextEditingController();

  String? _sex;
  final List<String> _conditions = [];
  final List<String> _allergies = [];
  bool _loading = true;
  bool _saving = false;

  static const _sexOptions = [
    "Female",
    "Male",
    "Other",
    "Prefer not to say",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _service.load();
    if (!mounted) return;
    setState(() {
      if (profile != null) {
        _nameController.text = profile.name;
        _ageController.text = profile.age?.toString() ?? '';
        _sex = profile.sex;
        _conditions.addAll(profile.conditions);
        _allergies.addAll(profile.allergies);
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name to continue.")),
      );
      return;
    }

    setState(() => _saving = true);
    await _service.save(HealthProfile(
      name: name,
      age: int.tryParse(_ageController.text.trim()),
      sex: _sex,
      conditions: List.of(_conditions),
      allergies: List.of(_allergies),
    ));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _skip() async {
    await _service.markSetupSkipped();
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  void _addTo(List<String> target, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    if (target.any((e) => e.toLowerCase() == value.toLowerCase())) {
      controller.clear();
      return;
    }
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSetup ? "Set up your profile" : "Your profile"),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  if (widget.isSetup) ...[
                    Text(
                      "A little about you",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "This helps MediVoice address you properly and keep "
                      "your health information in one place. You can skip "
                      "this and fill it in later.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _PrivacyNote(),
                  const SizedBox(height: 20),
                  _label(context, "Name"),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        hintText: "What should we call you?"),
                  ),
                  const SizedBox(height: 18),
                  _label(context, "Age"),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: const InputDecoration(hintText: "Optional"),
                  ),
                  const SizedBox(height: 18),
                  _label(context, "Sex"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sexOptions
                        .map((option) => ChoiceChip(
                              label: Text(option),
                              selected: _sex == option,
                              onSelected: (selected) => setState(
                                  () => _sex = selected ? option : null),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  _label(context, "Existing conditions"),
                  Text(
                    "Anything you already know about - diabetes, asthma, "
                    "high blood pressure.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _EntryField(
                    controller: _conditionController,
                    hint: "Add a condition",
                    onAdd: () => _addTo(_conditions, _conditionController),
                  ),
                  _ChipList(
                    items: _conditions,
                    onRemove: (item) => setState(() => _conditions.remove(item)),
                  ),
                  const SizedBox(height: 22),
                  _label(context, "Allergies"),
                  Text(
                    "Medicines, foods or anything else you react to.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  _EntryField(
                    controller: _allergyController,
                    hint: "Add an allergy",
                    onAdd: () => _addTo(_allergies, _allergyController),
                  ),
                  _ChipList(
                    items: _allergies,
                    onRemove: (item) => setState(() => _allergies.remove(item)),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(widget.isSetup ? "Save and continue" : "Save"),
                    ),
                  ),
                  if (widget.isSetup) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _saving ? null : _skip,
                      child: const Text("Skip for now"),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: AppTheme.primaryDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "This is stored on your phone only. It is never uploaded, "
              "shared, or sent anywhere, and you can change or delete it "
              "at any time.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;

  const _EntryField({
    required this.controller,
    required this.hint,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
            decoration: InputDecoration(hintText: hint),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _ChipList extends StatelessWidget {
  final List<String> items;
  final void Function(String) onRemove;

  const _ChipList({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((item) => Chip(
                  label: Text(item),
                  onDeleted: () => onRemove(item),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                ))
            .toList(),
      ),
    );
  }
}
