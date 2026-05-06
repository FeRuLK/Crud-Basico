class Tarefa {
  int? id;
  String titulo;
  String descricao;
  DateTime dataPrevista;
  bool importante;
  bool realizada;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataPrevista,
    this.importante = false,
    this.realizada = false,
  });

  /// Converte o objeto para um Map para ser salvo no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'dataPrevista': dataPrevista.toIso8601String(),
      'importante': importante ? 1 : 0,
      'realizada': realizada ? 1 : 0,
    };
  }

  /// Cria um objeto Tarefa a partir de um Map vindo do SQLite.
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      dataPrevista: DateTime.parse(map['dataPrevista'] as String),
      importante: (map['importante'] as int) == 1,
      realizada: (map['realizada'] as int) == 1,
    );
  }

  /// Cria uma cópia do objeto com campos alterados.
  Tarefa copyWith({
    int? id,
    String? titulo,
    String? descricao,
    DateTime? dataPrevista,
    bool? importante,
    bool? realizada,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataPrevista: dataPrevista ?? this.dataPrevista,
      importante: importante ?? this.importante,
      realizada: realizada ?? this.realizada,
    );
  }
}
