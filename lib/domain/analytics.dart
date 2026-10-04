import 'enums.dart';
import 'month_plan.dart';

/// Lista `count` meses `yyyy-MM` terminando em [currentYearMonth] (inclusive), em ordem crescente.
List<String> presetMonths(String currentYearMonth, int count) {
  final p = currentYearMonth.split('-');
  final y = int.parse(p[0]);
  final m = int.parse(p[1]);
  return [
    for (var i = count - 1; i >= 0; i--)
      () {
        final d = DateTime(y, m - i);
        return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
      }(),
  ];
}

/// Meses de [start] a [end] (inclusive). Se vier invertido, troca. Limitado a [maxMonths] (mantém os mais recentes).
List<String> customMonths(String start, String end, {int maxMonths = 60}) {
  var a = start.compareTo(end) <= 0 ? start : end;
  final b = start.compareTo(end) <= 0 ? end : start;
  final sp = a.split('-');
  final ep = b.split('-');
  final span = (int.parse(ep[0]) - int.parse(sp[0])) * 12 + (int.parse(ep[1]) - int.parse(sp[1])) + 1;
  if (span > maxMonths) {
    a = presetMonths(b, maxMonths).first;
  }
  final ap = a.split('-');
  final n = (int.parse(ep[0]) - int.parse(ap[0])) * 12 + (int.parse(ep[1]) - int.parse(ap[1])) + 1;
  return presetMonths(b, n);
}

/// Gasto previsto agrupado por mês, categoria e tipo (contas canceladas e excluídas já ficam de fora).
class SpendRow {
  const SpendRow({required this.yearMonth, required this.categoryId, required this.type, required this.plannedCents});
  final String yearMonth;
  final String categoryId;
  final ExpenseType type;
  final int plannedCents;
}

/// Dados brutos do período, já lidos do banco. A análise é calculada só a partir deles.
class AnalyticsSource {
  const AnalyticsSource({
    this.spend = const [],
    this.incomes = const {},
    this.realizedInvestmentByMonth = const {},
    this.overrides = const {},
    this.defaults = const PlanningDefaults(),
  });
  final List<SpendRow> spend;
  final Map<String, List<IncomeEntry>> incomes;
  final Map<String, int> realizedInvestmentByMonth;
  final Map<String, MonthOverrides> overrides;
  final PlanningDefaults defaults;
}

class AnalyticsMonth {
  const AnalyticsMonth({
    required this.yearMonth,
    required this.spendingCents,
    required this.byType,
    required this.byCategory,
    required this.incomeCents,
    required this.investmentPlannedCents,
    required this.investmentRealizedCents,
  });
  final String yearMonth;
  final int spendingCents;
  final Map<ExpenseType, int> byType;
  final Map<String, int> byCategory;
  final int incomeCents;
  final int investmentPlannedCents;
  final int investmentRealizedCents;

  /// Investimentos realizados ÷ renda. Nulo quando não há renda (divisão sem significado).
  double? get savingsRate => incomeCents > 0 ? investmentRealizedCents / incomeCents : null;
}

class CategoryShare {
  const CategoryShare({required this.categoryId, required this.cents, required this.fraction});
  final String categoryId;
  final int cents;

  /// Parte do gasto total do período (0 a 1).
  final double fraction;
}

class TypeShare {
  const TypeShare({required this.type, required this.cents, required this.fraction});
  final ExpenseType type;
  final int cents;
  final double fraction;
}

/// Análise de um período. Só descreve os dados inseridos, sem interpretar nem recomendar.
class Analytics {
  const Analytics({
    required this.months,
    required this.spendingCents,
    required this.incomeCents,
    required this.investmentPlannedCents,
    required this.investmentRealizedCents,
    required this.categories,
    required this.types,
  });

  final List<AnalyticsMonth> months;
  final int spendingCents;
  final int incomeCents;
  final int investmentPlannedCents;
  final int investmentRealizedCents;

  /// Maior gasto primeiro (desempate por id).
  final List<CategoryShare> categories;
  final List<TypeShare> types;

  int get monthCount => months.length;

  /// Média mensal de gastos no período (todos os meses contam, inclusive os sem gasto).
  int get averageSpendingCents => months.isEmpty ? 0 : (spendingCents / months.length).round();

  /// Investimentos realizados ÷ renda no período; nulo sem renda.
  double? get savingsRate => incomeCents > 0 ? investmentRealizedCents / incomeCents : null;

  bool get hasData => spendingCents > 0 || incomeCents > 0 || investmentRealizedCents > 0 || investmentPlannedCents > 0;
}

/// Monta a análise dos [months] (já em ordem) a partir da [source].
///
/// - **Gastos** = valor previsto das contas com vencimento no mês.
/// - **Renda** = a mesma regra do planejamento: (padrão ou valor do mês) + lançamentos de renda.
///   Os padrões valem também para meses passados sem personalização.
/// - **Investimentos** = meta do mês (planejado) × soma dos registros (realizado).
Analytics buildAnalytics(List<String> months, AnalyticsSource source) {
  final set = months.toSet();
  final spendByMonth = <String, List<SpendRow>>{};
  for (final r in source.spend) {
    if (set.contains(r.yearMonth)) spendByMonth.putIfAbsent(r.yearMonth, () => []).add(r);
  }

  final out = <AnalyticsMonth>[];
  final catTotals = <String, int>{};
  final typeTotals = <ExpenseType, int>{};
  for (final ym in months) {
    final rows = spendByMonth[ym] ?? const <SpendRow>[];
    final byType = <ExpenseType, int>{};
    final byCat = <String, int>{};
    var spending = 0;
    for (final r in rows) {
      spending += r.plannedCents;
      byType[r.type] = (byType[r.type] ?? 0) + r.plannedCents;
      byCat[r.categoryId] = (byCat[r.categoryId] ?? 0) + r.plannedCents;
      catTotals[r.categoryId] = (catTotals[r.categoryId] ?? 0) + r.plannedCents;
      typeTotals[r.type] = (typeTotals[r.type] ?? 0) + r.plannedCents;
    }
    final realized = source.realizedInvestmentByMonth[ym] ?? 0;
    final plan = resolveMonthPlan(
      defaults: source.defaults,
      overrides: source.overrides[ym] ?? const MonthOverrides(),
      incomes: source.incomes[ym] ?? const [],
      investmentRealizedCents: realized,
    );
    out.add(AnalyticsMonth(
      yearMonth: ym,
      spendingCents: spending,
      byType: byType,
      byCategory: byCat,
      incomeCents: plan.totalIncomeCents,
      investmentPlannedCents: plan.investmentTargetCents,
      investmentRealizedCents: realized,
    ));
  }

  final total = out.fold<int>(0, (s, m) => s + m.spendingCents);
  final categories = [
    for (final e in catTotals.entries) CategoryShare(categoryId: e.key, cents: e.value, fraction: total == 0 ? 0 : e.value / total),
  ]..sort((a, b) {
      final c = b.cents.compareTo(a.cents);
      return c != 0 ? c : a.categoryId.compareTo(b.categoryId);
    });
  final types = [
    for (final t in ExpenseType.values) TypeShare(type: t, cents: typeTotals[t] ?? 0, fraction: total == 0 ? 0 : (typeTotals[t] ?? 0) / total),
  ];

  return Analytics(
    months: out,
    spendingCents: total,
    incomeCents: out.fold(0, (s, m) => s + m.incomeCents),
    investmentPlannedCents: out.fold(0, (s, m) => s + m.investmentPlannedCents),
    investmentRealizedCents: out.fold(0, (s, m) => s + m.investmentRealizedCents),
    categories: categories,
    types: types,
  );
}
