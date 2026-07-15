import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/practice_mode.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import 'practice/flashcards_screen.dart';
import 'practice/matching_game_screen.dart';
import 'practice/multiple_choice_screen.dart';
import 'practice/speed_round_screen.dart';
import 'practice/typing_quiz_screen.dart';
import 'practice_queue_screen.dart';

class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  static void startPractice(BuildContext context, {required String mode}) {
    final hub = context.findAncestorStateOfType<_PracticeHubScreenState>();
    if (hub != null) {
      hub._launchMode(_modeFromKey(mode));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PracticeLauncher(mode: _modeFromKey(mode)),
        ),
      );
    }
  }

  static PracticeMode _modeFromKey(String key) => switch (key) {
        'flashcards' => PracticeMode.flashcards,
        'multipleChoice' => PracticeMode.multipleChoice,
        'typing' => PracticeMode.typing,
        'reverseTyping' => PracticeMode.reverseTyping,
        'matching' => PracticeMode.matching,
        'speedRound' => PracticeMode.speedRound,
        _ => PracticeMode.flashcards,
      };

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  PracticeFilter _filter = PracticeFilter.all;
  PracticeDirection _direction = PracticeDirection.germanToEnglish;
  int _wordCount = 20;

  void _launchMode(PracticeMode mode) {
    final provider = context.read<WordProvider>();
    final words = provider.getWordsForPractice(
      filter: _filter.name,
      limit: _wordCount,
    );

    if (words.length < 4 && mode == PracticeMode.matching) {
      _showNotEnoughWords(minRequired: 4);
      return;
    }
    if (words.isEmpty) {
      _showNotEnoughWords(minRequired: 1);
      return;
    }

    final screen = _buildPracticeScreen(mode, words);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildPracticeScreen(PracticeMode mode, List<Word> words) {
    return switch (mode) {
      PracticeMode.flashcards => FlashcardsScreen(
          words: words,
          direction: _direction,
        ),
      PracticeMode.multipleChoice => MultipleChoiceScreen(
          words: words,
          direction: _direction,
        ),
      PracticeMode.typing => TypingQuizScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
      PracticeMode.reverseTyping => TypingQuizScreen(
          words: words,
          direction: PracticeDirection.englishToGerman,
        ),
      PracticeMode.matching => MatchingGameScreen(words: words),
      PracticeMode.speedRound => SpeedRoundScreen(
          words: words,
          direction: _direction,
        ),
    };
  }

  void _showNotEnoughWords({required int minRequired}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Not enough words for this practice. Need at least $minRequired. Try a different filter.',
        ),
      ),
    );
  }

  IconData _iconForMode(PracticeMode mode) => switch (mode) {
        PracticeMode.flashcards => Icons.style,
        PracticeMode.multipleChoice => Icons.quiz,
        PracticeMode.typing => Icons.keyboard,
        PracticeMode.reverseTyping => Icons.swap_horiz,
        PracticeMode.matching => Icons.grid_view,
        PracticeMode.speedRound => Icons.timer,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WordProvider>();
    final queueCount = provider.practiceQueueCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PracticeQueueScreen()),
              );
            },
            tooltip: 'Need Practice list',
            icon: Badge(
              isLabelVisible: queueCount > 0,
              label: Text('$queueCount'),
              child: const Icon(Icons.playlist_add_check),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (queueCount > 0) ...[
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: Icon(
                  Icons.playlist_add_check,
                  color: Colors.orange.shade800,
                ),
                title: Text(
                  '$queueCount words need practice',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Tap to review words you forgot'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PracticeQueueScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Practice Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Word set', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PracticeFilter.values.map((f) {
                      final count =
                          f == PracticeFilter.needPractice ? queueCount : null;
                      return FilterChip(
                        label: Text(
                          count != null && count > 0
                              ? '${f.label} ($count)'
                              : f.label,
                        ),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Direction', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  // Make segmented control scrollable horizontally to avoid overflow
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<PracticeDirection>(
                      segments: PracticeDirection.values
                          .map((d) => ButtonSegment(
                                value: d,
                                label: Text(
                                  d.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                      selected: {_direction},
                      onSelectionChanged: (s) =>
                          setState(() => _direction = s.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Words per session: $_wordCount',
                      style: theme.textTheme.labelLarge),
                  Slider(
                    value: _wordCount.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$_wordCount',
                    onChanged: (v) => setState(() => _wordCount = v.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose a Mode',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...PracticeMode.values.map((mode) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(_iconForMode(mode)),
                  ),
                  title: Text(
                    mode.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(mode.description),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _launchMode(mode),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PracticeLauncher extends StatelessWidget {
  const _PracticeLauncher({required this.mode});

  final PracticeMode mode;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WordProvider>();
    final words = provider.getWordsForPractice(filter: 'all', limit: 20);

    return switch (mode) {
      PracticeMode.flashcards => FlashcardsScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
      PracticeMode.multipleChoice => MultipleChoiceScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
      PracticeMode.typing => TypingQuizScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
      PracticeMode.reverseTyping => TypingQuizScreen(
          words: words,
          direction: PracticeDirection.englishToGerman,
        ),
      PracticeMode.matching => MatchingGameScreen(words: words),
      PracticeMode.speedRound => SpeedRoundScreen(
          words: words,
          direction: PracticeDirection.germanToEnglish,
        ),
    };
  }
}
