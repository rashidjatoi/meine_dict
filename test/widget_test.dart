import 'package:flutter_test/flutter_test.dart';

import 'package:meine_dict/main.dart';

void main() {
  testWidgets('App shows loading then home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MeineDictApp());

    expect(find.text('Loading vocabulary...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Meine Dict'), findsOneWidget);
    expect(find.text('Willkommen!'), findsOneWidget);
  });
}
