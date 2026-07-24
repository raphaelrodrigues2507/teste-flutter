import '../database/database_provider.dart';
import '../models/log_operacao.dart';

class LogRepository {
  final DatabaseProvider _provider;

  LogRepository(this._provider);

  Future<List<LogOperacao>> listar() async {
    final db = await _provider.database;
    final linhas = await db.query(
      'log_operacao',
      orderBy: 'data_hora DESC, id DESC',
    );
    return linhas.map(LogOperacao.fromMap).toList();
  }
}
