import 'package:flutter/material.dart';

import '../agendamentos/agendamentos_page.dart';
import '../logs/logs_page.dart';
import '../salas/salas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento de Salas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            icone: Icons.meeting_room,
            titulo: 'Salas',
            subtitulo: 'Cadastrar e gerenciar salas',
            destino: () => const SalasPage(),
          ),
          _MenuCard(
            icone: Icons.event,
            titulo: 'Agendamentos',
            subtitulo: 'Reservar salas por período',
            destino: () => const AgendamentosPage(),
          ),
          _MenuCard(
            icone: Icons.history,
            titulo: 'Log de operações',
            subtitulo: 'Auditoria de alterações no banco',
            destino: () => const LogsPage(),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final Widget Function() destino;

  const _MenuCard({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone, size: 32),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destino()),
        ),
      ),
    );
  }
}
