import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meine_dict/services/storage_service.dart';
import 'package:meine_dict/services/word_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('parses list-based and object-based vocabulary payloads', () {
    final fromList = parseWordsFromJson(
      jsonDecode('[{"german":"Hallo","english":"Hello","rank":1}]'),
    );
    expect(fromList, hasLength(1));
    expect(fromList.first.german, 'Hallo');
    expect(fromList.first.english, 'Hello');

    final fromMap = parseWordsFromJson(
      jsonDecode('{"hello":"hallo"}'),
    );
    expect(fromMap, hasLength(1));
    expect(fromMap.first.german, 'hallo');
    expect(fromMap.first.english, 'hello');
  });

  test('exports and imports vocabulary JSON preserving custom words', () async {
    final repository = WordRepository(StorageService());
    await repository.addCustomWord(german: 'Apfel', english: 'apple');

    final exported = repository.exportVocabularyJson();
    final payload = jsonDecode(exported) as List<dynamic>;
    expect(payload, hasLength(1));

    final imported = WordRepository(StorageService());
    await imported.importVocabularyJson(exported);

    expect(imported.customWords, hasLength(1));
    expect(imported.customWords.first.german, 'Apfel');
    expect(imported.customWords.first.english, 'apple');
  });
}
