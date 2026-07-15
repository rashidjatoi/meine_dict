import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/word.dart';
import '../models/word_progress.dart';
import 'storage_service.dart';

List<Word> parseWordsFromJson(
  dynamic payload, {
  WordSource source = WordSource.builtin,
}) {
  final words = <Word>[];
  final seen = <String>{};

  void addWord(Word word) {
    final key =
        '${word.german.toLowerCase().trim()}::${word.english.toLowerCase().trim()}';
    if (seen.add(key)) {
      words.add(word);
    }
  }

  if (payload is List) {
    for (final item in payload) {
      if (item is Map<String, dynamic>) {
        addWord(Word.fromJson(item, source: source));
      } else if (item is Map) {
        addWord(Word.fromJson(Map<String, dynamic>.from(item), source: source));
      }
    }
  } else if (payload is Map) {
    for (final entry in payload.entries) {
      final english = entry.key.toString();
      final german = entry.value.toString();
      addWord(
        Word.fromJson(
          {'german': german, 'english': english},
          source: source,
        ),
      );
    }
  }

  return words;
}

class WordRepository {
  WordRepository(this._storage);

  final StorageService _storage;
  final _random = Random();

  List<Word> _builtinWords = [];
  List<Word> _customWords = [];
  Set<String> _favorites = {};
  Set<String> _practiceQueue = {};
  Map<String, WordProgress> _progress = {};
  Map<String, int> _dailyStats = {};

  List<Word> get allWords => [..._builtinWords, ..._customWords];

  List<Word> get builtinWords => List.unmodifiable(_builtinWords);

  List<Word> get rankedWords =>
      _builtinWords.where((w) => w.rank != null).toList();

  List<Word> get extendedWords =>
      _builtinWords.where((w) => w.rank == null).toList();

  List<Word> get customWords => List.unmodifiable(_customWords);

  Set<String> get favorites => Set.unmodifiable(_favorites);

  Map<String, WordProgress> get progress => Map.unmodifiable(_progress);

  int get todayPracticedCount {
    final today = _todayKey();
    return _dailyStats[today] ?? 0;
  }

  Future<void> initialize() async {
    final assets = [
      'lib/src/german_vocabulary.json',
      'lib/src/vocabeo_vocabulary.json',
      'lib/src/1000_most_common_german_words.json',
      'lib/src/english_german.json',
    ];

    final loadedWords = <Word>[];
    for (final asset in assets) {
      final jsonString = await rootBundle.loadString(asset);
      final decoded = jsonDecode(jsonString);
      loadedWords.addAll(parseWordsFromJson(decoded));
    }

    _builtinWords = loadedWords;

    _customWords = await _storage.loadCustomWords();
    _favorites = await _storage.loadFavorites();
    _practiceQueue = await _storage.loadPracticeQueue();
    _progress = await _storage.loadProgress();
    _dailyStats = await _storage.loadDailyStats();
  }

  String exportVocabularyJson() {
    final allWords = [..._builtinWords, ..._customWords];
    final payload = allWords.map((word) => word.toJson()).toList();
    return jsonEncode(payload);
  }

  Future<void> importVocabularyJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    final importedWords =
        parseWordsFromJson(decoded, source: WordSource.custom);

    final mergedWords = <Word>[];
    final seen = <String>{};

    void addWord(Word word) {
      final key =
          '${word.german.toLowerCase().trim()}::${word.english.toLowerCase().trim()}';
      if (seen.add(key)) {
        mergedWords.add(word);
      }
    }

    for (final word in _customWords) {
      addWord(word);
    }

    for (final word in importedWords) {
      addWord(word);
    }

    _customWords = mergedWords;
    await _storage.saveCustomWords(_customWords);
  }

  List<Word> search(String query) {
    if (query.trim().isEmpty) return allWords;
    final q = query.toLowerCase().trim();
    return allWords.where((w) {
      return w.german.toLowerCase().contains(q) ||
          w.english.toLowerCase().contains(q);
    }).toList();
  }

  List<Word> getFavorites() {
    return allWords.where((w) => _favorites.contains(w.id)).toList();
  }

  bool isFavorite(String wordId) => _favorites.contains(wordId);

  Future<void> toggleFavorite(String wordId) async {
    if (_favorites.contains(wordId)) {
      _favorites.remove(wordId);
    } else {
      _favorites.add(wordId);
    }
    await _storage.saveFavorites(_favorites);
  }

  bool isInPracticeQueue(String wordId) => _practiceQueue.contains(wordId);

  List<Word> getPracticeQueue() {
    return allWords.where((w) => _practiceQueue.contains(w.id)).toList();
  }

  Future<bool> togglePracticeQueue(String wordId) async {
    if (_practiceQueue.contains(wordId)) {
      _practiceQueue.remove(wordId);
      await _storage.savePracticeQueue(_practiceQueue);
      return false;
    }

    _practiceQueue.add(wordId);
    await _storage.savePracticeQueue(_practiceQueue);
    return true;
  }

  Future<void> addToPracticeQueue(String wordId) async {
    if (_practiceQueue.contains(wordId)) return;
    _practiceQueue.add(wordId);
    await _storage.savePracticeQueue(_practiceQueue);
  }

  Future<void> removeFromPracticeQueue(String wordId) async {
    _practiceQueue.remove(wordId);
    await _storage.savePracticeQueue(_practiceQueue);
  }

  WordProgress getProgress(String wordId) {
    return _progress[wordId] ?? const WordProgress();
  }

  Future<void> recordAnswer(String wordId, bool correct) async {
    final current = getProgress(wordId);
    final updated = current.copyWith(
      correctCount: correct ? current.correctCount + 1 : current.correctCount,
      incorrectCount:
          correct ? current.incorrectCount : current.incorrectCount + 1,
      lastPracticed: DateTime.now(),
      masteryLevel: WordProgress.calculateMastery(
        correct ? current.correctCount + 1 : current.correctCount,
        correct ? current.incorrectCount : current.incorrectCount + 1,
      ),
    );
    _progress[wordId] = updated;
    await _storage.saveProgress(_progress);

    final today = _todayKey();
    _dailyStats[today] = (_dailyStats[today] ?? 0) + 1;
    await _storage.saveDailyStats(_dailyStats);
  }

  Future<Word> addCustomWord({
    required String german,
    required String english,
    String? notes,
  }) async {
    final word = Word(
      id: 'custom_${const Uuid().v4()}',
      german: german.trim(),
      english: english.trim(),
      source: WordSource.custom,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );
    _customWords.insert(0, word);
    await _storage.saveCustomWords(_customWords);
    return word;
  }

  Future<void> deleteCustomWord(String wordId) async {
    _customWords.removeWhere((w) => w.id == wordId);
    _favorites.remove(wordId);
    _practiceQueue.remove(wordId);
    _progress.remove(wordId);
    await _storage.saveCustomWords(_customWords);
    await _storage.saveFavorites(_favorites);
    await _storage.savePracticeQueue(_practiceQueue);
    await _storage.saveProgress(_progress);
  }

  List<Word> getWordsForPractice({
    required String filter,
    int? limit,
  }) {
    List<Word> words;
    switch (filter) {
      case 'needPractice':
        words = getPracticeQueue();
      case 'favorites':
        words = getFavorites();
      case 'custom':
        words = List.from(_customWords);
      case 'learning':
        words = allWords.where((w) {
          final p = getProgress(w.id);
          return p.masteryLevel == MasteryLevel.learning ||
              p.masteryLevel == MasteryLevel.newWord;
        }).toList();
      case 'builtin':
        words = List.from(rankedWords);
      default:
        words = List.from(allWords);
    }

    words.shuffle(_random);
    if (limit != null && words.length > limit) {
      return words.sublist(0, limit);
    }
    return words;
  }

  List<String> generateDistractors(Word correct, {required bool useGerman}) {
    final pool = allWords.where((w) => w.id != correct.id).toList();
    pool.shuffle(_random);
    final distractors =
        pool.take(3).map((w) => useGerman ? w.german : w.english).toList();
    return distractors;
  }

  int get masteredCount => allWords
      .where((w) => getProgress(w.id).masteryLevel == MasteryLevel.mastered)
      .length;

  int get learningCount => allWords.where((w) {
        final level = getProgress(w.id).masteryLevel;
        return level == MasteryLevel.learning || level == MasteryLevel.familiar;
      }).length;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
