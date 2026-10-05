import 'package:finance_hub/design_system/components/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ScaffoldMessengerState> pumpHost(WidgetTester t) async {
  await t.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox.expand())));
  return ScaffoldMessenger.of(t.element(find.byType(Scaffold)));
}

void main() {
  testWidgets('aviso com "Desfazer" some sozinho em poucos segundos (não fica preso na tela)', (t) async {
    final m = await pumpHost(t);
    showAppSnack(m, 'Pagamentos removidos', actionLabel: 'Desfazer', onAction: () {});
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Pagamentos removidos'), findsOneWidget);
    await t.pump(const Duration(seconds: 3)); // 3,3 s: ainda visível
    expect(find.text('Pagamentos removidos'), findsOneWidget);
    await t.pump(const Duration(seconds: 1)); // passou de 3,5 s
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Pagamentos removidos'), findsNothing);
  });

  testWidgets('aviso simples some em ~2 s', (t) async {
    final m = await pumpHost(t);
    showAppSnack(m, 'Salvo');
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Salvo'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Salvo'), findsNothing);
  });

  testWidgets('um aviso novo substitui o atual na hora, sem fila', (t) async {
    final m = await pumpHost(t);
    showAppSnack(m, 'Primeiro', actionLabel: 'Desfazer', onAction: () {});
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    showAppSnack(m, 'Segundo', actionLabel: 'Desfazer', onAction: () {});
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Primeiro'), findsNothing);
    expect(find.text('Segundo'), findsOneWidget);
    for (var i = 0; i < 60; i++) {
      await t.pump(const Duration(milliseconds: 100)); // em passos pequenos: o temporizador só começa depois da animação de entrada
    }
    expect(find.text('Segundo'), findsNothing); // e não sobra um terceiro "esperando a vez"
  });

  testWidgets('tocar em "Desfazer" executa a ação e fecha o aviso', (t) async {
    final m = await pumpHost(t);
    var undone = 0;
    showAppSnack(m, 'Removido', actionLabel: 'Desfazer', onAction: () => undone++);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Desfazer'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(undone, 1);
    expect(find.text('Removido'), findsNothing);
  });
}
