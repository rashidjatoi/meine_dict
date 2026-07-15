import 'package:flutter/material.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/pronounce_button.dart';
import 'package:provider/provider.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.word,
    this.onTap,
    this.showProgress = true,
  });

  final Word word;
  final VoidCallback? onTap;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final theme = Theme.of(context);
    final isFavorite = provider.isFavorite(word.id);
    final progress = provider.getProgress(word.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.german,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (word.source == WordSource.custom)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Custom',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.english,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showProgress && progress.totalAttempts > 0) ...[
                      const SizedBox(height: 8),
                      _MasteryChip(level: progress.masteryLevel),
                    ],
                  ],
                ),
              ),
              PronounceButton(
                text: word.german,
                iconSize: 22,
              ),
              IconButton(
                onPressed: () => provider.toggleFavorite(word.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red.shade400 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.level});

  final MasteryLevel level;

  @override
  Widget build(BuildContext context) {
    final (label, color, textColor) = switch (level) {
      MasteryLevel.newWord => ('New', Colors.grey, Colors.grey.shade700),
      MasteryLevel.learning => ('Learning', Colors.orange, Colors.orange.shade800),
      MasteryLevel.familiar => ('Familiar', Colors.blue, Colors.blue.shade800),
      MasteryLevel.mastered => ('Mastered', Colors.green, Colors.green.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
