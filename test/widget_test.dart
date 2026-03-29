import 'package:flutter_test/flutter_test.dart';
import 'package:lista_ai/app.dart';

void main() {
  testWidgets('App exibe texto de setup', (WidgetTester tester) async {
    await tester.pumpWidget(const ListaAiApp());
    expect(find.text('Lista AI - Setup OK!'), findsOneWidget);
  });
}
