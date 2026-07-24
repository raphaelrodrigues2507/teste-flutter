import 'package:intl/intl.dart';

class Agendamento {
  static final DateFormat formatoBanco = DateFormat('yyyy-MM-dd HH:mm:ss');

  final int? id;
  final int salaId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? salaNome;

  const Agendamento({
    this.id,
    required this.salaId,
    required this.dataInicio,
    required this.dataFim,
    this.salaNome,
  });

  factory Agendamento.fromMap(Map<String, Object?> map) => Agendamento(
        id: map['id'] as int?,
        salaId: map['sala_id'] as int,
        dataInicio: formatoBanco.parse(map['data_inicio'] as String),
        dataFim: formatoBanco.parse(map['data_fim'] as String),
        salaNome: map['sala_nome'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'sala_id': salaId,
        'data_inicio': formatoBanco.format(dataInicio),
        'data_fim': formatoBanco.format(dataFim),
      };

  Agendamento copyWith({
    int? id,
    int? salaId,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? salaNome,
  }) =>
      Agendamento(
        id: id ?? this.id,
        salaId: salaId ?? this.salaId,
        dataInicio: dataInicio ?? this.dataInicio,
        dataFim: dataFim ?? this.dataFim,
        salaNome: salaNome ?? this.salaNome,
      );
}
