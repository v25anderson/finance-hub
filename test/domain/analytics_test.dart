import 'package:finance_hub/domain/analytics.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/month_plan.dart';
import 'package:flutter_test/flutter_test.dart';

SpendRow row(String ym, String cat, ExpenseType t, int cents) => SpendRow(yearMonth: ym, categoryId: cat, type: t, plannedCents: cents);

void main() {
  group('meses do período', () {
    test('presets terminam no mês atual, em ordem, atravessando o ano', () {
      expect(presetMonths('2026-10', 6), ['2026-05', '2026-06', '2026-07', '2026-08', '2026-09', '2026-10']);
      expect(presetMonths('2026-02', 4), ['2025-11', '2025-12', '2026-01', '2026-02']);
      expect(presetMonths('2026-10', 12).first, '2025-11');
      expect(presetMonths('2026-10', 24).first, '2024-11');
      expect(presetMonths('2026-10', 1), ['2026-10']);
    });

    test('personalizado: inclusivo, troca se invertido, e limita a 60 meses', () {
      expect(customMonths('2026-03', '2026-05'), ['2026-03', '2026-04', '2026-05']);
      expect(customMonths('2026-05', '2026-03'), ['2026-03', '2026-04', '2026-05']);
      expect(customMonths('2026-04', '2026-04'), ['2026-04']);
      final long = customMonths('2000-01', '2026-10');
      expect(long.length, 60);
      expect(long.last, '2026-10');
    });
  });

  group('gastos', () {
    test('soma por mês, por categoria e por tipo', () {
      final a = buildAnalytics(['2026-09', '2026-10'], AnalyticsSource(spend: [
        row('2026-09', 'moradia', ExpenseType.fixed, 180000),
        row('2026-09', 'lazer', ExpenseType.variable, 20000),
        row('2026-10', 'moradia', ExpenseType.fixed, 180000),
        row('2026-10', 'lazer', ExpenseType.oneOff, 50000),
      ]));
      expect(a.months.map((m) => m.spendingCents), [200000, 230000]);
      expect(a.spendingCents, 430000);
      expect(a.averageSpendingCents, 215000);
      expect(a.categories.map((c) => (c.categoryId, c.cents)), [('moradia', 360000), ('lazer', 70000)]);
      expect(a.categories.fold<double>(0, (s, c) => s + c.fraction), closeTo(1, 1e-9));
      expect(a.types.map((t) => (t.type, t.cents)), [(ExpenseType.fixed, 360000), (ExpenseType.variable, 20000), (ExpenseType.oneOff, 50000)]);
      expect(a.types.fold<double>(0, (s, t) => s + t.fraction), closeTo(1, 1e-9));
    });

    test('ignora linhas de meses fora do período', () {
      final a = buildAnalytics(['2026-10'], AnalyticsSource(spend: [
        row('2026-09', 'a', ExpenseType.fixed, 999),
        row('2026-10', 'a', ExpenseType.fixed, 100),
        row('2026-11', 'a', ExpenseType.fixed, 999),
      ]));
      expect(a.spendingCents, 100);
    });

    test('mês sem gastos conta na média (zeros incluídos)', () {
      final a = buildAnalytics(['2026-08', '2026-09', '2026-10'], AnalyticsSource(spend: [row('2026-10', 'a', ExpenseType.fixed, 30000)]));
      expect(a.months.map((m) => m.spendingCents), [0, 0, 30000]);
      expect(a.averageSpendingCents, 10000);
    });

    test('desempate de categorias é por id; tipos sempre aparecem nos três', () {
      final a = buildAnalytics(['2026-10'], AnalyticsSource(spend: [row('2026-10', 'b', ExpenseType.fixed, 100), row('2026-10', 'a', ExpenseType.fixed, 100)]));
      expect(a.categories.map((c) => c.categoryId), ['a', 'b']);
      expect(a.types.length, 3);
      expect(a.types[1].cents, 0);
    });

    test('média arredonda para o centavo mais próximo', () {
      final a = buildAnalytics(['2026-09', '2026-10'], AnalyticsSource(spend: [row('2026-10', 'a', ExpenseType.fixed, 101)]));
      expect(a.averageSpendingCents, 51); // 50,5 → 51
    });
  });

  group('renda, investimentos e taxa de poupança', () {
    const defaults = PlanningDefaults(salaryCents: 800000, extraIncomeCents: 50000, investmentCents: 200000);

    test('renda usa o padrão, o valor do mês e lançamentos, como no planejamento', () {
      final a = buildAnalytics(['2026-08', '2026-09', '2026-10'], AnalyticsSource(
        defaults: defaults,
        overrides: {'2026-09': const MonthOverrides(salaryCents: 920000)},
        incomes: {'2026-10': const [IncomeEntry(IncomeKind.other, 10000)]},
      ));
      expect(a.months.map((m) => m.incomeCents), [850000, 970000, 860000]);
      expect(a.incomeCents, 2680000);
    });

    test('investimentos: planejado (meta do mês) × realizado (registros)', () {
      final a = buildAnalytics(['2026-09', '2026-10'], AnalyticsSource(
        defaults: defaults,
        overrides: {'2026-10': const MonthOverrides(investmentCents: 300000)},
        realizedInvestmentByMonth: {'2026-09': 150000, '2026-10': 300000},
      ));
      expect(a.months.map((m) => m.investmentPlannedCents), [200000, 300000]);
      expect(a.months.map((m) => m.investmentRealizedCents), [150000, 300000]);
      expect((a.investmentPlannedCents, a.investmentRealizedCents), (500000, 450000));
    });

    test('taxa de poupança = realizado ÷ renda, por mês e no período', () {
      final a = buildAnalytics(['2026-09', '2026-10'], AnalyticsSource(
        defaults: defaults,
        realizedInvestmentByMonth: {'2026-09': 85000, '2026-10': 170000},
      ));
      expect(a.months[0].savingsRate, closeTo(0.1, 1e-9));
      expect(a.months[1].savingsRate, closeTo(0.2, 1e-9));
      expect(a.savingsRate, closeTo(0.15, 1e-9));
    });

    test('sem renda: taxa indefinida (nulo), sem divisão por zero', () {
      final a = buildAnalytics(['2026-10'], const AnalyticsSource(realizedInvestmentByMonth: {'2026-10': 50000}));
      expect(a.months.single.incomeCents, 0);
      expect(a.months.single.savingsRate, isNull);
      expect(a.savingsRate, isNull);
    });

    test('investido acima da renda passa de 100% sem erro', () {
      final a = buildAnalytics(['2026-10'], const AnalyticsSource(defaults: PlanningDefaults(salaryCents: 100000), realizedInvestmentByMonth: {'2026-10': 150000}));
      expect(a.savingsRate, closeTo(1.5, 1e-9));
    });
  });

  group('período vazio e casos-limite', () {
    test('sem nenhum dado: zeros e hasData falso', () {
      final a = buildAnalytics(presetMonths('2026-10', 6), const AnalyticsSource());
      expect(a.hasData, isFalse);
      expect((a.spendingCents, a.incomeCents, a.averageSpendingCents), (0, 0, 0));
      expect(a.categories, isEmpty);
      expect(a.monthCount, 6);
    });

    test('só renda padrão já conta como dado', () {
      final a = buildAnalytics(['2026-10'], const AnalyticsSource(defaults: PlanningDefaults(salaryCents: 1)));
      expect(a.hasData, isTrue);
    });

    test('24 meses atravessando anos mantêm a ordem e as somas', () {
      final months = presetMonths('2026-10', 24);
      final a = buildAnalytics(months, AnalyticsSource(spend: [for (final m in months) row(m, 'a', ExpenseType.fixed, 1000)]));
      expect(a.months.length, 24);
      expect(a.months.first.yearMonth, '2024-11');
      expect(a.spendingCents, 24000);
      expect(a.averageSpendingCents, 1000);
    });

    test('lista de meses vazia não quebra', () {
      final a = buildAnalytics(const [], const AnalyticsSource());
      expect(a.averageSpendingCents, 0);
      expect(a.hasData, isFalse);
    });
  });
}
