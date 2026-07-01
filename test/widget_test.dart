import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:appgv/main.dart';

void main() {
  // `main.dart` legge subito la sessione da `flutter_secure_storage`: senza
  // un mock del suo MethodChannel il test fallisce con
  // MissingPluginException prima ancora di poter verificare la UI.
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              return null;
            case 'readAll':
              return <String, String>{};
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('DiariApp mostra il login quando non c\'è una sessione salvata', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DiariApp()));
    await tester.pumpAndSettle();

    expect(find.text('Diari di Bordo'), findsWidgets);
    expect(find.text('Accedi'), findsOneWidget);
  });
}
