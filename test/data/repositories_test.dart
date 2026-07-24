import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:teste_flutter/data/exceptions/persistencia_exception.dart';
import 'package:teste_flutter/data/models/agendamento.dart';
import 'package:teste_flutter/data/models/sala.dart';
import 'package:teste_flutter/data/repositories/agendamento_repository.dart';
import 'package:teste_flutter/data/repositories/log_repository.dart';
import 'package:teste_flutter/data/repositories/sala_repository.dart';

import '../helpers/db_helper.dart';

void main() {
  inicializarSqfliteFfi();

  late Database db;
  late SalaRepository salas;
  late AgendamentoRepository agendamentos;
  late LogRepository logs;

  setUp(() async {
    db = await abrirBancoEmMemoria();
    final provider = InMemoryDatabaseProvider(db);
    salas = SalaRepository(provider);
    agendamentos = AgendamentoRepository(provider);
    logs = LogRepository(provider);
  });

  tearDown(() async {
    await db.close();
  });

  group('SalaRepository', () {
    test('insere e lista salas ordenadas', () async {
      await salas.inserir(const Sala(nome: 'Sala B'));
      await salas.inserir(const Sala(nome: 'Sala A'));
      final lista = await salas.listar();
      expect(lista.map((s) => s.nome), ['Sala A', 'Sala B']);
    });

    test('nome duplicado vira PersistenciaException legivel', () async {
      await salas.inserir(const Sala(nome: 'Sala A'));
      expect(
        () => salas.inserir(const Sala(nome: 'Sala A')),
        throwsA(
          isA<PersistenciaException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('Já existe uma sala'),
          ),
        ),
      );
    });

    test('excluir sala com agendamento futuro vira mensagem legivel', () async {
      final id = await salas.inserir(const Sala(nome: 'Sala A'));
      final amanha = DateTime.now().add(const Duration(days: 1));
      await agendamentos.inserir(Agendamento(
        salaId: id,
        dataInicio: amanha,
        dataFim: amanha.add(const Duration(hours: 1)),
      ));
      expect(
        () => salas.excluir(id),
        throwsA(
          isA<PersistenciaException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('agendamento futuro'),
          ),
        ),
      );
    });
  });

  group('AgendamentoRepository', () {
    test('lista agendamentos com o nome da sala (JOIN)', () async {
      final id = await salas.inserir(const Sala(nome: 'Sala A'));
      await agendamentos.inserir(Agendamento(
        salaId: id,
        dataInicio: DateTime(2030, 1, 1, 10),
        dataFim: DateTime(2030, 1, 1, 11),
      ));
      final lista = await agendamentos.listar();
      expect(lista, hasLength(1));
      expect(lista.first.salaNome, 'Sala A');
      expect(lista.first.dataInicio, DateTime(2030, 1, 1, 10));
    });

    test('sobreposicao vira PersistenciaException legivel', () async {
      final id = await salas.inserir(const Sala(nome: 'Sala A'));
      await agendamentos.inserir(Agendamento(
        salaId: id,
        dataInicio: DateTime(2030, 1, 1, 10),
        dataFim: DateTime(2030, 1, 1, 11),
      ));
      expect(
        () => agendamentos.inserir(Agendamento(
          salaId: id,
          dataInicio: DateTime(2030, 1, 1, 10, 30),
          dataFim: DateTime(2030, 1, 1, 11, 30),
        )),
        throwsA(
          isA<PersistenciaException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('nesse horário'),
          ),
        ),
      );
    });
  });

  group('LogRepository', () {
    test('lista logs mais recentes primeiro', () async {
      await salas.inserir(const Sala(nome: 'Sala A'));
      final registros = await logs.listar();
      expect(registros, isNotEmpty);
      expect(registros.first.nomeTabela, 'sala');
      expect(registros.first.tipoOperacao, 'INSERT');
    });
  });
}
