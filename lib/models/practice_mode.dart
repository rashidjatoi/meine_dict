enum PracticeMode {
  flashcards('Flashcards', 'Flip cards to test recall', 'style'),
  multipleChoice('Multiple Choice', 'Pick the correct translation', 'quiz'),
  typing('Type Answer', 'Type the translation from memory', 'keyboard'),
  reverseTyping('Reverse Typing', 'See English, type German', 'swap_horiz'),
  matching('Matching Game', 'Match German to English pairs', 'grid_view'),
  speedRound('Speed Round', 'Timed multiple choice challenge', 'timer');

  const PracticeMode(this.title, this.description, this.iconName);

  final String title;
  final String description;
  final String iconName;
}

enum PracticeFilter {
  all('All Words'),
  needPractice('Need Practice'),
  favorites('Favorites'),
  custom('My Words'),
  learning('Still Learning'),
  builtin('Common 1000');

  const PracticeFilter(this.label);

  final String label;
}

enum PracticeDirection {
  germanToEnglish('German → English'),
  englishToGerman('English → German');

  const PracticeDirection(this.label);

  final String label;
}
