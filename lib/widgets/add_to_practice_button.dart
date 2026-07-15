import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';

class AddToPracticeButton extends StatelessWidget {
  const AddToPracticeButton({
    super.key,
    required this.word,
    this.compact = false,
  });

  final Word word;
  final bool compact;

  Future<void> _toggle(BuildContext context, WordProvider provider) async {
    final added = await provider.togglePracticeQueue(word.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '"${word.german}" added to Need Practice'
              : '"${word.german}" removed from Need Practice',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final inQueue = provider.isInPracticeQueue(word.id);

    if (compact) {
      return IconButton(
        onPressed: () => _toggle(context, provider),
        tooltip: inQueue ? 'Remove from Need Practice' : 'Save for later practice',
        icon: Icon(
          inQueue ? Icons.playlist_add_check : Icons.playlist_add,
          color: inQueue ? Colors.orange.shade800 : null,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _toggle(context, provider),
      icon: Icon(
        inQueue ? Icons.playlist_add_check : Icons.playlist_add,
        size: 18,
      ),
      label: Text(inQueue ? 'Saved for practice' : 'Practice later'),
      style: OutlinedButton.styleFrom(
        foregroundColor: inQueue ? Colors.orange.shade800 : null,
      ),
    );
  }
}
