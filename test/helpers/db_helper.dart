import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teste_flutter/data/database/database_provider.dart';
import 'package:teste_flutter/data/database/sql_script.dart';

void inicializarSqfliteFfi() => sqfliteFfiInit();

Future<Database> abrirBancoEmMemoria({DatabaseFactory? factory}) async {
  final schema = await File('assets/sql/schema.sql').readAsString();
  return (factory ?? databaseFactoryFfi).openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => aplicarSchema(db, schema),
    ),
  );
}

class InMemoryDatabaseProvider implements DatabaseProvider {
  final Database _db;

  InMemoryDatabaseProvider(this._db);

  @override
  Future<Database> get database async => _db;
}

String fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}:'
    '${d.second.toString().padLeft(2, '0')}';
