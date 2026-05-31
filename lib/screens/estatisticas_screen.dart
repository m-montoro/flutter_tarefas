// lib/screens/estatisticas_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  Map<String, int> _stats = {};
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final stats = await _db.obterEstatisticas();
    final tarefas = await _db.buscarTodasTarefas();
    setState(() {
      _stats = stats;
      _tarefas = tarefas;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Estatísticas',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumo(),
                  const SizedBox(height: 24),
                  _buildProgresso(),
                  const SizedBox(height: 24),
                  _buildPorPrioridade(),
                  const SizedBox(height: 24),
                  _buildPorCategoria(),
                ],
              ),
            ),
    );
  }

  Widget _buildResumo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visão Geral',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _cardEstat(
                'Total',
                '${_stats['total'] ?? 0}',
                Icons.list_alt_rounded,
                const Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cardEstat(
                'Pendentes',
                '${_stats['pendentes'] ?? 0}',
                Icons.hourglass_empty_rounded,
                const Color(0xFFFFB74D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _cardEstat(
                'Concluídas',
                '${_stats['concluidas'] ?? 0}',
                Icons.check_circle_outline_rounded,
                const Color(0xFF66BB6A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cardEstat(
                'Alta Prioridade',
                '${_stats['alta_prioridade'] ?? 0}',
                Icons.priority_high_rounded,
                const Color(0xFFFF5252),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardEstat(String label, String valor, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgresso() {
    final total = _stats['total'] ?? 0;
    final concluidas = _stats['concluidas'] ?? 0;
    final progresso = total > 0 ? concluidas / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso Geral',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progresso * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7C4DFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C4DFF)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$concluidas de $total tarefas concluídas',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPorPrioridade() {
    final pendentes = _tarefas.where((t) => !t.concluida).toList();
    final alta = pendentes.where((t) => t.prioridade == Prioridade.alta).length;
    final media = pendentes.where((t) => t.prioridade == Prioridade.media).length;
    final baixa = pendentes.where((t) => t.prioridade == Prioridade.baixa).length;
    final total = pendentes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendentes por Prioridade',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _barraCategoria('Alta', alta, total, const Color(0xFFFF5252)),
        const SizedBox(height: 8),
        _barraCategoria('Média', media, total, const Color(0xFFFFB74D)),
        const SizedBox(height: 8),
        _barraCategoria('Baixa', baixa, total, const Color(0xFF66BB6A)),
      ],
    );
  }

  Widget _buildPorCategoria() {
    final categorias = <String, int>{};
    for (final t in _tarefas.where((t) => !t.concluida)) {
      categorias[t.categoria] = (categorias[t.categoria] ?? 0) + 1;
    }
    final total = categorias.values.fold(0, (a, b) => a + b);

    if (categorias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendentes por Categoria',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...categorias.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _barraCategoria(e.key, e.value, total, const Color(0xFF7C4DFF)),
          ),
        ),
      ],
    );
  }

  Widget _barraCategoria(String label, int valor, int total, Color cor) {
    final proporcao = total > 0 ? valor / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '$valor',
                style: GoogleFonts.inter(
                  color: cor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: proporcao,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(cor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
