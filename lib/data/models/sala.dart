class Sala {
  final int? id;
  final String nome;

  const Sala({this.id, required this.nome});

  factory Sala.fromMap(Map<String, Object?> map) => Sala(
        id: map['id'] as int?,
        nome: map['nome'] as String,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'nome': nome,
      };

  Sala copyWith({int? id, String? nome}) =>
      Sala(id: id ?? this.id, nome: nome ?? this.nome);
}
