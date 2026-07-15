import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/add_to_practice_button.dart';
import '../widgets/pronounce_button.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final theme = Theme.of(context);
    final progress = provider.getProgress(word.id);
    final isFavorite = provider.isFavorite(word.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(word.german),
        actions: [
          PronounceButton(text: word.german),
          IconButton(
            onPressed: () => provider.toggleFavorite(word.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red.shade400 : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    word.german,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  PronounceButton(
                    text: word.german,
                    style: PronounceButtonStyle.filled,
                    label: 'Play pronunciation',
                  ),
                  const SizedBox(height: 8),
                  AddToPracticeButton(word: word),
                  const SizedBox(height: 8),
                  Text(
                    word.english,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (word.rank != null) ...[
                    const SizedBox(height: 16),
                    Chip(
                      label: Text('Rank #${word.rank} most common'),
                    ),
                  ],
                  if (word.notes != null && word.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      word.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ProgressRow(
                    label: 'Mastery',
                    value: _masteryLabel(progress.masteryLevel),
                  ),
                  const Divider(),
                  _ProgressRow(
                    label: 'Correct',
                    value: '${progress.correctCount}',
                  ),
                  const Divider(),
                  _ProgressRow(
                    label: 'Incorrect',
                    value: '${progress.incorrectCount}',
                  ),
                  if (progress.totalAttempts > 0) ...[
                    const Divider(),
                    _ProgressRow(
                      label: 'Accuracy',
                      value: '${(progress.accuracy * 100).round()}%',
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (word.source == WordSource.custom) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete word?'),
                    content: Text('Remove "${word.german}" from your vocabulary?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await provider.deleteCustomWord(word.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete custom word'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _masteryLabel(MasteryLevel level) => switch (level) {
        MasteryLevel.newWord => 'New',
        MasteryLevel.learning => 'Learning',
        MasteryLevel.familiar => 'Familiar',
        MasteryLevel.mastered => 'Mastered',
      };
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
