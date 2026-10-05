import 'package:finance_hub/app/app.dart';
import 'package:finance_hub/app/theme_mode_provider.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/test_db.dart';

/// Hoje fixo nos testes de UI: 10/10/2026 às 12:00.
/// Deve ser chamado em `setUpAll` (fora da zona de relógio falso do testWidgets).
Future<void> initHarness() => initializeDateFormatting('pt_BR');

final fixedNow = DateTime(2026, 10, 10, 12);

class Harness {
  Harness(this.tester, this.db);
  final WidgetTester tester;
  final AppDatabase db;

  /// Deixa streams do Drift e animações assentarem (o banco usa I/O real).
  Future<void> settle() async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Executa I/O real do banco e em seguida esvazia a zona de relógio falso. Sem isso, a atualização de
  /// streams do Drift (iniciada na zona falsa) fica pendente e a próxima operação trava, esperando o banco.
  Future<T> run<T>(Future<T> Function() f) async {
    final r = (await tester.runAsync(f)) as T; // `as T` aceita operações void (resultado nulo)
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 15)));
    }
    return r;
  }

  /// Descarta a árvore (cancelando streams do Drift), deixa os timers pendentes dispararem e fecha o banco.
  Future<void> finish() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await db.close();
    });
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// `testWidgets` com app, banco em memória e limpeza garantida.
void appTest(String name, Future<void> Function(WidgetTester t, Harness h) body,
    {Size size = const Size(390, 844), Future<void> Function(AppDatabase db)? seed}) {
  testWidgets(name, (t) async {
    final h = await pumpApp(t, size: size, seed: seed);
    await body(t, h);
    await h.finish();
  });
}

/// [seed] roda ANTES de montar o app, em tempo real: sem streams ativas, várias escritas são seguras.
Future<Harness> pumpApp(WidgetTester tester,
    {Size size = const Size(390, 844), Future<void> Function(AppDatabase db)? seed, List<Override> overrides = const [], ThemeMode? theme}) async {
  // Como a opção "reduzir movimento" do sistema: números e barras aparecem direto no valor final.
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = memoryDb(clock: () => fixedNow.toUtc());
  if (seed != null) await tester.runAsync(() => seed(db));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => fixedNow),
      if (theme != null) themeStoreProvider.overrideWithValue(MemoryThemeStore()..save(theme)),
      ...overrides,
    ],
    child: const FinanceHubApp(),
  ));
  final h = Harness(tester, db);
  await h.settle();
  return h;
}

Future<void> goToBills(Harness h) async {
  await h.tester.tap(find.byKey(const Key('nav-Contas')));
  await h.settle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

/// Rolagem da lista mais ao topo da tela (a do painel aberto, se houver), e não a de um campo de texto.
Finder _listScrollable() => find.descendant(of: find.byType(ListView).last, matching: find.byType(Scrollable)).first;

/// Toca no widget; se ainda não foi construído (lista preguiçosa, abaixo da dobra), rola até ele antes.
Future<void> tapVisible(WidgetTester t, Harness h, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(f, 150, scrollable: _listScrollable());
  } else {
    await t.ensureVisible(f);
  }
  await t.pump(const Duration(milliseconds: 100));
  await t.tap(f);
  await h.settle();
}

/// Contagem exibida em uma aba da tela de Contas.
String tabCount(WidgetTester t, String tab) => t.widget<Text>(find.byKey(Key('tab-count-$tab'))).data!;

/// Rola o painel aberto até [f] ser construído.
Future<void> scrollTo(WidgetTester t, Finder f) async {
  await t.scrollUntilVisible(f, 150, scrollable: _listScrollable());
  await t.pump(const Duration(milliseconds: 100));
}

/// Volta ao topo do painel aberto.
Future<void> scrollToTop(WidgetTester t) async {
  await t.drag(_listScrollable(), const Offset(0, 3000));
  await t.pump(const Duration(milliseconds: 300));
}

/// Rola o formulário até o botão "Salvar" (o formulário é uma lista preguiçosa) e o aciona.
/// Chama o `onPressed` do botão: com o botão rente à borda inferior, o toque por coordenada às vezes não o alcança.
Future<void> tapSave(WidgetTester t) async {
  final scrollable = find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first;
  await t.scrollUntilVisible(find.text('Salvar'), 200, scrollable: scrollable);
  final save = t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'));
  expect(save.onPressed, isNotNull, reason: 'o botão Salvar está desabilitado');
  save.onPressed!();
  await t.pump();
}
