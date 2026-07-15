import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/practice_mode.dart';
import '../providers/word_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/word_tile.dart';
import 'practice/flashcards_screen.dart';
import 'word_detail_screen.dart';

class PracticeQueueScreen extends StatelessWidget {
  const PracticeQueueScreen({super.key});

  void _startPractice(BuildContext context) {
    final provider = context.read<WordProvider>();
    final words = provider.getPracticeQueue();
    if (words.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardsScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final queue = provider.getPracticeQueue();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Need Practice')),
      body: queue.isEmpty
          ? const EmptyState(
              icon: Icons.playlist_add,
              title: 'No words saved yet',
              subtitle:
                  'During practice, tap the playlist icon on words you forget. They will appear here.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.playlist_add_check,
                            color: Colors.orange.shade800,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${queue.length} words to review',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Practice these until you remember them',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _startPractice(context),
                            child: const Text('Start'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final word = queue[index];
                      return WordTile(
                        word: word,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WordDetailScreen(word: word),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
