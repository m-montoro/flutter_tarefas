// test/widget_test.dart
// Testes básicos do aplicativo

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tarefas/main.dart';

void main() {
  testWidgets('App inicializa corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterTarefasApp());
    expect(find.text('Minhas Tarefas'), findsOneWidget);
  });

  testWidgets('Botão de nova tarefa está presente', (WidgetTester tester) async {
    await tester.pumpWidget(const FlutterTarefasApp());
    expect(find.text('Nova Tarefa'), findsOneWidget);
  });
}
