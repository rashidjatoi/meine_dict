import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word.dart';
import '../models/word_progress.dart';

class StorageService {
  static const _favoritesKey = 'favorites';
  static const _practiceQueueKey = 'practice_queue';
  static const _customWordsKey = 'custom_words';
  static const _progressKey = 'word_progress';
  static const _dailyStatsKey = 'daily_stats';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey)?.toSet() ?? {};
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<Set<String>> loadPracticeQueue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_practiceQueueKey)?.toSet() ?? {};
  }

  Future<void> savePracticeQueue(Set<String> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_practiceQueueKey, queue.toList());
  }

  Future<List<Word>> loadCustomWords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customWordsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Word.fromJson(e as Map<String, dynamic>, source: WordSource.custom))
        .toList();
  }

  Future<void> saveCustomWords(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(words.map((w) => w.toJson()).toList());
    await prefs.setString(_customWordsKey, encoded);
  }

  Future<Map<String, WordProgress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return {};

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        key,
        WordProgress.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> saveProgress(Map<String, WordProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      progress.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_progressKey, encoded);
  }

  Future<Map<String, int>> loadDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dailyStatsKey);
    if (raw == null) return {};

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> saveDailyStats(Map<String, int> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyStatsKey, jsonEncode(stats));
  }
}
