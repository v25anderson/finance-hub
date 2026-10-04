import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/analytics_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/analytics.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late AnalyticsRepository repo;
  late TransactionRepository tx;
  late PlanningRepository planning;

  setUp(() {
    db = memoryDb();
    repo = AnalyticsRepository(db);
    tx = TransactionRepository(db);
    planning = PlanningRepository(db);
  });
  tearDown(() => db.close());

  Future<String> bill(String name, int cents, DateTime due, {String cat = 'cat-moradia', ExpenseType type = ExpenseType.fixed}) =>
      tx.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: cat, expenseType: type);

  Analytics analyze(AnalyticsSource s, List<String> months) => buildAnalytics(months, s);

  test('agrupa por mês, categoria e tipo, com fronteiras inclusivas', () async {
    await bill('Fim de agosto', 100, DateTime(2026, 8, 31));
    await bill('Início de setembro', 200, DateTime(2026, 9, 1), cat: 'cat-lazer', type: ExpenseType.variable);
    await bill('Fim de outubro', 300, DateTime(2026, 10, 31), cat: 'cat-lazer', type: ExpenseType.variable);
    await bill('Início de novembro', 400, DateTime(2026, 11, 1));
    final s = await repo.load('2026-09', '2026-10');
    final a = analyze(s, ['2026-09', '2026-10']);
    expect(a.months.map((m) => m.spendingCents), [200, 300]);
    expect(a.spendingCents, 500); // agosto e novembro ficam de fora
    expect(a.categories.single.categoryId, 'cat-lazer');
    expect(a.types.firstWhere((t) => t.type == ExpenseType.variable).cents, 500);
  });

  test('contas canceladas e excluídas não entram', () async {
    final c = await bill('Cancelada', 1000, DateTime(2026, 10, 5));
    final d = await bill('Excluída', 2000, DateTime(2026, 10, 6));
    await bill('Ok', 300, DateTime(2026, 10, 7));
    await tx.cancel(c);
    await tx.softDelete(d);
    final a = analyze(await repo.load('2026-10', '2026-10'), ['2026-10']);
    expect(a.spendingCents, 300);
  });

  test('várias contas na mesma categoria e tipo somam', () async {
    await bill('A', 100, DateTime(2026, 10, 1));
    await bill('B', 250, DateTime(2026, 10, 2));
    final s = await repo.load('2026-10', '2026-10');
    expect(s.spend.length, 1);
    expect(s.spend.single.plannedCents, 350);
  });

  test('renda, investimentos, personalização do mês e padrões', () async {
    await planning.updatePlanning(salaryCents: 800000, extraIncomeCents: 50000, investmentCents: 200000);
    await planning.setMonthConfig('2026-10', salaryCents: 920000);
    await planning.addIncome(yearMonth: '2026-10', kind: IncomeKind.other, amountCents: 10000);
    await planning.addInvestment(yearMonth: '2026-10', realizedCents: 150000);
    await planning.addInvestment(yearMonth: '2026-10', realizedCents: 30000);
    await planning.addInvestment(yearMonth: '2026-09', realizedCents: 100000);
    final a = analyze(await repo.load('2026-09', '2026-10'), ['2026-09', '2026-10']);
    expect(a.months.map((m) => m.incomeCents), [850000, 980000]); // 8.000+500 ; 9.200+500+100
    expect(a.months.map((m) => m.investmentRealizedCents), [100000, 180000]);
    expect(a.months.map((m) => m.investmentPlannedCents), [200000, 200000]);
  });

  test('lançamentos excluídos (renda e investimento) não entram', () async {
    final i = await planning.addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 5000);
    await planning.deleteIncome(i);
    final a = analyze(await repo.load('2026-10', '2026-10'), ['2026-10']);
    expect(a.incomeCents, 0);
  });

  test('período sem nada devolve fonte vazia sem erro', () async {
    final s = await repo.load('2030-01', '2030-06');
    expect(s.spend, isEmpty);
    expect(analyze(s, presetMonths('2030-06', 6)).hasData, isFalse);
  });

  test('atravessa anos (24 meses) e usa a data de vencimento', () async {
    await bill('Antiga', 111, DateTime(2024, 11, 15));
    await bill('Atual', 222, DateTime(2026, 10, 15));
    final months = presetMonths('2026-10', 24);
    final a = analyze(await repo.load(months.first, months.last), months);
    expect(a.months.first.yearMonth, '2024-11');
    expect(a.months.first.spendingCents, 111);
    expect(a.months.last.spendingCents, 222);
  });

  test('watchRange reemite quando uma conta é criada', () async {
    final seen = <int>[];
    final sub = repo.watchRange('2026-10', '2026-10').listen((s) => seen.add(s.spend.fold(0, (t, r) => t + r.plannedCents)));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await bill('Nova', 700, DateTime(2026, 10, 9));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 700);
  });
}
