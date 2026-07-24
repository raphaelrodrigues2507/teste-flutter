import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/exceptions/persistencia_exception.dart';
import '../../data/models/agendamento.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../shared/formatters.dart';
import 'agendamento_form_page.dart';

class AgendamentosPage extends StatefulWidget {
  final AgendamentoRepository? repository;

  const AgendamentosPage({super.key, this.repository});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  late final AgendamentoRepository _repo =
      widget.repository ?? AgendamentoRepository(AppDatabase.instance);
  late Future<List<Agendamento>> _futuro;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    setState(() {
      _futuro = _repo.listar();
    });
  }

  Future<void> _abrirFormulario() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AgendamentoFormPage()),
    );
    if (salvou == true) _recarregar();
  }

  Future<void> _excluir(Agendamento agendamento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir agendamento'),
        content: const Text('Deseja excluir este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await _repo.excluir(agendamento.id!);
      _recarregar();
    } on PersistenciaException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo agendamento'),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          final agendamentos = snapshot.data ?? const [];
          if (agendamentos.isEmpty) {
            return const Center(child: Text('Nenhum agendamento cadastrado.'));
          }
          return ListView.separated(
            itemCount: agendamentos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ag = agendamentos[index];
              return ListTile(
                leading: const Icon(Icons.event),
                title: Text(ag.salaNome ?? 'Sala ${ag.salaId}'),
                subtitle: Text(
                  '${formatoDataHora.format(ag.dataInicio)}  ➜  '
                  '${formatoDataHora.format(ag.dataFim)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _excluir(ag),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
