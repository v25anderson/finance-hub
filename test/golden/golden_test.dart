import 'dart:io';

import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/design_system/components/app_button.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/value_range.dart';
import 'package:finance_hub/design_system/components/sync_light.dart';
import 'package:finance_hub/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/test_harness.dart';
import '../support/seed.dart';

/// Testes golden: comparam capturas das telas principais com as imagens em `test/golden/goldens/`.
/// Para regenerar depois de uma mudança visual intencional: `flutter test --update-goldens test/golden`.
/// As imagens foram geradas no Linux com o Flutter fixado no workflow; outra plataforma pode renderizar texto de forma diferente.
Future<Harness> open(WidgetTester t, {Size size = const Size(390, 844), String? tab, bool light = false}) async {
  final h = await pumpApp(t, size: size, seed: seedRich);
  if (light) {
    await t.tap(find.byKey(const Key('theme-toggle')));
    await h.settle();
  }
  if (tab != null) {
    await t.tap(find.byKey(Key('nav-$tab')));
    await h.settle();
  }
  return h;
}

Future<void> shot(WidgetTester t, String name) => expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));

/// Nos testes o Flutter usa a fonte "Ahem" (blocos) e ícones viram quadrados. Para as imagens ficarem legíveis,
/// carrega a Inter do projeto e a fonte de ícones do SDK. Falha alto se não achar, em vez de gerar imagens diferentes.
Future<void> loadGoldenFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();

  final root = Platform.environment['FLUTTER_ROOT'] ?? File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (!icons.existsSync()) throw StateError('Fonte de ícones não encontrada em ${icons.path}');
  final loader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await initHarness();
    await loadGoldenFonts();
  });

  testWidgets('início (escuro)', (t) async {
    final h = await open(t);
    await shot(t, 'home_dark');
    await h.finish();
  });

  testWidgets('início (claro)', (t) async {
    final h = await open(t, light: true);
    await shot(t, 'home_light');
    await h.finish();
  });

  testWidgets('início no desktop (escuro)', (t) async {
    final h = await open(t, size: const Size(1400, 900));
    await shot(t, 'home_desktop_dark');
    await h.finish();
  });

  for (final (tab, name) in [('Contas', 'bills'), ('Calendário', 'calendar'), ('Planejamento', 'planning'), ('Análises', 'analytics')]) {
    testWidgets('$tab (escuro)', (t) async {
      final h = await open(t, tab: tab);
      await shot(t, '${name}_dark');
      await h.finish();
    });
  }

  testWidgets('contas (claro)', (t) async {
    final h = await open(t, tab: 'Contas', light: true);
    await shot(t, 'bills_light');
    await h.finish();
  });

  testWidgets('detalhe do mês com os filtros em blocos', (t) async {
    final h = await open(t);
    await t.tap(find.text('GASTOS DO MÊS'));
    await h.settle();
    await shot(t, 'month_detail_dark');
    await h.finish();
  });

  testWidgets('formulário de nova conta com faixa de valor', (t) async {
    final h = await open(t, tab: 'Contas');
    await t.tap(find.byTooltip('Adicionar'));
    await h.settle();
    await t.enterText(field('Nome'), 'Energia');
    final scrollable = find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const Key('range-switch')), 200, scrollable: scrollable);
    await t.tap(find.byKey(const Key('range-switch')));
    await h.settle();
    await t.scrollUntilVisible(find.byKey(const Key('range-max')), 200, scrollable: scrollable);
    await t.enterText(find.byKey(const Key('range-min')), '200');
    await t.enterText(find.byKey(const Key('range-max')), '300');
    await h.settle(); // deixa a animação dos rótulos terminar
    await shot(t, 'bill_form_range_dark');
    await h.finish();
  });

  testWidgets('contas com faixa na lista e detalhe', (t) async {
    final h = await pumpApp(t, seed: (db) async {
      await seedRich(db);
      await TransactionRepository(db).create(
          name: 'Energia elétrica',
          plannedAmountCents: 25000,
          dueDate: DateTime(2026, 10, 22),
          categoryId: 'cat-moradia',
          expenseType: ExpenseType.variable,
          range: const ValueRange(20000, 30000));
    });
    await t.tap(find.byKey(const Key('nav-Contas')));
    await h.settle();
    await shot(t, 'bills_range_dark');
    await t.tap(find.text('Energia elétrica'));
    await h.settle();
    await shot(t, 'bill_detail_range_dark');
    await h.finish();
  });

  testWidgets('backup e sincronização com o Drive não configurado', (t) async {
    final h = await open(t, tab: 'Análises');
    await t.tap(find.byKey(const Key('backup-open')));
    await h.settle();
    await shot(t, 'backup_unavailable_dark');
    await h.finish();
  });

  for (final light in [false, true]) {
    testWidgets('componentes: botões e luzes de sincronização (${light ? 'claro' : 'escuro'})', (t) async {
      t.view.physicalSize = const Size(420, 520);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: light ? AppTheme.light() : AppTheme.dark(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
              AppButton(label: 'Principal', icon: Icons.add_rounded, kind: AppButtonKind.primary, expand: true, onPressed: () {}),
              AppButton(label: 'Tonal', icon: Icons.tune_rounded, kind: AppButtonKind.tonal, expand: true, onPressed: () {}),
              AppButton(label: 'Discreto', kind: AppButtonKind.ghost, expand: true, onPressed: () {}),
              const AppButton(label: 'Desligado', icon: Icons.cloud_outlined, kind: AppButtonKind.primary, expand: true, onPressed: null),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                SyncBadge(state: SyncLightState.off, label: 'Desconectado'),
                SyncBadge(state: SyncLightState.idle, label: 'Conectado'),
                SyncBadge(state: SyncLightState.busy, label: 'Sincronizando…'),
                SyncBadge(state: SyncLightState.ok, label: 'Sincronizado'),
                SyncBadge(state: SyncLightState.problem, label: '2 conflitos'),
              ]),
            ]),
          ),
        ),
      ));
      await t.pump();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/components_${light ? 'light' : 'dark'}.png'));
    });
  }
}
