import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/models/log_operacao.dart';
import '../../data/repositories/log_repository.dart';
import '../shared/formatters.dart';

class LogsPage extends StatefulWidget {
  final LogRepository? repository;

  const LogsPage({super.key, this.repository});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late final LogRepository _repo =
      widget.repository ?? LogRepository(AppDatabase.instance);
  late Future<List<LogOperacao>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _repo.listar();
  }

  IconData _icone(String tipo) {
    switch (tipo) {
      case 'INSERT':
        return Icons.add_circle_outline;
      case 'UPDATE':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log de operações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => setState(() {
              _futuro = _repo.listar();
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<LogOperacao>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? const [];
          if (logs.isEmpty) {
            return const Center(child: Text('Nenhuma operação registrada.'));
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(_icone(log.tipoOperacao)),
                title: Text('${log.tipoOperacao} em ${log.nomeTabela}'),
                subtitle: Text(formatoDataHora.format(log.dataHora)),
              );
            },
          );
        },
      ),
    );
  }
}
