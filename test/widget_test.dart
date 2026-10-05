import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kornsai_app/main.dart';
import 'package:kornsai_app/providers/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const KornsaiApp(),
      ),
    );

    expect(find.text('ก่อนสาย'), findsWidgets);
  });
}
