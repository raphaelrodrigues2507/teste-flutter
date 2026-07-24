import 'package:sqflite_common/sqlite_api.dart';

List<String> splitSqlStatements(String sql) {
  final statements = <String>[];
  final current = StringBuffer();
  var inString = false;
  var beginDepth = 0;
  final length = sql.length;
  var i = 0;

  bool isWordChar(int code) =>
      (code >= 48 && code <= 57) ||
      (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      code == 95;

  bool matchesKeyword(String keyword) {
    if (i + keyword.length > length) return false;
    if (sql.substring(i, i + keyword.length).toUpperCase() != keyword) {
      return false;
    }
    final before = i > 0 ? sql.codeUnitAt(i - 1) : -1;
    final afterIndex = i + keyword.length;
    final after = afterIndex < length ? sql.codeUnitAt(afterIndex) : -1;
    if (before != -1 && isWordChar(before)) return false;
    if (after != -1 && isWordChar(after)) return false;
    return true;
  }

  while (i < length) {
    final ch = sql[i];

    if (inString) {
      current.write(ch);
      if (ch == "'") {
        if (i + 1 < length && sql[i + 1] == "'") {
          current.write("'");
          i += 2;
          continue;
        }
        inString = false;
      }
      i++;
      continue;
    }

    if (ch == '-' && i + 1 < length && sql[i + 1] == '-') {
      while (i < length && sql[i] != '\n') {
        i++;
      }
      continue;
    }

    if (ch == "'") {
      inString = true;
      current.write(ch);
      i++;
      continue;
    }

    if (matchesKeyword('BEGIN')) {
      beginDepth++;
      current.write(sql.substring(i, i + 5));
      i += 5;
      continue;
    }

    if (matchesKeyword('END')) {
      if (beginDepth > 0) beginDepth--;
      current.write(sql.substring(i, i + 3));
      i += 3;
      continue;
    }

    if (ch == ';' && beginDepth == 0) {
      final statement = current.toString().trim();
      if (statement.isNotEmpty) statements.add(statement);
      current.clear();
      i++;
      continue;
    }

    current.write(ch);
    i++;
  }

  final tail = current.toString().trim();
  if (tail.isNotEmpty) statements.add(tail);
  return statements;
}

Future<void> aplicarSchema(DatabaseExecutor db, String schemaSql) async {
  for (final statement in splitSqlStatements(schemaSql)) {
    await db.execute(statement);
  }
}
