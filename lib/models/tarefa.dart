// lib/models/tarefa.dart

enum Prioridade { baixa, media, alta }

class Tarefa {
  final String? id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final Prioridade prioridade;
  final DateTime criadaEm;
  final DateTime? concluidaEm;
  final String categoria;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    this.prioridade = Prioridade.media,
    required this.criadaEm,
    this.concluidaEm,
    this.categoria = 'Geral',
  });

  // Converte objeto para Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
      'prioridade': prioridade.index,
      'criada_em': criadaEm.toIso8601String(),
      'concluida_em': concluidaEm?.toIso8601String(),
      'categoria': categoria,
    };
  }

  // Converte Map para objeto Tarefa (leitura do SQLite)
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] == 1,
      prioridade: Prioridade.values[map['prioridade'] ?? 1],
      criadaEm: DateTime.parse(map['criada_em']),
      concluidaEm: map['concluida_em'] != null
          ? DateTime.parse(map['concluida_em'])
          : null,
      categoria: map['categoria'] ?? 'Geral',
    );
  }

  // Cria cópia com campos alterados (imutabilidade)
  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    Prioridade? prioridade,
    DateTime? criadaEm,
    DateTime? concluidaEm,
    String? categoria,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      prioridade: prioridade ?? this.prioridade,
      criadaEm: criadaEm ?? this.criadaEm,
      concluidaEm: concluidaEm ?? this.concluidaEm,
      categoria: categoria ?? this.categoria,
    );
  }
}
