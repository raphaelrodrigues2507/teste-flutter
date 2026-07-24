PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS sala (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE CHECK (length(trim(nome)) > 0)
);

CREATE TABLE IF NOT EXISTS agendamento (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    sala_id     INTEGER NOT NULL,
    data_inicio TEXT NOT NULL CHECK (length(trim(data_inicio)) > 0),
    data_fim    TEXT NOT NULL CHECK (length(trim(data_fim)) > 0),
    CHECK (data_fim > data_inicio),
    FOREIGN KEY (sala_id) REFERENCES sala (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS log_operacao (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_tabela   TEXT NOT NULL,
    tipo_operacao TEXT NOT NULL CHECK (tipo_operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    data_hora     TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE TRIGGER IF NOT EXISTS trg_agendamento_sobreposicao_insert
BEFORE INSERT ON agendamento
FOR EACH ROW
WHEN EXISTS (
    SELECT 1 FROM agendamento a
    WHERE a.sala_id = NEW.sala_id
      AND NEW.data_inicio < a.data_fim
      AND NEW.data_fim > a.data_inicio
)
BEGIN
    SELECT RAISE(ABORT, 'Ja existe um agendamento nesse horario para esta sala.');
END;

CREATE TRIGGER IF NOT EXISTS trg_agendamento_sobreposicao_update
BEFORE UPDATE ON agendamento
FOR EACH ROW
WHEN EXISTS (
    SELECT 1 FROM agendamento a
    WHERE a.sala_id = NEW.sala_id
      AND a.id <> NEW.id
      AND NEW.data_inicio < a.data_fim
      AND NEW.data_fim > a.data_inicio
)
BEGIN
    SELECT RAISE(ABORT, 'Ja existe um agendamento nesse horario para esta sala.');
END;

CREATE TRIGGER IF NOT EXISTS trg_sala_bloqueia_exclusao_futuro
BEFORE DELETE ON sala
FOR EACH ROW
WHEN EXISTS (
    SELECT 1 FROM agendamento a
    WHERE a.sala_id = OLD.id
      AND a.data_fim > datetime('now', 'localtime')
)
BEGIN
    SELECT RAISE(ABORT, 'Ja existe agendamento futuro: sala com agendamento futuro nao pode ser excluida.');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_sala_insert
AFTER INSERT ON sala
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('sala', 'INSERT');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_sala_update
AFTER UPDATE ON sala
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('sala', 'UPDATE');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_sala_delete
AFTER DELETE ON sala
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('sala', 'DELETE');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_agendamento_insert
AFTER INSERT ON agendamento
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('agendamento', 'INSERT');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_agendamento_update
AFTER UPDATE ON agendamento
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('agendamento', 'UPDATE');
END;

CREATE TRIGGER IF NOT EXISTS trg_log_agendamento_delete
AFTER DELETE ON agendamento
FOR EACH ROW
BEGIN
    INSERT INTO log_operacao (nome_tabela, tipo_operacao) VALUES ('agendamento', 'DELETE');
END;
