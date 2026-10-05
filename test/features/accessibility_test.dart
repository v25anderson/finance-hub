import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/seed.dart';
import 'test_harness.dart';

void main() {
  setUpAll(initHarness);

  for (final scale in [1.5, 2.0]) {
    for (final tab in ['Visão geral', 'Contas', 'Calendário', 'Planejamento', 'Análises']) {
      testWidgets('fonte ${scale}x em celular pequeno: "$tab" sem estouro de layout', (t) async {
        t.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final h = await pumpApp(t, size: const Size(360, 740), seed: seedRich);
        if (tab != 'Visão geral') {
          await t.tap(find.byKey(Key('nav-$tab')));
          await h.settle();
        }
        expect(t.takeException(), isNull);
        // o dock continua inteiro e tocável
        expect(find.byKey(Key('nav-$tab')), findsOneWidget);
        await h.finish();
      });
    }
  }

  testWidgets('leitor de tela: os itens do dock têm rótulo e papel de botão', (t) async {
    final h = await pumpApp(t, size: const Size(390, 844));
    final handle = t.ensureSemantics();
    await t.pump(); // a árvore de semântica só é montada no quadro seguinte
    for (final label in ['Visão geral', 'Contas', 'Calendário', 'Planejamento', 'Análises']) {
      final node = t.getSemantics(find.byKey(Key('nav-$label')));
      expect(node.label, contains(label), reason: 'rótulo do item "$label"');
      expect(node.flagsCollection.isButton, isTrue, reason: '"$label" deve ser um botão');
    }
    expect(find.bySemanticsLabel('Adicionar'), findsWidgets);
    handle.dispose();
    await h.finish();
  });
}
