import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/word_provider.dart';
import 'screens/main_shell.dart';
import 'services/tts_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TtsService.instance.initialize();
  runApp(const MeineDictApp());
}

class MeineDictApp extends StatelessWidget {
  const MeineDictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordProvider()..initialize(),
      child: MaterialApp(
        title: 'Meine Dict',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppLoader(),
      ),
    );
  }
}

class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading vocabulary...'),
            ],
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => provider.initialize(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const MainShell();
  }
}
