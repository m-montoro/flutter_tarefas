# 🎬 Roteiro do Vídeo — Flutter Tarefas (máx. 6 minutos)

## Estrutura sugerida

---

### ⏱️ 0:00 – 0:30 | Introdução
**Falar:**
"Olá! Neste vídeo vou apresentar o app *Flutter Tarefas*, desenvolvido em Flutter com banco de dados local SQLite para a atividade de Desenvolvimento Mobile.

O app permite criar, editar, excluir e organizar tarefas com prioridades, categorias e estatísticas — tudo persistido localmente no dispositivo."

---

### ⏱️ 0:30 – 1:30 | Demonstração do App

**Mostrar na tela:**
1. Tela principal vazia (sem tarefas)
2. Clicar em "Nova Tarefa"
3. Preencher o formulário:
   - Título: "Estudar Flutter"
   - Descrição: "Revisar Widgets, State e SQLite"
   - Prioridade: Alta
   - Categoria: Estudos
4. Salvar → mostrar tarefa na lista

5. Criar mais 2 tarefas rapidamente:
   - "Comprar material escolar" — Média — Compras
   - "Enviar relatório" — Alta — Trabalho

6. Marcar uma tarefa como concluída (tap no checkbox)
7. Ver a aba "Concluídas"
8. Abrir tela de Estatísticas

---

### ⏱️ 1:30 – 3:00 | Explicação do Código

**Mostrar no editor:**

#### 1. Modelo (tarefa.dart)
"Aqui temos a classe `Tarefa`, que representa nosso modelo de dados. Ela tem os atributos da tarefa e dois métodos importantes: `toMap()` que converte para Map para salvar no SQLite, e `fromMap()` que reconstrói o objeto ao ler do banco."

#### 2. DatabaseHelper (database_helper.dart)
"Esta é a camada de acesso ao banco. Usamos o padrão *Singleton* para garantir apenas uma conexão. O método `_inicializarDB()` cria o arquivo `tarefas.db` no dispositivo e o método `_criarTabelas()` define a estrutura da tabela via SQL DDL.

Aqui vemos as operações CRUD:
- `inserirTarefa()` — usa `db.insert()`
- `buscarTodasTarefas()` — usa `db.query()`
- `atualizarTarefa()` — usa `db.update()`
- `deletarTarefa()` — usa `db.delete()`
- `pesquisar()` — usa SQL com operador LIKE"

---

### ⏱️ 3:00 – 4:30 | Telas e Navegação

**Mostrar:**

#### HomeScreen
"A tela principal usa um `TabController` para separar pendentes de concluídas. A lista usa `Dismissible` para o swipe de exclusão e `RefreshIndicator` para o pull-to-refresh. Cada card exibe a prioridade com cores e a data de criação."

#### FormularioTarefaScreen
"O formulário usa `Form` com `GlobalKey<FormState>` para validação. Os campos têm validadores — o título é obrigatório e tem mínimo de 3 caracteres. O seletor de prioridade usa `AnimatedContainer` para feedback visual."

#### EstatisticasScreen
"A tela de estatísticas busca dados agregados do banco usando `rawQuery` SQL e exibe com `LinearProgressIndicator`."

---

### ⏱️ 4:30 – 5:30 | Conceitos Demonstrados

**Falar:**
"O projeto demonstra os seguintes conceitos de desenvolvimento mobile:

1. **StatefulWidget** — gerenciamento de estado com `setState`
2. **Navegação** — `Navigator.push` passando parâmetros entre telas
3. **Async/Await** — operações assíncronas com o banco de dados
4. **SQLite** — criação de banco, tabelas, índices e CRUD completo
5. **Formulários** — validação com `Form` e `TextFormField`
6. **Gestos** — `Dismissible` e `GestureDetector`
7. **Padrão Singleton** — instância única do DatabaseHelper"

---

### ⏱️ 5:30 – 6:00 | Encerramento

**Falar:**
"O código completo está disponível no GitHub no link da descrição. O app roda em Android e iOS, e todas as tarefas ficam salvas localmente no dispositivo mesmo sem internet.

Obrigado!"

---

## 🛠️ Dicas para gravar

- Use o **emulador Android** com a tela espelhada no OBS ou Scrcpy
- Ative o modo desenvolvedor e tamanho de fonte aumentado para facilitar a visualização
- Grave em resolução 1080p mínimo
- Use o plugin **Device Frame** ou **Flutter Device Preview** para mostrar o app com moldura de celular
- Edite com DaVinci Resolve (gratuito) ou CapCut para adicionar zoom nos trechos de código
