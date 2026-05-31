#!/bin/bash
# setup_github.sh — Script para publicar o projeto no GitHub

echo "=== Configuração do GitHub para Flutter Tarefas ==="
echo ""

# 1. Inicializar repositório git
git init
git add .
git commit -m "feat: app Flutter Tarefas com SQLite - atividade mobile"

echo ""
echo "✅ Repositório Git inicializado!"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. Crie um repositório PÚBLICO no GitHub:"
echo "   → Acesse: https://github.com/new"
echo "   → Nome sugerido: flutter_tarefas"
echo "   → Deixe PÚBLICO (sem README — já temos)"
echo ""
echo "2. Conecte e envie o código:"
echo "   git remote add origin https://github.com/SEU_USUARIO/flutter_tarefas.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. O link do GitHub será:"
echo "   https://github.com/SEU_USUARIO/flutter_tarefas"
echo ""
echo "=== Pronto para entrega! ==="
