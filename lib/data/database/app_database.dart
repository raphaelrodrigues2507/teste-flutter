import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_provider.dart';
import 'sql_script.dart';

class AppDatabase implements DatabaseProvider {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _nomeArquivo = 'coworking.db';
  static const String _caminhoSchema = 'assets/sql/schema.sql';
  static const int _versao = 1;

  Database? _db;

  @override
  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final diretorio = await databaseFactory.getDatabasesPath();
    final caminho = p.join(diretorio, _nomeArquivo);
    final schema = await rootBundle.loadString(_caminhoSchema);

    return databaseFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: _versao,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => aplicarSchema(db, schema),
      ),
    );
  }

  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
