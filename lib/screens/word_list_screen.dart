import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/word_tile.dart';
import 'add_word_screen.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importVocabulary() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final provider = context.read<WordProvider>();

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      jsonDecode(jsonString);
      await provider.importVocabularyJson(jsonString);

      if (!mounted) return;

      messenger?.showSnackBar(
        const SnackBar(content: Text('Vocabulary imported successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(content: Text('Could not import vocabulary: $e')),
      );
    }
  }

  Future<void> _exportVocabulary() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final provider = context.read<WordProvider>();

    try {
      final savePath = await FilePicker.saveFile(
        dialogTitle: 'Save vocabulary as JSON',
        fileName: 'vocabulary.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (savePath == null) return;

      final file = File(savePath);
      await file.writeAsString(provider.exportVocabularyJson());

      if (!mounted) return;

      messenger?.showSnackBar(
        const SnackBar(content: Text('Vocabulary exported successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(content: Text('Could not export vocabulary: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') {
                _importVocabulary();
              } else if (value == 'export') {
                _exportVocabulary();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'import', child: Text('Import JSON')),
              PopupMenuItem(value: 'export', child: Text('Export JSON')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${provider.allWords.length})'),
            Tab(text: 'Common (${provider.rankedWords.length})'),
            Tab(
                text:
                    'Extended (${provider.builtinWords.length - provider.rankedWords.length})'),
            Tab(text: 'My Words (${provider.customWords.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search German or English...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _WordList(words: provider.displayedWords),
                _WordList(
                  words: provider.searchQuery.isEmpty
                      ? provider.rankedWords
                      : provider.displayedWords
                          .where((w) => provider.rankedWords.contains(w))
                          .toList(),
                ),
                _WordList(
                  words: provider.searchQuery.isEmpty
                      ? provider.extendedWords
                      : provider.displayedWords
                          .where((w) => provider.extendedWords.contains(w))
                          .toList(),
                ),
                _WordList(
                  words: provider.searchQuery.isEmpty
                      ? provider.customWords
                      : provider.displayedWords
                          .where((w) => provider.customWords.contains(w))
                          .toList(),
                  emptyMessage: 'No custom words yet',
                  emptyAction: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddWordScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first word'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({
    required this.words,
    this.emptyMessage,
    this.emptyAction,
  });

  final List<Word> words;
  final String? emptyMessage;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(emptyMessage ?? 'No words found'),
            if (emptyAction != null) ...[
              const SizedBox(height: 16),
              emptyAction!,
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
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
    );
  }
}
