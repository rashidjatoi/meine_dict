import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/word_provider.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _germanController = TextEditingController();
  final _englishController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _germanController.dispose();
    _englishController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<WordProvider>();

    try {
      await provider.addCustomWord(
        german: _germanController.text,
        english: _englishController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Word added!')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Word')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Add your own German vocabulary',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _germanController,
              decoration: const InputDecoration(
                labelText: 'German',
                hintText: 'e.g. Apfel',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter the German word' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _englishController,
              decoration: const InputDecoration(
                labelText: 'English',
                hintText: 'e.g. apple',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter the translation' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. masculine noun, plural: Äpfel',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Word'),
            ),
          ],
        ),
      ),
    );
  }
}
