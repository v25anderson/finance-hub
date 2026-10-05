import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../domain/analytics.dart';
import '../../domain/enums.dart';
import '../../domain/defaults_timeline.dart';
import '../../domain/month_plan.dart';
import 'planning_repository.dart';
import 'repo_base.dart';

/// Leitura dos dados de um período para as Análises. Uma passada por tabela, sem uma consulta por mês.
class AnalyticsRepository extends RepoBase {
  AnalyticsRepository(super.db);

  Future<DefaultsTimeline> getDefaultsTimeline() async => PlanningRepository(db).getDefaultsTimeline();

  /// Reemite quando qualquer tabela usada na análise muda.
  Stream<AnalyticsSource> watchRange(String startYearMonth, String endYearMonth) => db
      .customSelect('SELECT 1', readsFrom: {db.transactions, db.incomes, db.investments, db.monthConfigurations, db.planningDefaultsVersions})
      .watch()
      .asyncMap((_) => load(startYearMonth, endYearMonth));

  /// Meses `[start, end]` inclusive (`yyyy-MM`). Contas canceladas e excluídas ficam de fora.
  Future<AnalyticsSource> load(String startYearMonth, String endYearMonth) async {
    final from = monthRange(startYearMonth).start;
    final toExclusive = monthRange(endYearMonth).endExclusive;

    final txs = await (db.select(db.transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.canceledAt.isNull() &
              t.dueDate.isBiggerOrEqualValue(from) &
              t.dueDate.isSmallerThanValue(toExclusive)))
        .get();
    final grouped = <(String, String, ExpenseType), int>{};
    for (final t in txs) {
      final k = (t.dueDate.substring(0, 7), t.categoryId, t.expenseType);
      grouped[k] = (grouped[k] ?? 0) + t.plannedAmountCents;
    }
    final spend = [
      for (final e in grouped.entries) SpendRow(yearMonth: e.key.$1, categoryId: e.key.$2, type: e.key.$3, plannedCents: e.value),
    ];

    final incomeRows = await (db.select(db.incomes)
          ..where((i) => i.deletedAt.isNull() & i.yearMonth.isBiggerOrEqualValue(startYearMonth) & i.yearMonth.isSmallerOrEqualValue(endYearMonth)))
        .get();
    final incomes = <String, List<IncomeEntry>>{};
    for (final i in incomeRows) {
      incomes.putIfAbsent(i.yearMonth, () => []).add(IncomeEntry(i.kind, i.amountCents));
    }

    final invRows = await (db.select(db.investments)
          ..where((i) => i.deletedAt.isNull() & i.yearMonth.isBiggerOrEqualValue(startYearMonth) & i.yearMonth.isSmallerOrEqualValue(endYearMonth)))
        .get();
    final realized = <String, int>{};
    for (final i in invRows) {
      realized[i.yearMonth] = (realized[i.yearMonth] ?? 0) + i.realizedCents;
    }

    final configs = await (db.select(db.monthConfigurations)
          ..where((m) => m.deletedAt.isNull() & m.yearMonth.isBiggerOrEqualValue(startYearMonth) & m.yearMonth.isSmallerOrEqualValue(endYearMonth)))
        .get();
    final overrides = {
      for (final c in configs)
        c.yearMonth: MonthOverrides(
          salaryCents: c.salaryCents,
          extraIncomeCents: c.extraIncomeCents,
          savingsGoalCents: c.savingsGoalCents,
          investmentCents: c.investmentCents,
        ),
    };

    final timeline = await getDefaultsTimeline();
    return AnalyticsSource(
      spend: spend,
      incomes: incomes,
      realizedInvestmentByMonth: realized,
      overrides: overrides,
      timeline: timeline,
    );
  }
}
