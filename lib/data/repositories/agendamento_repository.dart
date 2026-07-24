import 'package:sqflite/sqflite.dart';

import '../database/database_provider.dart';
import '../exceptions/persistencia_exception.dart';
import '../models/agendamento.dart';

class AgendamentoRepository {
  final DatabaseProvider _provider;

  AgendamentoRepository(this._provider);

  Future<int> inserir(Agendamento agendamento) => _guardar(() async {
        final db = await _provider.database;
        return db.insert('agendamento', agendamento.toMap());
      });

  Future<void> atualizar(Agendamento agendamento) => _guardar(() async {
        final db = await _provider.database;
        await db.update('agendamento', agendamento.toMap(),
            where: 'id = ?', whereArgs: [agendamento.id]);
      });

  Future<void> excluir(int id) => _guardar(() async {
        final db = await _provider.database;
        await db.delete('agendamento', where: 'id = ?', whereArgs: [id]);
      });

  Future<List<Agendamento>> listar() async {
    final db = await _provider.database;
    final linhas = await db.rawQuery('''
      SELECT a.*, s.nome AS sala_nome
      FROM agendamento a
      JOIN sala s ON s.id = a.sala_id
      ORDER BY a.data_inicio
    ''');
    return linhas.map(Agendamento.fromMap).toList();
  }

  Future<T> _guardar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on DatabaseException catch (e) {
      throw mapearErroBanco(e);
    }
  }
}
