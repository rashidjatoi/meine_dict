import 'package:flutter/foundation.dart';

import '../models/word.dart';
import '../models/word_progress.dart';
import '../services/storage_service.dart';
import '../services/word_repository.dart';

class WordProvider extends ChangeNotifier {
  WordProvider() : _repository = WordRepository(StorageService());

  final WordRepository _repository;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<Word> get allWords => _repository.allWords;
  List<Word> get customWords => _repository.customWords;
  List<Word> get builtinWords => _repository.builtinWords;
  List<Word> get rankedWords => _repository.rankedWords;

  List<Word> get extendedWords => _repository.extendedWords;
  int get todayPracticedCount => _repository.todayPracticedCount;
  int get masteredCount => _repository.masteredCount;
  int get learningCount => _repository.learningCount;
  int get favoritesCount => _repository.getFavorites().length;
  int get practiceQueueCount => _repository.getPracticeQueue().length;

  List<Word> get displayedWords {
    if (_searchQuery.isEmpty) return allWords;
    return _repository.search(_searchQuery);
  }

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.initialize();
    } catch (e) {
      _error = 'Failed to load vocabulary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isFavorite(String wordId) => _repository.isFavorite(wordId);

  Future<void> toggleFavorite(String wordId) async {
    await _repository.toggleFavorite(wordId);
    notifyListeners();
  }

  bool isInPracticeQueue(String wordId) =>
      _repository.isInPracticeQueue(wordId);

  List<Word> getPracticeQueue() => _repository.getPracticeQueue();

  Future<bool> togglePracticeQueue(String wordId) async {
    final added = await _repository.togglePracticeQueue(wordId);
    notifyListeners();
    return added;
  }

  Future<void> addToPracticeQueue(String wordId) async {
    await _repository.addToPracticeQueue(wordId);
    notifyListeners();
  }

  WordProgress getProgress(String wordId) => _repository.getProgress(wordId);

  Future<void> recordAnswer(String wordId, bool correct) async {
    await _repository.recordAnswer(wordId, correct);
    notifyListeners();
  }

  Future<Word> addCustomWord({
    required String german,
    required String english,
    String? notes,
  }) async {
    final word = await _repository.addCustomWord(
      german: german,
      english: english,
      notes: notes,
    );
    notifyListeners();
    return word;
  }

  String exportVocabularyJson() => _repository.exportVocabularyJson();

  Future<void> importVocabularyJson(String jsonString) async {
    await _repository.importVocabularyJson(jsonString);
    notifyListeners();
  }

  Future<void> deleteCustomWord(String wordId) async {
    await _repository.deleteCustomWord(wordId);
    notifyListeners();
  }

  List<Word> getFavorites() => _repository.getFavorites();

  List<Word> getWordsForPractice({required String filter, int? limit}) {
    return _repository.getWordsForPractice(filter: filter, limit: limit);
  }

  List<String> generateDistractors(Word correct, {required bool useGerman}) {
    return _repository.generateDistractors(correct, useGerman: useGerman);
  }
}
