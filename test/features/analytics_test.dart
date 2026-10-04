import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

const wide = Size(1400, 1100);

Future<void> goToAnalytics(Harness h) async {
  await h.tester.tap(find.text('Análises'));
  await h.settle();
}

String textKey(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data!;

Future<void> bill(AppDatabase db, String name, int cents, DateTime due, String cat, ExpenseType type, {bool canceled = false}) async {
  final repo = TransactionRepository(db);
  final id = await repo.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: cat, expenseType: type);
  if (canceled) await repo.cancel(id);
}

/// Hoje = 10/10/2026. Período de 6 meses = mai a out/2026.
///  gastos: mai 2.500 · jun 3.800 · jul 1.800 · ago 2.400 · set 2.700 · out 2.300 = 15.500
///  renda: 8.500 por mês, exceto setembro (salário 9.200 → 9.700) = 52.200
///  investido: jun 1.500 · set 2.000 · out 500 = 4.000; meta: 2.000 × 6 = 12.000
Future<void> seedYear(AppDatabase db) async {
  final plan = PlanningRepository(db);
  await plan.updatePlanning(salaryCents: 800000, extraIncomeCents: 50000, investmentCents: 200000);
  await plan.setMonthConfig('2026-09', salaryCents: 920000);
  const m = 'cat-moradia', a = 'cat-alimentacao';
  const f = ExpenseType.fixed, v = ExpenseType.variable, o = ExpenseType.oneOff;
  await bill(db, 'Aluguel', 180000, DateTime(2026, 5, 5), m, f);
  await bill(db, 'Mercado', 70000, DateTime(2026, 5, 12), a, v);
  await bill(db, 'Aluguel', 180000, DateTime(2026, 6, 5), m, f);
  await bill(db, 'Mercado', 80000, DateTime(2026, 6, 12), a, v);
  await bill(db, 'Viagem', 120000, DateTime(2026, 6, 22), 'cat-lazer', o);
  await bill(db, 'Aluguel', 180000, DateTime(2026, 7, 5), m, f);
  await bill(db, 'Aluguel', 180000, DateTime(2026, 8, 5), m, f);
  await bill(db, 'Mercado', 60000, DateTime(2026, 8, 12), a, v);
  await bill(db, 'Aluguel', 180000, DateTime(2026, 9, 5), m, f);
  await bill(db, 'Eletrônico', 90000, DateTime(2026, 9, 25), 'cat-compras', o);
  await bill(db, 'Aluguel', 180000, DateTime(2026, 10, 5), m, f);
  await bill(db, 'Mercado', 50000, DateTime(2026, 10, 12), a, v);
  // não devem entrar no período de 6 meses:
  await bill(db, 'Cancelada', 500000, DateTime(2026, 6, 15), m, f, canceled: true);
  await bill(db, 'Futura', 700000, DateTime(2026, 11, 5), m, f);
  await bill(db, 'Antiga', 300000, DateTime(2026, 4, 5), a, v); // só entra com 12 meses
  await plan.addInvestment(yearMonth: '2026-06', realizedCents: 150000);
  await plan.addInvestment(yearMonth: '2026-09', realizedCents: 100000);
  await plan.addInvestment(yearMonth: '2026-09', realizedCents: 100000);
  await plan.addInvestment(yearMonth: '2026-10', realizedCents: 50000);
}

void main() {
  setUpAll(initHarness);

  group('período de 6 meses (padrão)', () {
    appTest('indicadores batem com os dados e ignoram cancelada, futura e anterior', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      expect(textKey(t, 'stat-spending'), 'R\$ 15.500,00');
      expect(textKey(t, 'stat-average'), 'R\$ 2.583,33');
      expect(textKey(t, 'stat-income'), 'R\$ 52.200,00');
      expect(textKey(t, 'stat-invested'), 'R\$ 4.000,00');
      expect(find.text('meta R\$ 12.000,00'), findsOneWidget);
      expect(textKey(t, 'stat-rate'), '7,7%');
      expect(textKey(t, 'savings-rate-period'), '7,7%');
      expect(textKey(t, 'period-caption'), startsWith('Maio 2026 a Outubro 2026 · 6 meses'));
    });

    appTest('avisa que é análise de dados, não recomendação', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      expect(find.text('Análise dos dados que você inseriu. Não é recomendação financeira.'), findsOneWidget);
    });

    appTest('categorias ordenadas, com valor e percentual', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      Finder inRow(String id, String text) => find.descendant(of: find.byKey(Key('category-row-$id')), matching: find.text(text));
      expect(inRow('cat-moradia', 'R\$ 10.800,00'), findsOneWidget);
      expect(inRow('cat-moradia', '69,7%'), findsOneWidget);
      expect(inRow('cat-alimentacao', 'R\$ 2.600,00'), findsOneWidget);
      expect(inRow('cat-alimentacao', '16,8%'), findsOneWidget);
      expect(inRow('cat-lazer', 'R\$ 1.200,00'), findsOneWidget);
      expect(inRow('cat-compras', '5,8%'), findsOneWidget);
      final y = [for (final id in ['cat-moradia', 'cat-alimentacao', 'cat-lazer', 'cat-compras']) t.getTopLeft(find.byKey(Key('category-row-$id'))).dy];
      expect(y, [...y]..sort()); // do maior para o menor
    });

    appTest('fixos × variáveis × pontuais somam o total', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      Finder inRow(String type, String text) => find.descendant(of: find.byKey(Key('type-row-$type')), matching: find.text(text));
      expect(inRow('fixed', 'R\$ 10.800,00'), findsOneWidget);
      expect(inRow('fixed', '69,7%'), findsOneWidget);
      expect(inRow('variable', 'R\$ 2.600,00'), findsOneWidget);
      expect(inRow('oneOff', 'R\$ 2.100,00'), findsOneWidget);
      expect(inRow('oneOff', '13,5%'), findsOneWidget);
    });

    appTest('a leitura de cada gráfico começa no mês mais recente', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      expect(textKey(t, 'readout-month-spending'), 'out/26');
      expect(textKey(t, 'readout-value-spending-0'), 'R\$ 2.300,00');
      expect(textKey(t, 'readout-value-income-0'), 'R\$ 8.500,00');
      expect(textKey(t, 'readout-value-types-0'), 'R\$ 1.800,00'); // fixo
      expect(textKey(t, 'readout-value-types-1'), 'R\$ 500,00'); // variável
      expect(textKey(t, 'readout-value-types-2'), 'R\$ 0,00'); // pontual
      expect(textKey(t, 'readout-value-investments-0'), 'R\$ 2.000,00'); // planejado
      expect(textKey(t, 'readout-value-investments-1'), 'R\$ 500,00'); // realizado
      expect(textKey(t, 'readout-value-savings-0'), '5,9%'); // 500 ÷ 8.500
    });

    appTest('tocar no gráfico seleciona o mês e atualiza a leitura', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      final r = t.getRect(find.byKey(const Key('chart-spending')));
      final slot = (r.width - 46 - 6) / 6;
      await t.tapAt(Offset(r.left + 46 + slot * 0.5, r.center.dy)); // 1º mês: maio
      await h.settle();
      expect(textKey(t, 'readout-month-spending'), 'mai/26');
      expect(textKey(t, 'readout-value-spending-0'), 'R\$ 2.500,00');
      await t.tapAt(Offset(r.left + 46 + slot * 1.5, r.center.dy)); // junho
      await h.settle();
      expect(textKey(t, 'readout-month-spending'), 'jun/26');
      expect(textKey(t, 'readout-value-spending-0'), 'R\$ 3.800,00');
    });

    appTest('ver como tabela mostra todos os meses e volta ao gráfico', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      expect(find.byKey(const Key('chart-spending')), findsOneWidget);
      await t.tap(find.byKey(const Key('table-toggle-spending')));
      await h.settle();
      expect(find.byKey(const Key('chart-spending')), findsNothing);
      final table = find.byKey(const Key('table-spending'));
      for (final v in ['mai/26', 'R\$ 2.500,00', 'jun/26', 'R\$ 3.800,00', 'out/26', 'R\$ 2.300,00']) {
        expect(find.descendant(of: table, matching: find.text(v)), findsOneWidget, reason: v);
      }
      await t.tap(find.byKey(const Key('table-toggle-spending')));
      await h.settle();
      expect(find.byKey(const Key('chart-spending')), findsOneWidget);
    });

    appTest('séries múltiplas têm legenda; série única não', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      expect(find.text('Fixo'), findsWidgets);
      expect(find.text('Planejado'), findsWidgets);
      expect(find.text('Realizado'), findsWidgets);
    });
  });

  group('filtros de período', () {
    appTest('12 meses inclui a conta anterior e muda os totais', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      await t.tap(find.text('12 meses'));
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Novembro 2025 a Outubro 2026 · 12 meses'));
      expect(textKey(t, 'stat-spending'), 'R\$ 18.500,00'); // + Antiga (3.000)
      expect(textKey(t, 'stat-income'), 'R\$ 103.200,00'); // 12 × 8.500 + 1.200 de setembro
      await t.tap(find.byKey(const Key('table-toggle-spending')));
      await h.settle();
      expect(find.descendant(of: find.byKey(const Key('table-spending')), matching: find.text('nov/25')), findsOneWidget);
    });

    appTest('24 meses atravessa dois anos sem erro', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      await t.tap(find.text('24 meses'));
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Novembro 2024 a Outubro 2026 · 24 meses'));
      expect(find.byKey(const Key('chart-types')), findsOneWidget);
      expect(find.byKey(const Key('chart-investments')), findsOneWidget);
    });

    appTest('personalizado: início e fim por mês e ano', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      await t.tap(find.text('Personalizado'));
      await h.settle();
      await t.tap(find.byKey(const Key('custom-start')));
      await h.settle();
      await t.tap(find.text('Ago'));
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Agosto 2026 a Outubro 2026 · 3 meses'));
      expect(textKey(t, 'stat-spending'), 'R\$ 7.400,00'); // ago 2.400 + set 2.700 + out 2.300
      await t.tap(find.byKey(const Key('custom-end')));
      await h.settle();
      await t.tap(find.text('Set'));
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Agosto 2026 a Setembro 2026 · 2 meses'));
      expect(textKey(t, 'stat-spending'), 'R\$ 5.100,00');
    });

    appTest('personalizado: um fim antes do início leva o início junto; o fim nunca passa do mês atual', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      await t.tap(find.text('Personalizado'));
      await h.settle();
      await t.tap(find.byKey(const Key('custom-start')));
      await h.settle();
      await t.tap(find.text('Ago'));
      await h.settle();
      await t.tap(find.byKey(const Key('custom-end')));
      await h.settle();
      await t.tap(find.text('Jun')); // antes do início
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Junho 2026 · 1 mês'));
      expect(textKey(t, 'stat-spending'), 'R\$ 3.800,00');
      await t.tap(find.byKey(const Key('custom-end')));
      await h.settle();
      await t.tap(find.text('Dez')); // futuro
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Junho 2026 a Outubro 2026')); // prende em outubro
    });
  });

  group('casos-limite', () {
    appTest('período sem nenhum dado mostra o estado vazio', size: wide, (t, h) async {
      await goToAnalytics(h);
      expect(find.byKey(const Key('analytics-empty')), findsOneWidget);
      expect(find.text('Sem dados neste período.'), findsOneWidget);
      expect(find.byKey(const Key('chart-spending')), findsNothing);
    });

    appTest('sem renda a taxa de poupança é indefinida (—), não zero nem erro', size: wide, seed: (db) async {
      await PlanningRepository(db).addInvestment(yearMonth: '2026-10', realizedCents: 50000);
      await bill(db, 'Aluguel', 100000, DateTime(2026, 10, 5), 'cat-moradia', ExpenseType.fixed);
    }, (t, h) async {
      await goToAnalytics(h);
      expect(textKey(t, 'stat-income'), 'R\$ 0,00');
      expect(textKey(t, 'stat-rate'), '—');
      expect(textKey(t, 'savings-rate-period'), '—');
      expect(textKey(t, 'readout-value-savings-0'), '—');
    });

    appTest('só renda padrão (sem contas) ainda mostra as análises', size: wide, seed: (db) => PlanningRepository(db).updatePlanning(salaryCents: 800000), (t, h) async {
      await goToAnalytics(h);
      expect(find.byKey(const Key('analytics-empty')), findsNothing);
      expect(textKey(t, 'stat-income'), 'R\$ 48.000,00');
      expect(textKey(t, 'stat-spending'), 'R\$ 0,00');
    });

    appTest('um único mês no personalizado desenha o gráfico sem erro', size: wide, seed: seedYear, (t, h) async {
      await goToAnalytics(h);
      await t.tap(find.text('Personalizado'));
      await h.settle();
      await t.tap(find.byKey(const Key('custom-end')));
      await h.settle();
      await t.tap(find.text('Mai'));
      await h.settle();
      expect(textKey(t, 'period-caption'), startsWith('Maio 2026 · 1 mês'));
      expect(textKey(t, 'readout-value-spending-0'), 'R\$ 2.500,00');
    });
  });

  appTest('celular: tudo empilhado, rótulos cabem e os gráficos aparecem', seed: seedYear, (t, h) async {
    await goToAnalytics(h);
    expect(find.text('Personalizado'), findsOneWidget);
    await scrollTo(t, find.byKey(const Key('chart-spending')));
    await scrollTo(t, find.byKey(const Key('category-bars')));
    await scrollTo(t, find.byKey(const Key('chart-types')));
    await scrollTo(t, find.byKey(const Key('chart-savings')));
    expect(find.byKey(const Key('chart-savings')), findsOneWidget);
  });
}
