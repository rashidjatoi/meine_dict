import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/word_provider.dart';
import '../widgets/stat_card.dart';
import 'practice_hub_screen.dart';
import 'word_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final theme = Theme.of(context);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(child: Text(provider.error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Dict'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.flag, size: 16),
              label: const Text('Deutsch'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Willkommen!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Practice ${provider.builtinWords.length} German words',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // Reduce the aspect ratio so cards get a bit more vertical space
            childAspectRatio: 1.05,
            children: [
              StatCard(
                label: 'Total Words',
                value: '${provider.allWords.length}',
                icon: Icons.library_books,
              ),
              StatCard(
                label: 'Practiced Today',
                value: '${provider.todayPracticedCount}',
                icon: Icons.today,
                color: theme.colorScheme.tertiary,
              ),
              StatCard(
                label: 'Mastered',
                value: '${provider.masteredCount}',
                icon: Icons.emoji_events,
                color: Colors.amber.shade700,
              ),
              StatCard(
                label: 'Favorites',
                value: '${provider.favoritesCount}',
                icon: Icons.favorite,
                color: Colors.red.shade400,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Quick Start',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _QuickActionCard(
            icon: Icons.style,
            title: 'Flashcards',
            subtitle: 'Flip through cards and rate yourself',
            color: theme.colorScheme.primaryContainer,
            onTap: () => PracticeHubScreen.startPractice(
              context,
              mode: 'flashcards',
            ),
          ),
          const SizedBox(height: 10),
          _QuickActionCard(
            icon: Icons.quiz,
            title: 'Multiple Choice Quiz',
            subtitle: 'Pick the right translation from 4 options',
            color: theme.colorScheme.secondaryContainer,
            onTap: () => PracticeHubScreen.startPractice(
              context,
              mode: 'multipleChoice',
            ),
          ),
          const SizedBox(height: 10),
          _QuickActionCard(
            icon: Icons.keyboard,
            title: 'Type the Answer',
            subtitle: 'Test your recall by typing translations',
            color: theme.colorScheme.tertiaryContainer,
            onTap: () => PracticeHubScreen.startPractice(
              context,
              mode: 'typing',
            ),
          ),
          const SizedBox(height: 10),
          _QuickActionCard(
            icon: Icons.menu_book,
            title: 'Browse All Words',
            subtitle:
                '${provider.builtinWords.length} built-in words + your custom vocab',
            color: theme.colorScheme.surfaceContainerHighest,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WordListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
