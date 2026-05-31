// lib/screens/formulario_tarefa_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class FormularioTarefaScreen extends StatefulWidget {
  final Tarefa? tarefaExistente;

  const FormularioTarefaScreen({super.key, this.tarefaExistente});

  @override
  State<FormularioTarefaScreen> createState() => _FormularioTarefaScreenState();
}

class _FormularioTarefaScreenState extends State<FormularioTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();
  final _uuid = const Uuid();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descricaoCtrl;
  late TextEditingController _categoriaCtrl;

  Prioridade _prioridade = Prioridade.media;
  bool _salvando = false;

  bool get _editando => widget.tarefaExistente != null;

  final List<String> _categoriasSugeridas = [
    'Geral',
    'Trabalho',
    'Estudos',
    'Pessoal',
    'Saúde',
    'Compras',
    'Finanças',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.tarefaExistente;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: t?.descricao ?? '');
    _categoriaCtrl = TextEditingController(text: t?.categoria ?? 'Geral');
    _prioridade = t?.prioridade ?? Prioridade.media;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      if (_editando) {
        final atualizada = widget.tarefaExistente!.copyWith(
          titulo: _tituloCtrl.text.trim(),
          descricao: _descricaoCtrl.text.trim(),
          prioridade: _prioridade,
          categoria: _categoriaCtrl.text.trim(),
        );
        await _db.atualizarTarefa(atualizada);
      } else {
        final novaTarefa = Tarefa(
          id: _uuid.v4(),
          titulo: _tituloCtrl.text.trim(),
          descricao: _descricaoCtrl.text.trim(),
          prioridade: _prioridade,
          categoria: _categoriaCtrl.text.trim(),
          criadaEm: DateTime.now(),
        );
        await _db.inserirTarefa(novaTarefa);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _editando ? 'Editar Tarefa' : 'Nova Tarefa',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7C4DFF),
                    ),
                  )
                : Text(
                    'Salvar',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7C4DFF),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Título *'),
              const SizedBox(height: 8),
              _buildCampoTexto(
                controller: _tituloCtrl,
                hint: 'Ex: Estudar Flutter',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  if (v.trim().length < 3) {
                    return 'Título muito curto (mínimo 3 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Descrição'),
              const SizedBox(height: 8),
              _buildCampoTexto(
                controller: _descricaoCtrl,
                hint: 'Adicione detalhes sobre a tarefa...',
                maxLinhas: 4,
              ),
              const SizedBox(height: 20),
              _buildLabel('Prioridade'),
              const SizedBox(height: 8),
              _buildSeletorPrioridade(),
              const SizedBox(height: 20),
              _buildLabel('Categoria'),
              const SizedBox(height: 8),
              _buildCampoTexto(
                controller: _categoriaCtrl,
                hint: 'Ex: Trabalho, Estudos...',
              ),
              const SizedBox(height: 12),
              _buildCategoriasSugeridas(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Text(
      texto,
      style: GoogleFonts.inter(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String hint,
    int maxLinhas = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLinhas,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: GoogleFonts.inter(color: Colors.red.shade300),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSeletorPrioridade() {
    return Row(
      children: Prioridade.values.map((p) {
        final selecionada = _prioridade == p;
        final cor = _corPrioridade(p);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _prioridade = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selecionada ? cor.withOpacity(0.2) : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selecionada ? cor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _iconePrioridade(p),
                    color: selecionada ? cor : Colors.white38,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labelPrioridade(p),
                    style: GoogleFonts.inter(
                      color: selecionada ? cor : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriasSugeridas() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categoriasSugeridas.map((cat) {
        final selecionada = _categoriaCtrl.text == cat;
        return GestureDetector(
          onTap: () => setState(() => _categoriaCtrl.text = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selecionada
                  ? const Color(0xFF7C4DFF).withOpacity(0.2)
                  : const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selecionada
                    ? const Color(0xFF7C4DFF)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              cat,
              style: GoogleFonts.inter(
                color: selecionada ? const Color(0xFF7C4DFF) : Colors.white54,
                fontSize: 13,
                fontWeight: selecionada ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
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

  IconData _iconePrioridade(Prioridade p) {
    switch (p) {
      case Prioridade.alta:
        return Icons.arrow_upward_rounded;
      case Prioridade.media:
        return Icons.remove_rounded;
      case Prioridade.baixa:
        return Icons.arrow_downward_rounded;
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
}
