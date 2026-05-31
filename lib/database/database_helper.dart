// lib/database/database_helper.dart
// Camada de acesso ao banco de dados SQLite local
// Utiliza o padrão Singleton para garantir uma única instância

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';

class DatabaseHelper {
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static Database? _database;

  // Construtor privado (Singleton)
  DatabaseHelper._interno();

  factory DatabaseHelper() => _instancia;

  // Getter lazy para o banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _inicializarDB();
    return _database!;
  }

  // Inicializa e cria o banco de dados
  Future<Database> _inicializarDB() async {
    final caminho = await getDatabasesPath();
    final caminhoCompleto = join(caminho, 'tarefas.db');

    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: _criarTabelas,
    );
  }

  // DDL - Criação das tabelas
  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descricao TEXT,
        concluida INTEGER NOT NULL DEFAULT 0,
        prioridade INTEGER NOT NULL DEFAULT 1,
        criada_em TEXT NOT NULL,
        concluida_em TEXT,
        categoria TEXT DEFAULT 'Geral'
      )
    ''');

    // Índice para melhorar performance de busca
    await db.execute(
      'CREATE INDEX idx_categoria ON tarefas(categoria)',
    );

    await db.execute(
      'CREATE INDEX idx_concluida ON tarefas(concluida)',
    );
  }

  // ============================================================
  // OPERAÇÕES CRUD
  // ============================================================

  /// CREATE - Insere uma nova tarefa no banco
  Future<String> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    await db.insert(
      'tarefas',
      tarefa.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return tarefa.id!;
  }

  /// READ - Busca todas as tarefas
  Future<List<Tarefa>> buscarTodasTarefas() async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'tarefas',
      orderBy: 'criada_em DESC',
    );
    return mapas.map((mapa) => Tarefa.fromMap(mapa)).toList();
  }

  /// READ - Busca tarefas por status (pendentes ou concluídas)
  Future<List<Tarefa>> buscarPorStatus({required bool concluida}) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'tarefas',
      where: 'concluida = ?',
      whereArgs: [concluida ? 1 : 0],
      orderBy: 'prioridade DESC, criada_em DESC',
    );
    return mapas.map((mapa) => Tarefa.fromMap(mapa)).toList();
  }

  /// READ - Busca tarefas por categoria
  Future<List<Tarefa>> buscarPorCategoria(String categoria) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'tarefas',
      where: 'categoria = ?',
      whereArgs: [categoria],
      orderBy: 'criada_em DESC',
    );
    return mapas.map((mapa) => Tarefa.fromMap(mapa)).toList();
  }

  /// READ - Busca tarefas por termo de pesquisa
  Future<List<Tarefa>> pesquisar(String termo) async {
    final db = await database;
    final List<Map<String, dynamic>> mapas = await db.query(
      'tarefas',
      where: 'titulo LIKE ? OR descricao LIKE ?',
      whereArgs: ['%$termo%', '%$termo%'],
      orderBy: 'criada_em DESC',
    );
    return mapas.map((mapa) => Tarefa.fromMap(mapa)).toList();
  }

  /// UPDATE - Atualiza uma tarefa existente
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  /// UPDATE - Marca tarefa como concluída ou pendente
  Future<int> alternarConclusao(String id, bool concluida) async {
    final db = await database;
    return await db.update(
      'tarefas',
      {
        'concluida': concluida ? 1 : 0,
        'concluida_em': concluida ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE - Remove uma tarefa pelo ID
  Future<int> deletarTarefa(String id) async {
    final db = await database;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE - Remove todas as tarefas concluídas
  Future<int> limparConcluidas() async {
    final db = await database;
    return await db.delete(
      'tarefas',
      where: 'concluida = 1',
    );
  }

  // ============================================================
  // ESTATÍSTICAS
  // ============================================================

  Future<Map<String, int>> obterEstatisticas() async {
    final db = await database;

    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tarefas'),
    )!;

    final concluidas = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tarefas WHERE concluida = 1'),
    )!;

    final alta = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM tarefas WHERE prioridade = 2 AND concluida = 0',
      ),
    )!;

    return {
      'total': total,
      'concluidas': concluidas,
      'pendentes': total - concluidas,
      'alta_prioridade': alta,
    };
  }

  Future<List<String>> obterCategorias() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT categoria FROM tarefas ORDER BY categoria',
    );
    return result.map((r) => r['categoria'] as String).toList();
  }

  // Fecha o banco de dados
  Future<void> fechar() async {
    final db = await database;
    db.close();
  }
}
