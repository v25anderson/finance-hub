import 'package:finance_hub/app/app.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<T> run<T>(Future<T> Function() f) async => (await tester.runAsync(f))!;

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
void appTest(String name, Future<void> Function(WidgetTester t, Harness h) body, {Size size = const Size(390, 844)}) {
  testWidgets(name, (t) async {
    final h = await pumpApp(t, size: size);
    await body(t, h);
    await h.finish();
  });
}

Future<Harness> pumpApp(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = memoryDb(clock: () => fixedNow.toUtc());
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const FinanceHubApp(),
  ));
  final h = Harness(tester, db);
  await h.settle();
  return h;
}

Future<void> goToBills(Harness h) async {
  await h.tester.tap(find.text('Contas').last);
  await h.settle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

/// Toca no widget; se ainda não foi construído (lista preguiçosa, abaixo da dobra), rola até ele antes.
Future<void> tapVisible(WidgetTester t, Harness h, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).last);
    await t.pump(const Duration(milliseconds: 100));
  }
  await t.tap(f);
  await h.settle();
}

/// Contagem exibida em uma aba da tela de Contas.
String tabCount(WidgetTester t, String tab) => t.widget<Text>(find.byKey(Key('tab-count-$tab'))).data!;

/// Rola o painel aberto até [f] ser construído.
Future<void> scrollTo(WidgetTester t, Finder f) async {
  await t.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).last);
  await t.pump(const Duration(milliseconds: 100));
}

/// Volta ao topo do painel aberto.
Future<void> scrollToTop(WidgetTester t) async {
  await t.drag(find.byType(Scrollable).last, const Offset(0, 3000));
  await t.pump(const Duration(milliseconds: 300));
}
