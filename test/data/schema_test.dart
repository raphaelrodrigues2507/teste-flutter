import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/db_helper.dart';

void main() {
  inicializarSqfliteFfi();

  late Database db;

  setUp(() async {
    db = await abrirBancoEmMemoria();
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> inserirSala(String nome) =>
      db.insert('sala', {'nome': nome});

  Future<int> inserirAgendamento(int salaId, DateTime inicio, DateTime fim) =>
      db.insert('agendamento', {
        'sala_id': salaId,
        'data_inicio': fmt(inicio),
        'data_fim': fmt(fim),
      });

  group('estrutura', () {
    test('cria as tabelas sala, agendamento e log_operacao', () async {
      final tabelas = (await db.query('sqlite_master',
              columns: ['name'], where: "type = 'table'"))
          .map((l) => l['name'])
          .toSet();
      expect(tabelas, containsAll(['sala', 'agendamento', 'log_operacao']));
    });
  });

  group('sala', () {
    test('insere sala com nome valido', () async {
      final id = await inserirSala('Sala A');
      expect(id, greaterThan(0));
    });

    test('nome nao pode se repetir (UNIQUE)', () async {
      await inserirSala('Sala A');
      expect(
        () => inserirSala('Sala A'),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('nome obrigatorio: rejeita vazio/espacos (CHECK)', () async {
      expect(
        () => inserirSala('   '),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('agendamento', () {
    late int salaId;

    setUp(() async {
      salaId = await inserirSala('Sala A');
    });

    test('insere agendamento valido', () async {
      final id = await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      expect(id, greaterThan(0));
    });

    test('data_fim deve ser maior que data_inicio (CHECK)', () async {
      expect(
        () => inserirAgendamento(
          salaId,
          DateTime(2030, 1, 1, 11),
          DateTime(2030, 1, 1, 10),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('data_fim igual a data_inicio e rejeitada (CHECK)', () async {
      expect(
        () => inserirAgendamento(
          salaId,
          DateTime(2030, 1, 1, 10),
          DateTime(2030, 1, 1, 10),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('sala obrigatoria e valida (FOREIGN KEY)', () async {
      expect(
        () => inserirAgendamento(
          99999,
          DateTime(2030, 1, 1, 10),
          DateTime(2030, 1, 1, 11),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejeita sobreposicao na mesma sala', () async {
      await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      expect(
        () => inserirAgendamento(
          salaId,
          DateTime(2030, 1, 1, 10, 30),
          DateTime(2030, 1, 1, 11, 30),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('permite agendamentos adjacentes (fim == proximo inicio)', () async {
      await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      final id = await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 11),
        DateTime(2030, 1, 1, 12),
      );
      expect(id, greaterThan(0));
    });

    test('mesma faixa em salas diferentes e permitida', () async {
      final salaB = await inserirSala('Sala B');
      await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      final id = await inserirAgendamento(
        salaB,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      expect(id, greaterThan(0));
    });

    test('update nao conflita com o proprio registro', () async {
      final id = await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      final alterados = await db.update(
        'agendamento',
        {'data_fim': fmt(DateTime(2030, 1, 1, 11, 30))},
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(alterados, 1);
    });

    test('update que gera sobreposicao e rejeitado', () async {
      await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );
      final id2 = await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 12),
        DateTime(2030, 1, 1, 13),
      );
      expect(
        () => db.update(
          'agendamento',
          {'data_inicio': fmt(DateTime(2030, 1, 1, 10, 30))},
          where: 'id = ?',
          whereArgs: [id2],
        ),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('exclusao de sala', () {
    test('bloqueia exclusao com agendamento futuro', () async {
      final salaId = await inserirSala('Sala A');
      final amanha = DateTime.now().add(const Duration(days: 1));
      await inserirAgendamento(
        salaId,
        amanha,
        amanha.add(const Duration(hours: 1)),
      );
      expect(
        () => db.delete('sala', where: 'id = ?', whereArgs: [salaId]),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('permite exclusao quando so ha agendamento passado', () async {
      final salaId = await inserirSala('Sala A');
      final ontem = DateTime.now().subtract(const Duration(days: 2));
      await inserirAgendamento(
        salaId,
        ontem,
        ontem.add(const Duration(hours: 1)),
      );
      final removidos =
          await db.delete('sala', where: 'id = ?', whereArgs: [salaId]);
      expect(removidos, 1);
    });

    test('permite exclusao de sala sem agendamentos', () async {
      final salaId = await inserirSala('Sala A');
      final removidos =
          await db.delete('sala', where: 'id = ?', whereArgs: [salaId]);
      expect(removidos, 1);
    });
  });

  group('log_operacao', () {
    Future<List<Map<String, Object?>>> logs() =>
        db.query('log_operacao', orderBy: 'id');

    test('registra INSERT, UPDATE e DELETE de sala', () async {
      final id = await inserirSala('Sala A');
      await db.update('sala', {'nome': 'Sala B'},
          where: 'id = ?', whereArgs: [id]);
      await db.delete('sala', where: 'id = ?', whereArgs: [id]);

      final registros = await logs();
      final desala = registros.where((l) => l['nome_tabela'] == 'sala');
      expect(desala.map((l) => l['tipo_operacao']),
          containsAll(['INSERT', 'UPDATE', 'DELETE']));
    });

    test('registra operacoes de agendamento e preenche data_hora', () async {
      final salaId = await inserirSala('Sala A');
      await inserirAgendamento(
        salaId,
        DateTime(2030, 1, 1, 10),
        DateTime(2030, 1, 1, 11),
      );

      final registros = await logs();
      final deAg =
          registros.where((l) => l['nome_tabela'] == 'agendamento').toList();
      expect(deAg, hasLength(1));
      expect(deAg.first['tipo_operacao'], 'INSERT');
      expect(deAg.first['data_hora'], isNotNull);
      expect((deAg.first['data_hora'] as String), isNotEmpty);
    });
  });
}
