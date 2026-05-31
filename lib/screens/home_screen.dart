// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'formulario_tarefa_screen.dart';
import 'estatisticas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  late TabController _tabController;

  List<Tarefa> _tarefas = [];
  List<Tarefa> _tarefasFiltradas = [];
  bool _carregando = true;
  String _pesquisa = '';
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _carregarTarefas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _carregando = true);
    final tarefas = await _db.buscarTodasTarefas();
    setState(() {
      _tarefas = tarefas;
      _aplicarFiltro();
      _carregando = false;
    });
  }

  void _aplicarFiltro() {
    if (_pesquisa.isEmpty) {
      _tarefasFiltradas = List.from(_tarefas);
    } else {
      _tarefasFiltradas = _tarefas
          .where((t) =>
              t.titulo.toLowerCase().contains(_pesquisa.toLowerCase()) ||
              t.descricao.toLowerCase().contains(_pesquisa.toLowerCase()))
          .toList();
    }
  }

  List<Tarefa> get _pendentes =>
      _tarefasFiltradas.where((t) => !t.concluida).toList();
  List<Tarefa> get _concluidas =>
      _tarefasFiltradas.where((t) => t.concluida).toList();

  Future<void> _alternarConclusao(Tarefa tarefa) async {
    await _db.alternarConclusao(tarefa.id!, !tarefa.concluida);
    await _carregarTarefas();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tarefa.concluida ? 'Tarefa reaberta!' : 'Tarefa concluída! ✓',
        ),
        backgroundColor:
            tarefa.concluida ? Colors.orange : const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deletarTarefa(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir tarefa?',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          '"${tarefa.titulo}" será removida permanentemente.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _db.deletarTarefa(tarefa.id!);
      await _carregarTarefas();
    }
  }

  Future<void> _abrirFormulario({Tarefa? tarefa}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioTarefaScreen(tarefaExistente: tarefa),
      ),
    );
    if (resultado == true) await _carregarTarefas();
  }

  Color _corPrioridade(Prioridade p) {
    switch (p) {
      case Prioridade.alta:
        return const Color(0xFFFF5252);
      case Prioridade.media:
        return const Color(0xFFFFB74D);
      case Prioridade.baixa:
        return const Color(0xFF66BB6A);
    }
  }

  String _labelPrioridade(Prioridade p) {
    switch (p) {
      case Prioridade.alta:
        return 'Alta';
      case Prioridade.media:
        return 'Média';
      case Prioridade.baixa:
        return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPesquisa(),
            _buildTabBar(),
            Expanded(child: _buildConteudo()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF7C4DFF),
        icon: const Icon(Icons.add),
        label: Text('Nova Tarefa', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() {
    final stats = {
      'pendentes': _pendentes.length,
      'concluidas': _concluidas.length,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Tarefas',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${stats['pendentes']} pendentes · ${stats['concluidas']} concluídas',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstatisticasScreen()),
            ),
            icon: const Icon(Icons.bar_chart_rounded),
            color: const Color(0xFF7C4DFF),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: _pesquisaController,
        onChanged: (v) => setState(() {
          _pesquisa = v;
          _aplicarFiltro();
        }),
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Pesquisar tarefas...',
          hintStyle: GoogleFonts.inter(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          suffixIcon: _pesquisa.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38),
                  onPressed: () => setState(() {
                    _pesquisa = '';
                    _pesquisaController.clear();
                    _aplicarFiltro();
                  }),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF7C4DFF),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Pendentes (${_pendentes.length})'),
            Tab(text: 'Concluídas (${_concluidas.length})'),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildLista(_pendentes, vazio: 'Nenhuma tarefa pendente!\nAdicione uma nova tarefa.'),
        _buildLista(_concluidas, vazio: 'Nenhuma tarefa concluída ainda.'),
      ],
    );
  }

  Widget _buildLista(List<Tarefa> tarefas, {required String vazio}) {
    if (tarefas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.white12,
            ),
            const SizedBox(height: 16),
            Text(
              vazio,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarTarefas,
      color: const Color(0xFF7C4DFF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: tarefas.length,
        itemBuilder: (ctx, i) => _buildCardTarefa(tarefas[i]),
      ),
    );
  }

  Widget _buildCardTarefa(Tarefa tarefa) {
    final corPrioridade = _corPrioridade(tarefa.prioridade);
    return Dismissible(
      key: Key(tarefa.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _deletarTarefa(tarefa);
        return false;
      },
      child: GestureDetector(
        onTap: () => _abrirFormulario(tarefa: tarefa),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: corPrioridade, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _alternarConclusao(tarefa),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: tarefa.concluida
                          ? const Color(0xFF7C4DFF)
                          : Colors.transparent,
                      border: Border.all(
                        color: tarefa.concluida
                            ? const Color(0xFF7C4DFF)
                            : Colors.white38,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: tarefa.concluida
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarefa.titulo,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: tarefa.concluida ? Colors.white38 : Colors.white,
                          decoration: tarefa.concluida
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (tarefa.descricao.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tarefa.descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _chip(
                            tarefa.categoria,
                            const Color(0xFF2A2A3E),
                            Colors.white60,
                          ),
                          const SizedBox(width: 6),
                          _chip(
                            _labelPrioridade(tarefa.prioridade),
                            corPrioridade.withOpacity(0.15),
                            corPrioridade,
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd/MM').format(tarefa.criadaEm),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 11, color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }
}
