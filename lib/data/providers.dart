import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/bill_service.dart';
import '../application/dashboard_data.dart';
import '../application/income_investment_service.dart';
import '../application/planning_service.dart';
import '../application/recurrence_service.dart';
import '../core/dates.dart';
import '../domain/alerts.dart';
import '../domain/balance.dart';
import '../domain/month_comparison.dart';
import '../domain/month_plan.dart';
import '../domain/month_summary.dart';
import '../domain/projection.dart';
import '../domain/recurrence.dart';
import '../domain/bill.dart';
import 'db/app_database.dart';
import 'db/connection.dart';
import 'repositories/bill_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/planning_repository.dart';
import 'repositories/recurring_repository.dart';
import 'repositories/transaction_repository.dart';

/// Relógio do app (sobrescrevível em testes).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// "Hoje" como data pura.
final todayProvider = Provider<DateTime>(
  (ref) => dateOnly(ref.watch(clockProvider)()),
);

/// Banco único do app. Em testes, sobrescreva com um banco em memória.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openAppConnection());
  ref.onDispose(db.close);
  return db;
});

final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(ref.watch(databaseProvider)),
);
final planningRepositoryProvider = Provider(
  (ref) => PlanningRepository(ref.watch(databaseProvider)),
);
final recurringRepositoryProvider = Provider(
  (ref) => RecurringRepository(ref.watch(databaseProvider)),
);
final billRepositoryProvider = Provider(
  (ref) => BillRepository(ref.watch(databaseProvider)),
);

final billServiceProvider = Provider(
  (ref) => BillService(
    bills: ref.watch(billRepositoryProvider),
    transactions: ref.watch(transactionRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final recurrenceServiceProvider = Provider(
  (ref) => RecurrenceService(
    rules: ref.watch(recurringRepositoryProvider),
    transactions: ref.watch(transactionRepositoryProvider),
    bills: ref.watch(billRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final categoriesProvider = StreamProvider(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Contas do mês `yyyy-MM`.
///
/// Ao observar um mês, garante (em segundo plano) que as ocorrências das recorrências existam até ele;
/// o stream reemite quando elas são criadas.
final billsForMonthProvider = StreamProvider.family<List<Bill>, String>((
  ref,
  ym,
) {
  unawaited(
    ref
        .read(recurrenceServiceProvider)
        .ensureMonth(ym)
        .then<void>((_) {}, onError: (_) {}),
  );
  return ref.watch(billRepositoryProvider).watchMonth(ym);
});

/// Regra de recorrência (reativa), inclusive encerrada ou excluída, para mostrar o histórico.
final recurrenceRuleProvider = StreamProvider.family<RecurrenceRule?, String>(
  (ref, id) => ref.watch(recurringRepositoryProvider).watchRule(id),
);

/// Ocorrências ativas de uma recorrência (histórico de valores).
final occurrencesProvider = StreamProvider.family<List<Bill>, String>(
  (ref, ruleId) => ref.watch(billRepositoryProvider).watchOccurrences(ruleId),
);

/// Uma conta (reativa), para a tela de detalhe.
final billProvider = StreamProvider.family<Bill?, String>(
  (ref, id) => ref.watch(billRepositoryProvider).watchBill(id),
);

final incomeInvestmentServiceProvider = Provider(
  (ref) => IncomeInvestmentService(ref.watch(planningRepositoryProvider)),
);

final planningProvider = StreamProvider(
  (ref) => ref.watch(planningRepositoryProvider).watchPlanning(),
);
final monthConfigProvider = StreamProvider.family(
  (ref, String ym) =>
      ref.watch(planningRepositoryProvider).watchMonthConfig(ym),
);
final incomesProvider = StreamProvider.family(
  (ref, String ym) => ref.watch(planningRepositoryProvider).watchIncomes(ym),
);
final investmentsProvider = StreamProvider.family(
  (ref, String ym) =>
      ref.watch(planningRepositoryProvider).watchInvestments(ym),
);

/// Contas em aberto até 30 dias à frente (alertas; independem do mês exibido).
final openBillsProvider = StreamProvider((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(billRepositoryProvider).watchOpenBills(today);
});

/// Dados do dashboard de um mês. Fica em carregamento até todas as fontes responderem.
final dashboardProvider = Provider.family<AsyncValue<DashboardData>, String>((
  ref,
  ym,
) {
  final today = ref.watch(todayProvider);
  final bills = ref.watch(billsForMonthProvider(ym));
  final prevBills = ref.watch(billsForMonthProvider(previousYearMonth(ym)));
  final open = ref.watch(openBillsProvider);
  final planning = ref.watch(planningProvider);
  final config = ref.watch(monthConfigProvider(ym));
  final incomes = ref.watch(incomesProvider(ym));
  final investments = ref.watch(investmentsProvider(ym));

  final all = <AsyncValue<Object?>>[
    bills,
    prevBills,
    open,
    planning,
    config,
    incomes,
    investments,
  ];
  for (final v in all) {
    if (v.hasError) {
      return AsyncError(v.error!, v.stackTrace ?? StackTrace.current);
    }
  }
  if (all.any((v) => !v.hasValue)) return const AsyncLoading();

  final summary = computeMonthSummary(bills.requireValue, today);
  final previous = computeMonthSummary(prevBills.requireValue, today);
  final p = planning.requireValue;
  final c = config.requireValue;
  final plan = resolveMonthPlan(
    defaults: PlanningDefaults(
      salaryCents: p.defaultSalaryCents,
      extraIncomeCents: p.defaultExtraIncomeCents,
      savingsGoalCents: p.defaultSavingsGoalCents,
      investmentCents: p.defaultInvestmentCents,
    ),
    overrides: c == null
        ? const MonthOverrides()
        : MonthOverrides(
            salaryCents: c.salaryCents,
            extraIncomeCents: c.extraIncomeCents,
            savingsGoalCents: c.savingsGoalCents,
            investmentCents: c.investmentCents,
          ),
    incomes: [
      for (final i in incomes.requireValue) IncomeEntry(i.kind, i.amountCents),
    ],
    investmentRealizedCents: investments.requireValue.fold(
      0,
      (s, i) => s + i.realizedCents,
    ),
  );
  return AsyncData(
    DashboardData(
      yearMonth: ym,
      summary: summary,
      previousSummary: previous,
      comparison: compareMonths(summary, previous),
      plan: plan,
      balance: computeBalance(plan, summary),
      alerts: computeAlerts(open.requireValue, today),
    ),
  );
});

final planningServiceProvider = Provider(
  (ref) => PlanningService(ref.watch(planningRepositoryProvider)),
);

/// Quantos meses a projeção mostra, contando o mês atual: 1, 3, 6 ou 12.
class ProjectionRangeNotifier extends Notifier<int> {
  @override
  int build() => 3;
  void set(int months) => state = months;
}

final projectionRangeProvider = NotifierProvider<ProjectionRangeNotifier, int>(
  ProjectionRangeNotifier.new,
);

/// Projeção a partir do **mês atual** (não do mês exibido). Reaproveita os dados de cada mês do dashboard.
final projectionProvider = Provider<AsyncValue<Projection>>((ref) {
  final today = ref.watch(todayProvider);
  final current = yearMonthOf(today);
  final months = monthsFrom(current, ref.watch(projectionRangeProvider));
  final datas = [for (final ym in months) ref.watch(dashboardProvider(ym))];
  for (final d in datas) {
    if (d.hasError) {
      return AsyncError(d.error!, d.stackTrace ?? StackTrace.current);
    }
  }
  if (datas.any((d) => !d.hasValue)) return const AsyncLoading();
  return AsyncData(
    buildProjection([
      for (final d in datas)
        ProjectionInput(
          yearMonth: d.requireValue.yearMonth,
          summary: d.requireValue.summary,
          plan: d.requireValue.plan,
        ),
    ], currentYearMonth: current),
  );
});
