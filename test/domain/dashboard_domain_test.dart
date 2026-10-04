import 'package:finance_hub/domain/alerts.dart';
import 'package:finance_hub/domain/balance.dart';
import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/month_comparison.dart';
import 'package:finance_hub/domain/month_plan.dart';
import 'package:finance_hub/domain/month_summary.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 10);

Bill mk(String id, int planned, DateTime due, {int paid = 0, String cat = 'a', bool canceled = false}) => Bill(
      id: id,
      name: id,
      plannedCents: planned,
      dueDate: due,
      categoryId: cat,
      expenseType: ExpenseType.fixed,
      createdAt: DateTime.utc(2026, 1, 1),
      canceledAt: canceled ? DateTime.utc(2026, 10, 1) : null,
      payments: paid > 0 ? [Payment(id: 'p$id', billId: id, amountCents: paid, paidAt: DateTime.utc(2026, 10, 1))] : const [],
    );

void main() {
  group('MonthSummary', () {
    test('exemplo do enunciado: 5.240 total, 3.800 pago, 1.440 pendente, 72,5% quitado', () {
      final s = computeMonthSummary([
        mk('a', 380000, DateTime(2026, 10, 5), paid: 380000),
        mk('b', 144000, DateTime(2026, 10, 25)),
      ], today);
      expect(s.totalCents, 524000);
      expect(s.paidCents, 380000);
      expect(s.pendingCents, 144000);
      expect(s.paidFraction, closeTo(0.7252, 0.0001));
      expect(s.paidFraction + s.remainingFraction, closeTo(1, 1e-9));
    });

    test('invariante pago + pendente = total, também com parciais', () {
      final s = computeMonthSummary([
        mk('a', 100000, DateTime(2026, 10, 25), paid: 40000),
        mk('b', 30000, DateTime(2026, 10, 3), paid: 30000),
        mk('c', 5000, DateTime(2026, 10, 2)),
      ], today);
      expect(s.paidCents + s.pendingCents, s.totalCents);
      expect(s.paidCents, 70000);
      expect(s.pendingCents, 65000);
    });

    test('pagamento acima do previsto: excedente separado, não infla o "pago" nem o percentual', () {
      final s = computeMonthSummary([mk('a', 10000, DateTime(2026, 10, 5), paid: 13000)], today);
      expect(s.paidCents, 10000);
      expect(s.excessCents, 3000);
      expect(s.paidCashCents, 13000);
      expect(s.pendingCents, 0);
      expect(s.paidFraction, 1.0);
    });

    test('canceladas ficam fora de tudo', () {
      final s = computeMonthSummary([mk('a', 10000, DateTime(2026, 10, 5), canceled: true), mk('b', 500, DateTime(2026, 10, 20))], today);
      expect(s.totalCents, 500);
      expect(s.activeCount, 1);
    });

    test('mês sem gastos: zeros, frações 0, sem divisão por zero', () {
      final s = computeMonthSummary(const [], today);
      expect((s.totalCents, s.paidCents, s.pendingCents), (0, 0, 0));
      expect(s.paidFraction, 0);
      expect(s.remainingFraction, 0);
      expect(s.isEmpty, isTrue);
      expect(s.byCategory, isEmpty);
    });

    test('listas por estado (vencida parcial aparece em vencidas e parciais, não em pendentes)', () {
      final s = computeMonthSummary([
        mk('paga', 1000, DateTime(2026, 10, 3), paid: 1000),
        mk('vencida', 1000, DateTime(2026, 10, 4)),
        mk('parcialVencida', 1000, DateTime(2026, 10, 2), paid: 300),
        mk('parcialPrazo', 1000, DateTime(2026, 10, 20), paid: 300),
        mk('pendente', 1000, DateTime(2026, 10, 15)),
        mk('futura', 1000, DateTime(2026, 12, 15)),
      ], today);
      List<String> ids(List<Bill> l) => l.map((b) => b.id).toList()..sort();
      expect(ids(s.paidBills), ['paga']);
      expect(ids(s.overdueBills), ['parcialVencida', 'vencida']);
      expect(ids(s.partiallyPaidBills), ['parcialPrazo', 'parcialVencida']);
      expect(ids(s.pendingBills), ['futura', 'parcialPrazo', 'pendente']);
      expect(ids(s.futureBills), ['futura']);
    });

    test('mês futuro: tudo previsto, nada pago nem vencido', () {
      final s = computeMonthSummary([mk('a', 5000, DateTime(2027, 3, 10)), mk('b', 7000, DateTime(2027, 3, 20))], today);
      expect(s.paidCents, 0);
      expect(s.pendingCents, 12000);
      expect(s.overdueBills, isEmpty);
      expect(s.futureBills.length, 2);
    });

    test('distribuição por categoria: ordenada, soma 100%', () {
      final s = computeMonthSummary([
        mk('a', 6000, DateTime(2026, 10, 5), cat: 'moradia'),
        mk('b', 3000, DateTime(2026, 10, 6), cat: 'lazer'),
        mk('c', 1000, DateTime(2026, 10, 7), cat: 'moradia'),
      ], today);
      expect(s.byCategory.map((c) => c.categoryId), ['moradia', 'lazer']);
      expect(s.byCategory.first.plannedCents, 7000);
      expect(s.byCategory.fold<double>(0, (a, c) => a + c.fraction), closeTo(1, 1e-9));
    });
  });

  group('MonthComparison', () {
    MonthSummary sum(Map<String, int> cats) => computeMonthSummary([
          for (final e in cats.entries) mk(e.key, e.value, DateTime(2026, 10, 20), cat: e.key),
        ], today);

    test('exemplo: 5.240 vs 4.838 → +8,3%', () {
      final c = compareMonths(sum({'a': 524000}), sum({'a': 483800}));
      expect(c.deltaCents, 40200);
      expect(c.deltaFraction, closeTo(0.0831, 0.0001));
    });

    test('queda é variação negativa', () {
      final c = compareMonths(sum({'a': 8000}), sum({'a': 10000}));
      expect(c.deltaCents, -2000);
      expect(c.deltaFraction, closeTo(-0.2, 1e-9));
    });

    test('mês anterior sem gastos: percentual indefinido (null), valor absoluto continua', () {
      final c = compareMonths(sum({'a': 5000}), sum({}));
      expect(c.deltaCents, 5000);
      expect(c.deltaFraction, isNull);
      expect(c.isEmpty, isFalse);
    });

    test('ambos vazios', () {
      final c = compareMonths(sum({}), sum({}));
      expect(c.deltaCents, 0);
      expect(c.deltaFraction, isNull);
      expect(c.isEmpty, isTrue);
      expect(c.topChanges, isEmpty);
    });

    test('principais categorias por variação absoluta, inclusive novas e que sumiram', () {
      final c = compareMonths(
        sum({'moradia': 120000, 'lazer': 20000, 'nova': 15000, 'igual': 5000}),
        sum({'moradia': 100000, 'lazer': 35000, 'sumiu': 8000, 'igual': 5000}),
      );
      expect(c.topChanges.map((x) => x.categoryId), ['moradia', 'lazer', 'nova']); // |20000|, depois empate em |15000| resolvido por id
      expect(c.topChanges.first.deltaCents, 20000);
      expect(c.topChanges.any((x) => x.categoryId == 'igual'), isFalse);
    });

    test('limita ao top solicitado', () {
      final c = compareMonths(sum({'a': 1, 'b': 2, 'c': 3, 'd': 4}), sum({}), top: 2);
      expect(c.topChanges.length, 2);
      expect(c.topChanges.first.categoryId, 'd');
    });
  });

  group('MonthPlan (renda e investimento)', () {
    const defaults = PlanningDefaults(salaryCents: 800000, extraIncomeCents: 50000, investmentCents: 200000);

    test('usa os padrões quando o mês não é personalizado (8.000 + 500 = 8.500)', () {
      final p = resolveMonthPlan(defaults: defaults);
      expect(p.salaryCents, 800000);
      expect(p.extraCents, 50000);
      expect(p.totalIncomeCents, 850000);
      expect(p.investmentTargetCents, 200000);
      expect(p.customized, isFalse);
    });

    test('mês personalizado usa overrides só onde definidos', () {
      final p = resolveMonthPlan(defaults: defaults, overrides: const MonthOverrides(salaryCents: 920000, investmentCents: 300000));
      expect(p.salaryCents, 920000);
      expect(p.extraCents, 50000); // herdado
      expect(p.investmentTargetCents, 300000);
      expect(p.customized, isTrue);
    });

    test('override zero é zero explícito (não herda)', () {
      final p = resolveMonthPlan(defaults: defaults, overrides: const MonthOverrides(salaryCents: 0));
      expect(p.salaryCents, 0);
      expect(p.totalIncomeCents, 50000);
    });

    test('lançamentos de renda somam por tipo', () {
      final p = resolveMonthPlan(defaults: defaults, incomes: const [
        IncomeEntry(IncomeKind.extra, 10000),
        IncomeEntry(IncomeKind.other, 7000),
        IncomeEntry(IncomeKind.other, 3000),
        IncomeEntry(IncomeKind.salary, 5000),
      ]);
      expect(p.salaryCents, 805000);
      expect(p.extraCents, 60000);
      expect(p.otherCents, 10000);
      expect(p.totalIncomeCents, 875000);
    });

    test('mês sem renda: tudo zero', () {
      final p = resolveMonthPlan(defaults: const PlanningDefaults());
      expect(p.totalIncomeCents, 0);
      expect(p.investmentFraction, 0);
    });

    test('investimento: meta 2.000, realizado 1.500 → 75%, diferença 500, projeção 2.000', () {
      final p = resolveMonthPlan(defaults: defaults, investmentRealizedCents: 150000);
      expect(p.investmentFraction, closeTo(0.75, 1e-9));
      expect(p.investmentGapCents, 50000);
      expect(p.investmentProjectedCents, 200000);
    });

    test('meta ultrapassada: diferença negativa, fração > 1, projeção = realizado', () {
      final p = resolveMonthPlan(defaults: defaults, investmentRealizedCents: 250000);
      expect(p.investmentFraction, closeTo(1.25, 1e-9));
      expect(p.investmentGapCents, -50000);
      expect(p.investmentProjectedCents, 250000);
    });

    test('sem meta: fração 0, sem divisão por zero', () {
      final p = resolveMonthPlan(defaults: const PlanningDefaults(), investmentRealizedCents: 5000);
      expect(p.investmentFraction, 0);
      expect(p.investmentProjectedCents, 5000);
    });
  });

  group('BalanceBreakdown (quanto sobra)', () {
    test('três saldos distintos', () {
      final summary = computeMonthSummary([
        mk('a', 380000, DateTime(2026, 10, 5), paid: 380000),
        mk('b', 144000, DateTime(2026, 10, 25)),
      ], today);
      final plan = resolveMonthPlan(
        defaults: const PlanningDefaults(salaryCents: 800000, extraIncomeCents: 50000, investmentCents: 200000),
        investmentRealizedCents: 150000,
      );
      final b = computeBalance(plan, summary);
      expect(b.incomeCents, 850000);
      expect(b.currentCents, 850000 - 380000 - 150000); // 320.000
      expect(b.afterBillsCents, 850000 - 380000 - 144000 - 150000); // 176.000
      expect(b.projectedCents, 850000 - 380000 - 144000 - 200000); // 126.000
      expect(b.currentCents, isNot(b.afterBillsCents));
      expect(b.afterBillsCents, isNot(b.projectedCents));
    });

    test('mês sem renda: saldos negativos, sem erro', () {
      final summary = computeMonthSummary([mk('a', 10000, DateTime(2026, 10, 25))], today);
      final b = computeBalance(resolveMonthPlan(defaults: const PlanningDefaults()), summary);
      expect(b.currentCents, 0);
      expect(b.afterBillsCents, -10000);
      expect(b.projectedCents, -10000);
    });

    test('mês sem gastos: saldo = renda − investimentos', () {
      final b = computeBalance(
        resolveMonthPlan(defaults: const PlanningDefaults(salaryCents: 100000, investmentCents: 20000)),
        computeMonthSummary(const [], today),
      );
      expect(b.currentCents, 100000);
      expect(b.afterBillsCents, 100000);
      expect(b.projectedCents, 80000);
    });

    test('excedente pago reduz o saldo atual (saída real de caixa)', () {
      final summary = computeMonthSummary([mk('a', 10000, DateTime(2026, 10, 5), paid: 13000)], today);
      final b = computeBalance(resolveMonthPlan(defaults: const PlanningDefaults(salaryCents: 50000)), summary);
      expect(b.paidCents, 13000);
      expect(b.currentCents, 37000);
    });

    test('mês personalizado usa renda e meta do mês', () {
      final plan = resolveMonthPlan(
        defaults: const PlanningDefaults(salaryCents: 800000, investmentCents: 200000),
        overrides: const MonthOverrides(salaryCents: 920000, investmentCents: 300000),
      );
      final b = computeBalance(plan, computeMonthSummary(const [], today));
      expect(b.incomeCents, 920000);
      expect(b.projectedCents, 620000);
    });
  });

  group('alertas de vencimento', () {
    Map<AlertKind, int> counts(List<Bill> bills) => {for (final a in computeAlerts(bills, today)) a.kind: a.count};

    test('faixas exclusivas a partir de hoje', () {
      final c = counts([
        mk('venc', 100, DateTime(2026, 10, 9)),
        mk('hoje', 100, DateTime(2026, 10, 10)),
        mk('amanha', 100, DateTime(2026, 10, 11)),
        mk('d2', 100, DateTime(2026, 10, 12)),
        mk('d7', 100, DateTime(2026, 10, 17)),
        mk('d8', 100, DateTime(2026, 10, 18)),
        mk('d30', 100, DateTime(2026, 11, 9)),
        mk('d31', 100, DateTime(2026, 11, 10)),
      ]);
      expect(c, {AlertKind.overdue: 1, AlertKind.today: 1, AlertKind.tomorrow: 1, AlertKind.week: 2, AlertKind.month: 2});
    });

    test('vencidas de meses anteriores continuam alertando', () {
      expect(counts([mk('velha', 100, DateTime(2025, 1, 5))]), {AlertKind.overdue: 1});
    });

    test('pagas e canceladas não alertam; parcial alerta com o restante', () {
      final alerts = computeAlerts([
        mk('paga', 100, DateTime(2026, 10, 11), paid: 100),
        mk('cancelada', 100, DateTime(2026, 10, 11), canceled: true),
        mk('parcial', 1000, DateTime(2026, 10, 11), paid: 400),
      ], today);
      expect(alerts.length, 1);
      expect(alerts.single.kind, AlertKind.tomorrow);
      expect(alerts.single.totalCents, 600);
    });

    test('sem contas: nenhum alerta; ordem por urgência', () {
      expect(computeAlerts(const [], today), isEmpty);
      final kinds = computeAlerts([mk('a', 1, DateTime(2026, 10, 15)), mk('b', 1, DateTime(2026, 10, 1))], today).map((a) => a.kind);
      expect(kinds, [AlertKind.overdue, AlertKind.week]);
    });

    test('vence hoje não é vencida', () {
      expect(counts([mk('a', 1, today)]), {AlertKind.today: 1});
    });
  });
}
