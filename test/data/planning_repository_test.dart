import 'package:drift/drift.dart' show Value;
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/defaults_helpers.dart';
import 'test_db.dart';

void main() {
  late AppDatabase db;
  late PlanningRepository repo;
  setUp(() {
    db = memoryDb();
    repo = PlanningRepository(db);
  });
  tearDown(() => db.close());

  test('sem padrão definido a linha do tempo começa vazia', () async {
    final t = await repo.getDefaultsTimeline();
    expect(t.isEmpty, isTrue);
    expect(t.at('2026-10'), isNull);
    expect(t.atOrZero('2026-10').salaryCents, 0);
  });

  test('definir padrões a partir de um mês cria uma versão e não toca nos meses anteriores', () async {
    await repo.defaultsFrom('2026-10', salary: 800000, investment: 200000, extra: 50000);
    final t = await repo.getDefaultsTimeline();
    expect(t.at('2026-09'), isNull); // antes não havia padrão: continua sem
    expect(t.at('2026-10')!.salaryCents, 800000);
    expect(t.at('2027-03')!.investmentCents, 200000); // vale até a próxima mudança
    expect(t.firstEffective, '2026-10');
  });

  test('mudar o padrão depois: meses anteriores mantêm o valor que valia; os seguintes mudam', () async {
    await repo.defaultsFrom('2026-05', salary: 800000);
    await repo.defaultsFrom('2026-10', salary: 900000);
    final t = await repo.getDefaultsTimeline();
    for (final m in ['2026-05', '2026-07', '2026-09']) {
      expect(t.atOrZero(m).salaryCents, 800000, reason: m);
    }
    expect(t.atOrZero('2026-10').salaryCents, 900000);
    expect(t.atOrZero('2027-01').salaryCents, 900000);
    expect(t.versions.map((v) => v.effectiveFrom), ['2026-05', '2026-10']);
  });

  test('repetir no mesmo mês atualiza a mesma versão (id determinístico); um mês anterior ao primeiro entra no começo', () async {
    await repo.defaultsFrom('2026-10', salary: 1);
    await repo.defaultsFrom('2026-10', salary: 2);
    final rows = await db.select(db.planningDefaultsVersions).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'defaults-2026-10');
    expect(rows.single.salaryCents, 2);
    expect(rows.single.version, 2);
    await repo.defaultsFrom('2026-06', salary: 5); // o usuário editou estando em junho
    final t = await repo.getDefaultsTimeline();
    expect(t.atOrZero('2026-07').salaryCents, 5);
    expect(t.atOrZero('2026-10').salaryCents, 2); // a versão de outubro continua sendo a dela
  });

  test('valores negativos e mês inválido são rejeitados', () {
    expect(() => repo.defaultsFrom('2026-10', salary: -1), throwsA(isA<ValidationError>()));
    expect(() => repo.defaultsFrom('2026-13', salary: 1), throwsA(isA<ValidationError>()));
    expect(() => repo.defaultsFrom('outubro', salary: 1), throwsA(isA<ValidationError>()));
    expect(() => repo.setMonthConfig('2026-10', salaryCents: -1), throwsA(isA<ValidationError>()));
  });

  test('migração do padrão único antigo: vira a primeira versão, a partir do mês do primeiro dado', () async {
    await (db.update(db.plannings)..where((p) => p.id.equals(planningId))).write(const PlanningsCompanion(defaultSalaryCents: Value(850000)));
    await TransactionRepository(db).create(name: 'A', plannedAmountCents: 100, dueDate: DateTime(2026, 3, 15), categoryId: 'cat-outros', expenseType: ExpenseType.fixed);
    await TransactionRepository(db).create(name: 'B', plannedAmountCents: 100, dueDate: DateTime(2026, 8, 15), categoryId: 'cat-outros', expenseType: ExpenseType.fixed);
    await db.seedDefaultsFromLegacy();
    final t = await repo.getDefaultsTimeline();
    expect(t.versions.map((v) => v.effectiveFrom), ['2026-03']); // antes de março nada foi registrado
    expect(t.atOrZero('2026-02').salaryCents, 0);
    expect(t.atOrZero('2026-03').salaryCents, 850000);
    await db.seedDefaultsFromLegacy(); // idempotente
    expect((await db.select(db.planningDefaultsVersions).get()).length, 1);
  });

  test('migração sem valores no padrão antigo não cria versão; sem nenhum dado vale a partir do mês atual', () async {
    await db.seedDefaultsFromLegacy();
    expect((await db.select(db.planningDefaultsVersions).get()), isEmpty);
    await (db.update(db.plannings)..where((p) => p.id.equals(planningId))).write(const PlanningsCompanion(defaultSalaryCents: Value(1)));
    await db.seedDefaultsFromLegacy();
    final rows = await db.select(db.planningDefaultsVersions).get();
    expect(rows.single.effectiveFrom, matches(RegExp(r'^\d{4}-\d{2}$')));
  });

  test('mês personalizado afeta apenas aquele mês', () async {
    await repo.defaultsFrom('2026-01', salary: 800000);
    await repo.setMonthConfig('2026-10', salaryCents: 920000, investmentCents: 300000);
    final out = await repo.getMonthConfig('2026-10');
    expect(out!.salaryCents, 920000);
    expect(out.extraIncomeCents, isNull); // herda o padrão
    expect(await repo.getMonthConfig('2026-11'), isNull);
    expect((await repo.getDefaultsTimeline()).atOrZero('2026-10').salaryCents, 800000);
  });

  test('zero explícito é diferente de nulo (herdar)', () async {
    await repo.setMonthConfig('2026-10', salaryCents: 0);
    final c = (await repo.getMonthConfig('2026-10'))!;
    expect(c.salaryCents, 0);
    expect(c.extraIncomeCents, isNull);
  });

  test('regravar o mês atualiza o mesmo registro; clear volta a herdar tudo', () async {
    await repo.setMonthConfig('2026-10', salaryCents: 1);
    await repo.setMonthConfig('2026-10', salaryCents: 2);
    expect(await db.select(db.monthConfigurations).get(), hasLength(1));
    await repo.clearMonthConfig('2026-10');
    final c = (await repo.getMonthConfig('2026-10'))!;
    expect(c.salaryCents, isNull);
    expect(c.version, 3);
    await repo.clearMonthConfig('2030-01'); // sem efeito, sem erro
    expect(await repo.getMonthConfig('2030-01'), isNull);
  });

  test('rendas por mês com soft delete', () async {
    final id = await repo.addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 50000);
    await repo.addIncome(yearMonth: '2026-11', kind: IncomeKind.salary, amountCents: 800000);
    expect(await repo.watchIncomes('2026-10').first, hasLength(1));
    await repo.deleteIncome(id);
    expect(await repo.watchIncomes('2026-10').first, isEmpty);
    expect(await db.select(db.incomes).get(), hasLength(2));
  });

  test('investimentos: planejado × realizado', () async {
    final id = await repo.addInvestment(yearMonth: '2026-10', plannedCents: 200000);
    await repo.setInvestmentRealized(id, 150000);
    final row = (await repo.watchInvestments('2026-10').first).single;
    expect(row.plannedCents, 200000);
    expect(row.realizedCents, 150000);
    expect(() => repo.setInvestmentRealized('nada', 1), throwsA(isA<NotFoundError>()));
  });
}
