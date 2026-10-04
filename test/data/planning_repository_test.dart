import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late PlanningRepository repo;
  setUp(() {
    db = memoryDb();
    repo = PlanningRepository(db);
  });
  tearDown(() => db.close());

  test('planejamento padrão começa zerado e pode ser atualizado parcialmente', () async {
    var p = await repo.getPlanning();
    expect(p.defaultSalaryCents, 0);
    await repo.updatePlanning(salaryCents: 800000, investmentCents: 200000);
    await repo.updatePlanning(extraIncomeCents: 50000);
    p = await repo.getPlanning();
    expect(p.defaultSalaryCents, 800000);
    expect(p.defaultExtraIncomeCents, 50000);
    expect(p.defaultInvestmentCents, 200000);
    expect(p.version, 3);
  });

  test('valores negativos são rejeitados', () {
    expect(() => repo.updatePlanning(salaryCents: -1), throwsA(isA<ValidationError>()));
    expect(() => repo.setMonthConfig('2026-10', salaryCents: -1), throwsA(isA<ValidationError>()));
  });

  test('mês personalizado afeta apenas aquele mês', () async {
    await repo.updatePlanning(salaryCents: 800000);
    await repo.setMonthConfig('2026-10', salaryCents: 920000, investmentCents: 300000);
    final out = await repo.getMonthConfig('2026-10');
    expect(out!.salaryCents, 920000);
    expect(out.extraIncomeCents, isNull); // herda o padrão
    expect(await repo.getMonthConfig('2026-11'), isNull);
    expect((await repo.getPlanning()).defaultSalaryCents, 800000);
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
