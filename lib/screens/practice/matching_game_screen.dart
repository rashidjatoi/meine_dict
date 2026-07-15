import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/word.dart';
import '../../providers/word_provider.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key, required this.words});

  final List<Word> words;

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late final List<Word> _roundWords;
  String? _selectedGerman;
  String? _selectedEnglish;
  final Set<String> _matchedIds = {};
  int _mistakes = 0;
  bool _showMismatch = false;

  @override
  void initState() {
    super.initState();
    _roundWords = widget.words.take(min(6, widget.words.length)).toList();
  }

  List<Word> get _unmatched =>
      _roundWords.where((w) => !_matchedIds.contains(w.id)).toList();

  Future<void> _selectGerman(String id) async {
    if (_matchedIds.contains(id) || _showMismatch) return;
    setState(() => _selectedGerman = id);
    _checkMatch();
  }

  Future<void> _selectEnglish(String id) async {
    if (_matchedIds.contains(id) || _showMismatch) return;
    setState(() => _selectedEnglish = id);
    _checkMatch();
  }

  Future<void> _checkMatch() async {
    if (_selectedGerman == null || _selectedEnglish == null) return;

    if (_selectedGerman == _selectedEnglish) {
      final provider = context.read<WordProvider>();
      await provider.recordAnswer(_selectedGerman!, true);
      setState(() {
        _matchedIds.add(_selectedGerman!);
        _selectedGerman = null;
        _selectedEnglish = null;
      });

      if (_matchedIds.length == _roundWords.length) {
        _showComplete();
      }
    } else {
      setState(() {
        _mistakes++;
        _showMismatch = true;
      });
      final provider = context.read<WordProvider>();
      await provider.recordAnswer(_selectedGerman!, false);

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _selectedGerman = null;
          _selectedEnglish = null;
          _showMismatch = false;
        });
      }
    }
  }

  void _showComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('All matched!'),
        content: Text(
          'You matched all ${_roundWords.length} pairs'
          '${_mistakes > 0 ? ' with $_mistakes mistakes' : ' perfectly'}!',
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
    final germanWords = List<Word>.from(_unmatched)..shuffle(Random());
    final englishWords = List<Word>.from(_unmatched)..shuffle(Random());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Game'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_matchedIds.length}/${_roundWords.length}'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Match German words to their English translations',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_mistakes > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Mistakes: $_mistakes',
                style: TextStyle(color: Colors.orange.shade800),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MatchColumn(
                      title: 'German',
                      words: germanWords,
                      selectedId: _selectedGerman,
                      matchedIds: _matchedIds,
                      showText: (w) => w.german,
                      isMismatch: _showMismatch,
                      onTap: _selectGerman,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MatchColumn(
                      title: 'English',
                      words: englishWords,
                      selectedId: _selectedEnglish,
                      matchedIds: _matchedIds,
                      showText: (w) => w.english,
                      isMismatch: _showMismatch,
                      onTap: _selectEnglish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchColumn extends StatelessWidget {
  const _MatchColumn({
    required this.title,
    required this.words,
    required this.selectedId,
    required this.matchedIds,
    required this.showText,
    required this.isMismatch,
    required this.onTap,
  });

  final String title;
  final List<Word> words;
  final String? selectedId;
  final Set<String> matchedIds;
  final String Function(Word) showText;
  final bool isMismatch;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              final isSelected = selectedId == word.id;
              final isMatched = matchedIds.contains(word.id);

              Color? bg;
              if (isMatched) {
                bg = Colors.green.shade100;
              } else if (isMismatch && isSelected) {
                bg = Colors.red.shade100;
              } else if (isSelected) {
                bg = theme.colorScheme.primaryContainer;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: bg ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: isMatched ? null : () => onTap(word.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        showText(word),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          decoration:
                              isMatched ? TextDecoration.lineThrough : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
