import 'package:finance_hub/domain/balance.dart';
import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/month_plan.dart';
import 'package:finance_hub/domain/month_summary.dart';
import 'package:finance_hub/domain/projection.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 10);

Bill bill(int planned, DateTime due, {int paid = 0}) => Bill(
  id: '${due.toIso8601String()}-$planned',
  name: 'c',
  plannedCents: planned,
  dueDate: due,
  categoryId: 'c',
  expenseType: ExpenseType.fixed,
  createdAt: DateTime.utc(2026, 1, 1),
  payments: paid > 0
      ? [
          Payment(
            id: 'p$planned${due.day}',
            billId: 'b',
            amountCents: paid,
            paidAt: DateTime.utc(2026, 10, 1),
          ),
        ]
      : const [],
);

const defaults = PlanningDefaults(
  salaryCents: 800000,
  extraIncomeCents: 50000,
  savingsGoalCents: 100000,
  investmentCents: 200000,
);

ProjectionInput input(
  String ym,
  List<Bill> bills, {
  MonthOverrides overrides = const MonthOverrides(),
  List<IncomeEntry> incomes = const [],
  int realized = 0,
  PlanningDefaults d = defaults,
}) => ProjectionInput(
  yearMonth: ym,
  summary: computeMonthSummary(bills, today),
  plan: resolveMonthPlan(
    defaults: d,
    overrides: overrides,
    incomes: incomes,
    investmentRealizedCents: realized,
  ),
);

void main() {
  test('monthsFrom atravessa o ano', () {
    expect(monthsFrom('2026-10', 4), [
      '2026-10',
      '2026-11',
      '2026-12',
      '2027-01',
    ]);
    expect(monthsFrom('2026-01', 1), ['2026-01']);
    expect(
      monthsFrom('2026-12', 13).last,
      '2027-12',
    ); // 13 meses a partir de dez/2026 terminam em dez/2027
    expect(monthsFrom('2026-10', 12).last, '2027-09');
  });

  group('mês projetado', () {
    test('mês futuro só com recorrentes: tudo é projeção, nada real', () {
      final p = buildProjection([
        input('2026-11', [
          bill(3990, DateTime(2026, 11, 10)),
          bill(180000, DateTime(2026, 11, 5)),
        ]),
      ], currentYearMonth: '2026-10');
      final m = p.months.single;
      expect(m.isCurrent, isFalse);
      expect(m.hasRealData, isFalse);
      expect((m.incomeRealCents, m.incomeProjectedCents), (0, 850000));
      expect((m.spendingRealCents, m.spendingProjectedCents), (0, 183990));
      expect((m.investmentRealCents, m.investmentProjectedCents), (0, 200000));
      expect(m.balanceCents, 850000 - 183990 - 200000);
    });

    test('mês atual separa real e projeção sem misturar', () {
      final p = buildProjection([
        input(
          '2026-10',
          [
            bill(380000, DateTime(2026, 10, 5), paid: 380000),
            bill(144000, DateTime(2026, 10, 25)),
          ],
          incomes: const [IncomeEntry(IncomeKind.extra, 10000)],
          realized: 150000,
        ),
      ], currentYearMonth: '2026-10');
      final m = p.months.single;
      expect(m.isCurrent, isTrue);
      expect(m.hasRealData, isTrue);
      expect((m.spendingRealCents, m.spendingProjectedCents), (380000, 144000));
      expect(
        (m.investmentRealCents, m.investmentProjectedCents),
        (150000, 50000),
      ); // restante da meta
      expect((m.incomeRealCents, m.incomeProjectedCents), (10000, 850000));
      expect(m.incomeCents, 860000);
    });

    test('mesmo saldo do "Quanto sobra" (consistência com o dashboard)', () {
      final i = input(
        '2026-10',
        [
          bill(380000, DateTime(2026, 10, 5), paid: 380000),
          bill(144000, DateTime(2026, 10, 25), paid: 44000),
        ],
        incomes: const [IncomeEntry(IncomeKind.other, 7000)],
        realized: 250000,
      );
      final m = buildProjection([i], currentYearMonth: '2026-10').months.single;
      expect(m.balanceCents, computeBalance(i.plan, i.summary).projectedCents);
    });

    test(
      'pagamento acima do previsto entra no gasto real (excedente preservado)',
      () {
        final m = buildProjection([
          input('2026-10', [bill(10000, DateTime(2026, 10, 5), paid: 13000)]),
        ], currentYearMonth: '2026-10').months.single;
        expect((m.spendingRealCents, m.spendingProjectedCents), (13000, 0));
      },
    );

    test(
      'meta de investimento ultrapassada: nada a projetar além do realizado',
      () {
        final m = buildProjection([
          input('2026-10', const [], realized: 250000),
        ], currentYearMonth: '2026-10').months.single;
        expect(
          (m.investmentRealCents, m.investmentProjectedCents),
          (250000, 0),
        );
      },
    );

    test('conta futura já paga antecipadamente conta como real', () {
      final m = buildProjection([
        input('2026-12', [bill(5000, DateTime(2026, 12, 20), paid: 5000)]),
      ], currentYearMonth: '2026-10').months.single;
      expect(m.spendingRealCents, 5000);
      expect(m.hasRealData, isTrue);
    });
  });

  group('casos-limite', () {
    test('mês sem renda: saldo negativo, sem erro', () {
      final m = buildProjection([
        input('2026-11', [
          bill(10000, DateTime(2026, 11, 10)),
        ], d: const PlanningDefaults()),
      ], currentYearMonth: '2026-10').months.single;
      expect(m.incomeCents, 0);
      expect(m.balanceCents, -10000);
    });

    test('mês sem gastos: saldo = renda − investimentos', () {
      final m = buildProjection([
        input('2026-11', const []),
      ], currentYearMonth: '2026-10').months.single;
      expect(m.spendingCents, 0);
      expect(m.balanceCents, 850000 - 200000);
    });

    test('mês sem nada (sem padrão, sem contas)', () {
      final m = buildProjection([
        input('2026-11', const [], d: const PlanningDefaults()),
      ], currentYearMonth: '2026-10').months.single;
      expect(
        (m.incomeCents, m.spendingCents, m.investmentCents, m.balanceCents),
        (0, 0, 0, 0),
      );
      expect(m.savingsGapCents, isNull);
    });
  });

  group('planejamento personalizado por mês', () {
    test('só o mês personalizado muda; os demais seguem o padrão', () {
      final p = buildProjection([
        input('2026-10', const []),
        input(
          '2026-11',
          const [],
          overrides: const MonthOverrides(
            salaryCents: 920000,
            extraIncomeCents: 100000,
            investmentCents: 300000,
          ),
        ),
        input('2026-12', const []),
      ], currentYearMonth: '2026-10');
      expect(p.months.map((m) => m.incomeCents), [850000, 1020000, 850000]);
      expect(p.months.map((m) => m.investmentCents), [200000, 300000, 200000]);
      expect(p.months.map((m) => m.customized), [false, true, false]);
    });

    test('override zero é zero explícito', () {
      final m = buildProjection([
        input(
          '2026-11',
          const [],
          overrides: const MonthOverrides(salaryCents: 0),
        ),
      ], currentYearMonth: '2026-10').months.single;
      expect(m.incomeCents, 50000);
    });
  });

  group('meta de economia', () {
    test('diferença para a meta: acima, abaixo e igual', () {
      int? gap(int goal, int salary) => buildProjection([
        input(
          '2026-11',
          const [],
          d: PlanningDefaults(salaryCents: salary, savingsGoalCents: goal),
        ),
      ], currentYearMonth: '2026-10').months.single.savingsGapCents;
      expect(gap(100000, 300000), 200000); // sobra 3.000, meta 1.000
      expect(gap(100000, 50000), -50000);
      expect(gap(100000, 100000), 0);
      expect(gap(0, 300000), isNull);
    });
  });

  group('totais do período', () {
    test('soma por coluna e mantém real e projeção separados', () {
      final p = buildProjection([
        input('2026-10', [
          bill(100000, DateTime(2026, 10, 5), paid: 100000),
          bill(50000, DateTime(2026, 10, 25)),
        ], realized: 50000),
        input('2026-11', [bill(70000, DateTime(2026, 11, 5))]),
      ], currentYearMonth: '2026-10');
      expect((p.spendingRealCents, p.spendingProjectedCents), (100000, 120000));
      expect(
        (p.investmentRealCents, p.investmentProjectedCents),
        (50000, 150000 + 200000),
      );
      expect(p.spendingCents, 220000);
      expect(p.balanceCents, p.months.fold(0, (s, m) => s + m.balanceCents));
      expect(p.incomeCents, 1700000);
    });

    test('12 meses: 12 entradas em ordem', () {
      final inputs = [
        for (final ym in monthsFrom('2026-10', 12)) input(ym, const []),
      ];
      final p = buildProjection(inputs, currentYearMonth: '2026-10');
      expect(p.months.length, 12);
      expect(p.months.first.isCurrent, isTrue);
      expect(p.months.skip(1).any((m) => m.isCurrent), isFalse);
      expect(p.incomeCents, 850000 * 12);
    });
  });
}
