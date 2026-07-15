import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/word_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/word_tile.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final favorites = provider.getFavorites();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle:
                  'Tap the heart on any word to save it here for quick practice.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final word = favorites[index];
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
    );
  }
}
