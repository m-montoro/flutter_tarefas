# 📱 Flutter Tarefas — Gerenciador de Tarefas com SQLite

> **Atividade Acadêmica — Desenvolvimento Mobile com Flutter**  
> Banco de dados local: SQLite (`sqflite`)

---

## 🎯 Sobre o Projeto

Aplicativo de gerenciamento de tarefas desenvolvido em **Flutter** com persistência de dados local utilizando **SQLite** via pacote `sqflite`. O app demonstra na prática os principais conceitos de desenvolvimento mobile: estado, navegação, formulários, validações e operações CRUD completas.

---

## 🏗️ Arquitetura e Estrutura

```
lib/
├── main.dart                        # Ponto de entrada do app
├── models/
│   └── tarefa.dart                  # Modelo de domínio (entidade)
├── database/
│   └── database_helper.dart         # Camada de acesso ao SQLite (DAL)
└── screens/
    ├── home_screen.dart             # Tela principal — listagem
    ├── formulario_tarefa_screen.dart # Tela de criação/edição
    └── estatisticas_screen.dart     # Tela de estatísticas
```

### Padrões Utilizados
- **Singleton** — `DatabaseHelper` garante uma única conexão com o banco
- **DAO** — separação entre lógica de negócio e acesso a dados
- **Imutabilidade** — modelo `Tarefa` usa `copyWith` para atualizações

---

## 💾 Banco de Dados SQLite

### Tabela `tarefas`

| Coluna       | Tipo    | Descrição                         |
|--------------|---------|-----------------------------------|
| `id`         | TEXT PK | UUID gerado pelo app              |
| `titulo`     | TEXT    | Título da tarefa (obrigatório)    |
| `descricao`  | TEXT    | Descrição detalhada               |
| `concluida`  | INTEGER | 0 = pendente, 1 = concluída       |
| `prioridade` | INTEGER | 0 = baixa, 1 = média, 2 = alta    |
| `criada_em`  | TEXT    | ISO 8601 (DateTime)               |
| `concluida_em` | TEXT  | ISO 8601 — quando foi concluída   |
| `categoria`  | TEXT    | Categoria da tarefa               |

### Operações CRUD implementadas

| Operação | Método                    | Descrição                        |
|----------|---------------------------|----------------------------------|
| Create   | `inserirTarefa()`        | Insere nova tarefa no banco      |
| Read     | `buscarTodasTarefas()`   | Lê todas as tarefas              |
| Read     | `buscarPorStatus()`      | Filtra por pendente/concluída    |
| Read     | `pesquisar()`            | Busca por texto (LIKE)           |
| Update   | `atualizarTarefa()`      | Atualiza dados da tarefa         |
| Update   | `alternarConclusao()`    | Marca como concluída/pendente    |
| Delete   | `deletarTarefa()`        | Remove tarefa por ID             |
| Delete   | `limparConcluidas()`     | Remove todas as concluídas       |

---

## ✨ Funcionalidades

- ✅ Criar tarefas com título, descrição, prioridade e categoria
- ✅ Listar tarefas separadas por status (pendentes / concluídas)
- ✅ Marcar/desmarcar tarefas como concluídas com animação
- ✅ Editar tarefas existentes
- ✅ Excluir tarefas com confirmação (swipe ou dialog)
- ✅ Pesquisa em tempo real por título/descrição
- ✅ Seleção de prioridade (Alta / Média / Baixa)
- ✅ Categorias com sugestões rápidas
- ✅ Tela de estatísticas com progresso geral
- ✅ Persistência total no SQLite local
- ✅ Pull-to-refresh para atualizar lista

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio ou VS Code
- Dispositivo físico ou emulador Android/iOS

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/flutter_tarefas.git
cd flutter_tarefas

# 2. Instale as dependências
flutter pub get

# 3. Verifique o ambiente
flutter doctor

# 4. Execute o app
flutter run
```

### Build de produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recomendado para Play Store)
flutter build appbundle --release

# iOS (necessário macOS + Xcode)
flutter build ios --release
```

---

## 📦 Dependências

| Pacote              | Versão  | Uso                              |
|---------------------|---------|----------------------------------|
| `sqflite`           | ^2.3.0  | SQLite para Flutter              |
| `path`              | ^1.8.3  | Manipulação de caminhos de arquivo |
| `google_fonts`      | ^6.1.0  | Tipografia (Poppins + Inter)     |
| `uuid`              | ^4.2.1  | Geração de IDs únicos (UUIDs)    |
| `intl`              | ^0.18.1 | Formatação de datas              |
| `shared_preferences`| ^2.2.2  | Preferências do usuário          |

---

## 📐 Conceitos de Desenvolvimento Mobile Aplicados

1. **Widgets Stateful e Stateless** — gerenciamento de estado local
2. **Navegação** — `Navigator.push` / `Navigator.pop` com retorno de resultado
3. **Formulários e Validação** — `Form`, `TextFormField`, `GlobalKey<FormState>`
4. **Persistência Local** — SQLite via `sqflite`, operações CRUD completas
5. **Async/Await** — comunicação assíncrona com o banco de dados
6. **Padrão Singleton** — instância única do `DatabaseHelper`
7. **Gestos** — `Dismissible` para swipe-to-delete, `GestureDetector`
8. **Animações** — `AnimatedContainer` para feedback visual
9. **Temas** — Material 3 com tema escuro customizado
10. **Responsividade** — layouts adaptáveis com `Expanded`, `Flexible`

---

## 👨‍💻 Autor

Desenvolvido como atividade acadêmica para a disciplina de **Desenvolvimento Mobile**.

---

## 📄 Licença

Este projeto é de uso acadêmico.
