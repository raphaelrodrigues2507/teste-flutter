import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/exceptions/persistencia_exception.dart';
import '../../data/models/agendamento.dart';
import '../../data/models/sala.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../../data/repositories/sala_repository.dart';
import '../shared/formatters.dart';

class AgendamentoFormPage extends StatefulWidget {
  final SalaRepository? salaRepository;
  final AgendamentoRepository? agendamentoRepository;

  const AgendamentoFormPage({
    super.key,
    this.salaRepository,
    this.agendamentoRepository,
  });

  @override
  State<AgendamentoFormPage> createState() => _AgendamentoFormPageState();
}

class _AgendamentoFormPageState extends State<AgendamentoFormPage> {
  late final SalaRepository _salaRepo =
      widget.salaRepository ?? SalaRepository(AppDatabase.instance);
  late final AgendamentoRepository _repo =
      widget.agendamentoRepository ?? AgendamentoRepository(AppDatabase.instance);

  late Future<List<Sala>> _salasFuturo;
  int? _salaId;
  DateTime? _inicio;
  DateTime? _fim;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _salasFuturo = _salaRepo.listar();
  }

  bool get _podeSalvar =>
      _salaId != null && _inicio != null && _fim != null && !_salvando;

  Future<DateTime?> _escolherDataHora(DateTime? atual) async {
    final base = atual ?? DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data == null || !mounted) return null;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (hora == null) return null;

    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      await _repo.inserir(Agendamento(
        salaId: _salaId!,
        dataInicio: _inicio!,
        dataFim: _fim!,
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PersistenciaException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: FutureBuilder<List<Sala>>(
        future: _salasFuturo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final salas = snapshot.data ?? const [];
          if (salas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Cadastre uma sala antes de criar um agendamento.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _salaId,
                decoration: const InputDecoration(
                  labelText: 'Sala',
                  border: OutlineInputBorder(),
                ),
                items: salas
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nome),
                        ))
                    .toList(),
                onChanged: (valor) => setState(() => _salaId = valor),
              ),
              const SizedBox(height: 16),
              _CampoDataHora(
                rotulo: 'Início',
                valor: _inicio,
                onTap: () async {
                  final escolhido = await _escolherDataHora(_inicio);
                  if (escolhido != null) setState(() => _inicio = escolhido);
                },
              ),
              const SizedBox(height: 16),
              _CampoDataHora(
                rotulo: 'Fim',
                valor: _fim,
                onTap: () async {
                  final escolhido = await _escolherDataHora(_fim ?? _inicio);
                  if (escolhido != null) setState(() => _fim = escolhido);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _podeSalvar ? _salvar : null,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CampoDataHora extends StatelessWidget {
  final String rotulo;
  final DateTime? valor;
  final VoidCallback onTap;

  const _CampoDataHora({
    required this.rotulo,
    required this.valor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: rotulo,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          valor == null ? 'Selecionar data e hora' : formatoDataHora.format(valor!),
        ),
      ),
    );
  }
}
