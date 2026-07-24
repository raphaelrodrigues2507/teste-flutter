import 'package:intl/intl.dart';

class LogOperacao {
  static final DateFormat formatoBanco = DateFormat('yyyy-MM-dd HH:mm:ss');

  final int? id;
  final String nomeTabela;
  final String tipoOperacao;
  final DateTime dataHora;

  const LogOperacao({
    this.id,
    required this.nomeTabela,
    required this.tipoOperacao,
    required this.dataHora,
  });

  factory LogOperacao.fromMap(Map<String, Object?> map) => LogOperacao(
        id: map['id'] as int?,
        nomeTabela: map['nome_tabela'] as String,
        tipoOperacao: map['tipo_operacao'] as String,
        dataHora: formatoBanco.parse(map['data_hora'] as String),
      );
}
