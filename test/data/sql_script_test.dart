import 'package:flutter_test/flutter_test.dart';
import 'package:teste_flutter/data/database/sql_script.dart';

void main() {
  group('splitSqlStatements', () {
    test('separa comandos simples ignorando ; final', () {
      final comandos = splitSqlStatements('CREATE TABLE a (id INTEGER); '
          'CREATE TABLE b (id INTEGER);');
      expect(comandos, hasLength(2));
      expect(comandos[0], startsWith('CREATE TABLE a'));
      expect(comandos[1], startsWith('CREATE TABLE b'));
    });

    test('mantem o corpo de um trigger (BEGIN...END) como um unico comando', () {
      const sql = '''
CREATE TRIGGER t AFTER INSERT ON a
BEGIN
  INSERT INTO log VALUES ('x');
  INSERT INTO log VALUES ('y');
END;
CREATE TABLE b (id INTEGER);
''';
      final comandos = splitSqlStatements(sql);
      expect(comandos, hasLength(2));
      expect(comandos[0], contains('END'));
      expect(comandos[0], contains("INSERT INTO log VALUES ('y')"));
      expect(comandos[1], startsWith('CREATE TABLE b'));
    });

    test('remove comentarios de linha', () {
      const sql = 'CREATE TABLE a (id INTEGER); -- comentario\n'
          'CREATE TABLE b (id INTEGER);';
      final comandos = splitSqlStatements(sql);
      expect(comandos, hasLength(2));
      expect(comandos.join(), isNot(contains('comentario')));
    });

    test('nao confunde a palavra END dentro de um identificador', () {
      const sql = 'CREATE TABLE agendamento (id INTEGER);';
      final comandos = splitSqlStatements(sql);
      expect(comandos, hasLength(1));
    });
  });
}
