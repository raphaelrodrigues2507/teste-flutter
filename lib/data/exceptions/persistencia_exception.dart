class PersistenciaException implements Exception {
  final String mensagem;

  const PersistenciaException(this.mensagem);

  @override
  String toString() => mensagem;
}

PersistenciaException mapearErroBanco(Object erro) {
  final msg = erro.toString().toLowerCase();

  if (msg.contains('horario para esta sala')) {
    return const PersistenciaException(
        'Já existe um agendamento nesse horário para esta sala.');
  }
  if (msg.contains('sala com agendamento futuro')) {
    return const PersistenciaException(
        'Não é possível excluir uma sala com agendamento futuro.');
  }
  if (msg.contains('unique constraint failed') && msg.contains('sala')) {
    return const PersistenciaException('Já existe uma sala com esse nome.');
  }
  if (msg.contains('data_fim > data_inicio')) {
    return const PersistenciaException(
        'A data/hora final deve ser maior que a data/hora inicial.');
  }
  if (msg.contains('not null constraint failed') ||
      msg.contains('length(trim')) {
    return const PersistenciaException(
        'Preencha todos os campos obrigatórios.');
  }
  if (msg.contains('foreign key constraint failed')) {
    return const PersistenciaException('Selecione uma sala válida.');
  }
  if (msg.contains('check constraint failed')) {
    return const PersistenciaException('Dados inválidos. Verifique os campos.');
  }
  return const PersistenciaException('Não foi possível concluir a operação.');
}
