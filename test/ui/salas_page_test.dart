import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/data/models/sala.dart';
import 'package:teste_flutter/data/repositories/sala_repository.dart';
import 'package:teste_flutter/ui/salas/salas_page.dart';

class _FakeSalaRepository implements SalaRepository {
  final List<Sala> _salas = [];
  int _seq = 0;

  @override
  Future<int> inserir(Sala sala) async {
    _salas.add(sala.copyWith(id: ++_seq));
    return _seq;
  }

  @override
  Future<void> atualizar(Sala sala) async {
    final i = _salas.indexWhere((s) => s.id == sala.id);
    if (i != -1) _salas[i] = sala;
  }

  @override
  Future<void> excluir(int id) async {
    _salas.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<Sala>> listar() async => List.of(_salas);
}

void main() {
  testWidgets('carrega a lista vazia sem lançar exceção', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SalasPage(repository: _FakeSalaRepository())),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nenhuma sala cadastrada.'), findsOneWidget);
  });

  testWidgets('cadastra uma sala e ela aparece na lista', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SalasPage(repository: _FakeSalaRepository())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nova sala'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sala A');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Sala A'), findsOneWidget);
  });
}
