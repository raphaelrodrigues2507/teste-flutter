import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/exceptions/persistencia_exception.dart';
import '../../data/models/sala.dart';
import '../../data/repositories/sala_repository.dart';

class SalasPage extends StatefulWidget {
  final SalaRepository? repository;

  const SalasPage({super.key, this.repository});

  @override
  State<SalasPage> createState() => _SalasPageState();
}

class _SalasPageState extends State<SalasPage> {
  late final SalaRepository _repo =
      widget.repository ?? SalaRepository(AppDatabase.instance);
  late Future<List<Sala>> _futuro;

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

  Future<void> _abrirFormulario({Sala? sala}) async {
    final nome = await showDialog<String>(
      context: context,
      builder: (_) => _SalaDialog(nomeInicial: sala?.nome),
    );
    if (nome == null) return;

    try {
      if (sala == null) {
        await _repo.inserir(Sala(nome: nome));
      } else {
        await _repo.atualizar(sala.copyWith(nome: nome));
      }
      _recarregar();
    } on PersistenciaException catch (e) {
      _mostrarMensagem(e.mensagem);
    }
  }

  Future<void> _excluir(Sala sala) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir sala'),
        content: Text('Deseja excluir a sala "${sala.nome}"?'),
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
      await _repo.excluir(sala.id!);
      _recarregar();
    } on PersistenciaException catch (e) {
      _mostrarMensagem(e.mensagem);
    }
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova sala'),
      ),
      body: FutureBuilder<List<Sala>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          final salas = snapshot.data ?? const [];
          if (salas.isEmpty) {
            return const Center(child: Text('Nenhuma sala cadastrada.'));
          }
          return ListView.separated(
            itemCount: salas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sala = salas[index];
              return ListTile(
                leading: const Icon(Icons.meeting_room),
                title: Text(sala.nome),
                onTap: () => _abrirFormulario(sala: sala),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _excluir(sala),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SalaDialog extends StatefulWidget {
  final String? nomeInicial;

  const _SalaDialog({this.nomeInicial});

  @override
  State<_SalaDialog> createState() => _SalaDialogState();
}

class _SalaDialogState extends State<_SalaDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.nomeInicial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.nomeInicial != null;
    return AlertDialog(
      title: Text(editando ? 'Editar sala' : 'Nova sala'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome da sala'),
        onSubmitted: (_) => _confirmar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _confirmar() => Navigator.of(context).pop(_controller.text.trim());
}
