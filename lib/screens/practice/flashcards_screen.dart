import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/practice_mode.dart';
import '../../models/word.dart';
import '../../providers/word_provider.dart';
import '../../widgets/add_to_practice_button.dart';
import '../../widgets/pronounce_button.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.words,
    required this.direction,
  });

  final List<Word> words;
  final PracticeDirection direction;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  int _known = 0;
  int _review = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Word get _currentWord => widget.words[_currentIndex];

  String get _front =>
      widget.direction == PracticeDirection.germanToEnglish
          ? _currentWord.german
          : _currentWord.english;

  String get _back =>
      widget.direction == PracticeDirection.germanToEnglish
          ? _currentWord.english
          : _currentWord.german;

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _rate(bool knew) async {
    final provider = context.read<WordProvider>();
    await provider.recordAnswer(_currentWord.id, knew);
    if (!knew) {
      await provider.addToPracticeQueue(_currentWord.id);
    }
    setState(() {
      if (knew) {
        _known++;
      } else {
        _review++;
      }
    });
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex >= widget.words.length - 1) {
      _showResults();
      return;
    }
    _flipController.reset();
    setState(() {
      _currentIndex++;
      _isFlipped = false;
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text(
          'You knew $_known cards and marked $_review for review.\n'
          'Total: ${widget.words.length} cards',
        ),
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
    final progress = (_currentIndex + 1) / widget.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          AddToPracticeButton(word: _currentWord, compact: true),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_currentIndex + 1}/${widget.words.length}'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Knew: $_known', style: TextStyle(color: Colors.green.shade700)),
                Text('Review: $_review', style: TextStyle(color: Colors.orange.shade700)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isUnder = angle > pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        color: isUnder
                            ? theme.colorScheme.secondaryContainer
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(isUnder ? pi : 0),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              isUnder ? _back : _front,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            PronounceButton(
              text: _currentWord.german,
              style: PronounceButtonStyle.filled,
              label: 'Hear pronunciation',
            ),
            const SizedBox(height: 8),
            AddToPracticeButton(word: _currentWord),
            const SizedBox(height: 8),
            Text(
              _isFlipped ? 'Tap to see front' : 'Tap to reveal answer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (_isFlipped) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rate(false),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Review'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _rate(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Knew it'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              FilledButton(
                onPressed: _flip,
                child: const Text('Reveal Answer'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
