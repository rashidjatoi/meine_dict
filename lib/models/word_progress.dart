import 'word.dart';

class WordProgress {
  const WordProgress({
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastPracticed,
    this.masteryLevel = MasteryLevel.newWord,
  });

  final int correctCount;
  final int incorrectCount;
  final DateTime? lastPracticed;
  final MasteryLevel masteryLevel;

  int get totalAttempts => correctCount + incorrectCount;

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctCount / totalAttempts;

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      correctCount: json['correctCount'] as int? ?? 0,
      incorrectCount: json['incorrectCount'] as int? ?? 0,
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'] as String)
          : null,
      masteryLevel: MasteryLevel.values.firstWhere(
        (e) => e.name == json['masteryLevel'],
        orElse: () => MasteryLevel.newWord,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'correctCount': correctCount,
        'incorrectCount': incorrectCount,
        if (lastPracticed != null)
          'lastPracticed': lastPracticed!.toIso8601String(),
        'masteryLevel': masteryLevel.name,
      };

  WordProgress copyWith({
    int? correctCount,
    int? incorrectCount,
    DateTime? lastPracticed,
    MasteryLevel? masteryLevel,
  }) {
    return WordProgress(
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  static MasteryLevel calculateMastery(int correct, int incorrect) {
    if (correct >= 5 && incorrect <= 1) return MasteryLevel.mastered;
    if (correct >= 3) return MasteryLevel.familiar;
    if (correct >= 1 || incorrect >= 1) return MasteryLevel.learning;
    return MasteryLevel.newWord;
  }
}
