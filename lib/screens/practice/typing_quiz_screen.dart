import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_mode.dart';
import '../../models/word.dart';
import '../../providers/word_provider.dart';
import '../../widgets/add_to_practice_button.dart';
import '../../widgets/practice_result_banner.dart';
import '../../widgets/pronounce_button.dart';

class TypingQuizScreen extends StatefulWidget {
  const TypingQuizScreen({
    super.key,
    required this.words,
    required this.direction,
  });

  final List<Word> words;
  final PracticeDirection direction;

  @override
  State<TypingQuizScreen> createState() => _TypingQuizScreenState();
}

class _TypingQuizScreenState extends State<TypingQuizScreen> {
  int _currentIndex = 0;
  int _correct = 0;
  final _controller = TextEditingController();
  bool? _isCorrect;
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Word get _currentWord => widget.words[_currentIndex];

  String get _prompt =>
      widget.direction == PracticeDirection.germanToEnglish
          ? _currentWord.german
          : _currentWord.english;

  String get _answer =>
      widget.direction == PracticeDirection.germanToEnglish
          ? _currentWord.english
          : _currentWord.german;

  String get _promptLabel =>
      widget.direction == PracticeDirection.germanToEnglish
          ? 'Type the English translation'
          : 'Type the German word';

  bool _checkAnswer(String input) {
    final normalized = input.trim().toLowerCase();
    final expected = _answer.toLowerCase();
    if (normalized == expected) return true;

    final alternatives = expected.split('/').map((s) => s.trim()).toList();
    return alternatives.any((alt) => normalized == alt);
  }

  Future<void> _submit() async {
    if (_submitted) return;
    final isCorrect = _checkAnswer(_controller.text);
    setState(() {
      _submitted = true;
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
      _controller.clear();
      _submitted = false;
      _isCorrect = null;
    });
  }

  void _showResults() {
    final total = widget.words.length;
    final pct = ((_correct / total) * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Typing Quiz Complete!'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.direction == PracticeDirection.germanToEnglish
              ? 'Type Answer'
              : 'Reverse Typing',
        ),
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
              'Word ${_currentIndex + 1} of ${widget.words.length}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 40),
            Text(
              _promptLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _prompt,
              style: theme.textTheme.headlineLarge?.copyWith(
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
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              enabled: !_submitted,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              textCapitalization: widget.direction ==
                      PracticeDirection.englishToGerman
                  ? TextCapitalization.sentences
                  : TextCapitalization.none,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                suffixIcon: _submitted
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submit,
                      ),
              ),
              autofocus: true,
            ),
            const Spacer(),
            if (!_submitted)
              FilledButton(
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
                child: const Text('Check Answer'),
              )
            else
              PracticeResultBanner(
                isCorrect: _isCorrect!,
                correctAnswer: _answer,
                onContinue: _next,
              ),
          ],
        ),
      ),
    );
  }
}
