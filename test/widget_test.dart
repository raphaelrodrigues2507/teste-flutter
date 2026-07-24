import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/main.dart';

void main() {
  testWidgets('app inicia exibindo o titulo', (tester) async {
    await tester.pumpWidget(const CoworkingApp());
    expect(find.text('Agendamento de Salas'), findsWidgets);
  });
}
