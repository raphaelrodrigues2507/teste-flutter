import 'package:sqflite/sqflite.dart';

import '../database/database_provider.dart';
import '../exceptions/persistencia_exception.dart';
import '../models/sala.dart';

class SalaRepository {
  final DatabaseProvider _provider;

  SalaRepository(this._provider);

  Future<int> inserir(Sala sala) => _guardar(() async {
        final db = await _provider.database;
        return db.insert('sala', sala.toMap());
      });

  Future<void> atualizar(Sala sala) => _guardar(() async {
        final db = await _provider.database;
        await db.update('sala', sala.toMap(),
            where: 'id = ?', whereArgs: [sala.id]);
      });

  Future<void> excluir(int id) => _guardar(() async {
        final db = await _provider.database;
        await db.delete('sala', where: 'id = ?', whereArgs: [id]);
      });

  Future<List<Sala>> listar() async {
    final db = await _provider.database;
    final linhas = await db.query('sala', orderBy: 'nome COLLATE NOCASE');
    return linhas.map(Sala.fromMap).toList();
  }

  Future<T> _guardar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on DatabaseException catch (e) {
      throw mapearErroBanco(e);
    }
  }
}
