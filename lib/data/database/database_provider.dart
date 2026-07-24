import 'package:sqflite_common/sqlite_api.dart';

abstract class DatabaseProvider {
  Future<Database> get database;
}
