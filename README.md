# Agendamento de Salas Coworking

Aplicativo em Flutter para cadastro de salas e agendamentos, usando SQLite.
As regras de negócio são validadas no próprio banco de dados, por meio de
constraints e triggers.

## Requisitos

- Flutter 3.44 ou superior
- Windows, Android, Linux ou macOS

## Como rodar

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter test
```

## Banco de dados

O script de criação fica em `assets/sql/schema.sql` e é aplicado na primeira
execução do aplicativo.

Tabelas:

- `sala` — id, nome
- `agendamento` — id, sala_id, data_inicio, data_fim
- `log_operacao` — id, nome_tabela, tipo_operacao, data_hora

Validações feitas no banco:

- campos obrigatórios e nome de sala único
- data/hora final maior que a inicial
- sem sobreposição de agendamentos na mesma sala
- exclusão de sala bloqueada quando há agendamento futuro
- toda operação de INSERT, UPDATE e DELETE em `sala` e `agendamento` é
  registrada em `log_operacao`

## Estrutura

- `lib/data` — acesso ao banco, models e repositories
- `lib/ui` — telas de salas, agendamentos e log de operações
- `test` — testes das regras do banco e das telas
