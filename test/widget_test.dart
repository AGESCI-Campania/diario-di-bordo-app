import 'package:flutter_test/flutter_test.dart';

import 'package:appgv/main.dart';

void main() {
  testWidgets('DiariApp si avvia senza errori', (WidgetTester tester) async {
    await tester.pumpWidget(const DiariApp());

    expect(find.text('Diari di Bordo'), findsWidgets);
  });
}
