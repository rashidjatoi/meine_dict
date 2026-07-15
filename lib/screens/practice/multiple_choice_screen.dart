import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_mode.dart';
import '../../models/word.dart';
import '../../providers/word_provider.dart';
import '../../widgets/add_to_practice_button.dart';
import '../../widgets/practice_result_banner.dart';
import '../../widgets/pronounce_button.dart';

class MultipleChoiceScreen extends StatefulWidget {
  const MultipleChoiceScreen({
    super.key,
    required this.words,
    required this.direction,
  });

  final List<Word> words;
  final PracticeDirection direction;

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int _currentIndex = 0;
  int _correct = 0;
  String? _selected;
  bool? _isCorrect;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  Word get _currentWord => widget.words[_currentIndex];

  void _generateOptions() {
    final provider = context.read<WordProvider>();
    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correctAnswer = useGerman ? _currentWord.german : _currentWord.english;
    final distractors =
        provider.generateDistractors(_currentWord, useGerman: useGerman);

    _options = [correctAnswer, ...distractors];
    _options.shuffle(Random());
  }

  Future<void> _select(String option) async {
    if (_selected != null) return;

    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correctAnswer = useGerman ? _currentWord.german : _currentWord.english;
    final isCorrect = option == correctAnswer;

    setState(() {
      _selected = option;
      _isCorrect = isCorrect;
      if (isCorrect) _correct++;
    });

    final provider = context.read<WordProvider>();
    await provider.recordAnswer(_currentWord.id, isCorrect);
    if (!isCorrect) {
      await provider.addToPracticeQueue(_currentWord.id);
    }
  }

  void _next() {
    if (_currentIndex >= widget.words.length - 1) {
      _showResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _selected = null;
      _isCorrect = null;
    });
    _generateOptions();
  }

  void _showResults() {
    final total = widget.words.length;
    final pct = (( _correct / total) * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Score: $_correct / $total ($pct%)'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prompt = widget.direction == PracticeDirection.germanToEnglish
        ? _currentWord.german
        : _currentWord.english;
    final promptLabel = widget.direction == PracticeDirection.germanToEnglish
        ? 'What does this mean?'
        : 'How do you say this in German?';
    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correctAnswer =
        useGerman ? _currentWord.german : _currentWord.english;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Choice'),
        actions: [
          AddToPracticeButton(word: _currentWord, compact: true),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Score: $_correct')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.words.length,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentIndex + 1} of ${widget.words.length}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Text(
              promptLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              prompt,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PronounceButton(
              text: _currentWord.german,
              style: PronounceButtonStyle.filled,
              label: 'Hear pronunciation',
            ),
            const SizedBox(height: 8),
            AddToPracticeButton(word: _currentWord),
            const SizedBox(height: 12),
            ..._options.map((option) {
              final isSelected = _selected == option;
              final isCorrectOption = option == correctAnswer;

              Color? bgColor;
              if (_selected != null) {
                if (isCorrectOption) {
                  bgColor = Colors.green.shade100;
                } else if (isSelected) {
                  bgColor = Colors.red.shade100;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: bgColor ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _selected == null ? () => _select(option) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        option,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            if (_selected != null)
              PracticeResultBanner(
                isCorrect: _isCorrect!,
                correctAnswer: correctAnswer,
                onContinue: _next,
              ),
          ],
        ),
      ),
    );
  }
}
