enum WordSource { builtin, custom }

enum MasteryLevel { newWord, learning, familiar, mastered }

class Word {
  const Word({
    required this.id,
    required this.german,
    required this.english,
    this.rank,
    this.source = WordSource.builtin,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String german;
  final String english;
  final int? rank;
  final WordSource source;
  final String? notes;
  final DateTime? createdAt;

  factory Word.fromJson(Map<String, dynamic> json, {WordSource source = WordSource.builtin}) {
    final rank = json['rank'] as int?;
    final german = json['german'] as String;
    final english = json['english'] as String;
    final id = json['id'] as String? ??
        (rank != null
            ? 'builtin_$rank'
            : 'builtin_${german.toLowerCase()}_${english.toLowerCase()}'
                .replaceAll(RegExp(r'[^a-z0-9_]+'), '_'));
    return Word(
      id: id,
      german: german,
      english: english,
      rank: rank,
      source: source,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'german': german,
        'english': english,
        if (rank != null) 'rank': rank,
        'source': source.name,
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  Word copyWith({
    String? id,
    String? german,
    String? english,
    int? rank,
    WordSource? source,
    String? notes,
    DateTime? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      german: german ?? this.german,
      english: english ?? this.english,
      rank: rank ?? this.rank,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
