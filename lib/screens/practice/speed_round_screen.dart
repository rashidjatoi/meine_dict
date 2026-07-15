import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_mode.dart';
import '../../models/word.dart';
import '../../providers/word_provider.dart';
import '../../widgets/add_to_practice_button.dart';
import '../../widgets/pronounce_button.dart';

class SpeedRoundScreen extends StatefulWidget {
  const SpeedRoundScreen({
    super.key,
    required this.words,
    required this.direction,
  });

  final List<Word> words;
  final PracticeDirection direction;

  @override
  State<SpeedRoundScreen> createState() => _SpeedRoundScreenState();
}

class _SpeedRoundScreenState extends State<SpeedRoundScreen> {
  static const _timePerQuestion = 8;
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = _timePerQuestion;
  Timer? _timer;
  String? _selected;
  late List<String> _options;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _generateOptions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Word get _currentWord => widget.words[_currentIndex];

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _timePerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        _onTimeout();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _generateOptions() {
    final provider = context.read<WordProvider>();
    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correct = useGerman ? _currentWord.german : _currentWord.english;
    final distractors =
        provider.generateDistractors(_currentWord, useGerman: useGerman);
    _options = [correct, ...distractors];
    _options.shuffle(Random());
  }

  Future<void> _select(String option) async {
    if (_answered) return;
    _timer?.cancel();
    _answered = true;

    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correct = useGerman ? _currentWord.german : _currentWord.english;
    final isCorrect = option == correct;

    if (isCorrect) {
      final bonus = _timeLeft;
      setState(() => _score += 10 + bonus);
    }

    final provider = context.read<WordProvider>();
    await provider.recordAnswer(_currentWord.id, isCorrect);
    if (!isCorrect) {
      await provider.addToPracticeQueue(_currentWord.id);
    }
    setState(() => _selected = option);

    await Future.delayed(const Duration(milliseconds: 800));
    _next();
  }

  Future<void> _onTimeout() async {
    if (_answered) return;
    _answered = true;
    final provider = context.read<WordProvider>();
    await provider.recordAnswer(_currentWord.id, false);
    await provider.addToPracticeQueue(_currentWord.id);
    _next();
  }

  void _next() {
    if (_currentIndex >= widget.words.length - 1) {
      _timer?.cancel();
      _showResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _selected = null;
      _answered = false;
    });
    _generateOptions();
    _startTimer();
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Speed Round Over!'),
        content: Text('Final score: $_score points'),
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
    final useGerman = widget.direction == PracticeDirection.englishToGerman;
    final correct = useGerman ? _currentWord.german : _currentWord.english;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Round'),
        actions: [
          AddToPracticeButton(word: _currentWord, compact: true),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _timeLeft / _timePerQuestion,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: _timeLeft <= 3 ? Colors.red : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_timeLeft}s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 3 ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentIndex + 1} / ${widget.words.length}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 40),
            Text(
              prompt,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            PronounceButton(text: _currentWord.german),
            const SizedBox(height: 24),
            ..._options.map((option) {
              final isSelected = _selected == option;
              Color? bg;
              if (_selected != null) {
                if (option == correct) {
                  bg = Colors.green.shade100;
                } else if (isSelected) {
                  bg = Colors.red.shade100;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: bg ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _answered ? null : () => _select(option),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.3),
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
          ],
        ),
      ),
    );
  }
}
