import 'month_plan.dart';
import 'month_summary.dart';

/// Lista `count` meses `yyyy-MM` a partir de [startYearMonth] (inclusive), atravessando anos.
List<String> monthsFrom(String startYearMonth, int count) {
  final p = startYearMonth.split('-');
  final y = int.parse(p[0]);
  final m = int.parse(p[1]);
  return [
    for (var i = 0; i < count; i++)
      () {
        final d = DateTime(y, m + i);
        return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
      }(),
  ];
}

/// Dados de um mês já calculados (resumo de contas + renda/investimento resolvidos).
class ProjectionInput {
  const ProjectionInput({
    required this.yearMonth,
    required this.summary,
    required this.plan,
  });
  final String yearMonth;
  final MonthSummary summary;
  final MonthPlan plan;
}

/// Um mês da projeção. **Real** e **projeção** ficam em campos separados e nunca são somados em silêncio:
///
/// | | real (já aconteceu) | projeção (ainda vai acontecer) |
/// |---|---|---|
/// | renda | lançamentos de renda do mês | padrão ou valor personalizado do mês |
/// | gastos | pago (inclui excedente) | restante a pagar das contas, inclusive recorrentes futuras |
/// | investimentos | realizado | restante da meta do mês |
class ProjectionMonth {
  const ProjectionMonth({
    required this.yearMonth,
    required this.isCurrent,
    required this.incomeRealCents,
    required this.incomeProjectedCents,
    required this.spendingRealCents,
    required this.spendingProjectedCents,
    required this.investmentRealCents,
    required this.investmentProjectedCents,
    required this.savingsGoalCents,
    required this.customized,
  });

  final String yearMonth;
  final bool isCurrent;
  final int incomeRealCents, incomeProjectedCents;
  final int spendingRealCents, spendingProjectedCents;
  final int investmentRealCents, investmentProjectedCents;
  final int savingsGoalCents;
  final bool customized;

  int get incomeCents => incomeRealCents + incomeProjectedCents;
  int get spendingCents => spendingRealCents + spendingProjectedCents;
  int get investmentCents => investmentRealCents + investmentProjectedCents;

  /// Saldo projetado do mês: renda − gastos − investimentos (mesma conta do "Quanto sobra").
  int get balanceCents => incomeCents - spendingCents - investmentCents;

  /// Há algo que já aconteceu neste mês (pagamento, investimento ou renda lançada).
  bool get hasRealData =>
      incomeRealCents > 0 || spendingRealCents > 0 || investmentRealCents > 0;

  /// Diferença entre o saldo projetado e a meta de economia (positivo = acima da meta).
  /// Nulo quando não há meta definida.
  int? get savingsGapCents =>
      savingsGoalCents > 0 ? balanceCents - savingsGoalCents : null;
}

/// Projeção de vários meses, em ordem.
class Projection {
  const Projection({required this.months});
  final List<ProjectionMonth> months;

  int _sum(int Function(ProjectionMonth) f) =>
      months.fold(0, (s, m) => s + f(m));

  int get incomeRealCents => _sum((m) => m.incomeRealCents);
  int get incomeProjectedCents => _sum((m) => m.incomeProjectedCents);
  int get spendingRealCents => _sum((m) => m.spendingRealCents);
  int get spendingProjectedCents => _sum((m) => m.spendingProjectedCents);
  int get investmentRealCents => _sum((m) => m.investmentRealCents);
  int get investmentProjectedCents => _sum((m) => m.investmentProjectedCents);

  int get incomeCents => incomeRealCents + incomeProjectedCents;
  int get spendingCents => spendingRealCents + spendingProjectedCents;
  int get investmentCents => investmentRealCents + investmentProjectedCents;

  /// Soma dos saldos mensais projetados no período.
  int get balanceCents => _sum((m) => m.balanceCents);
}

/// Monta a projeção a partir dos dados de cada mês. [currentYearMonth] marca o mês atual.
Projection buildProjection(
  List<ProjectionInput> inputs, {
  required String currentYearMonth,
}) {
  return Projection(
    months: [
      for (final i in inputs)
        ProjectionMonth(
          yearMonth: i.yearMonth,
          isCurrent: i.yearMonth == currentYearMonth,
          incomeRealCents: i.plan.recordedIncomeCents,
          incomeProjectedCents:
              i.plan.totalIncomeCents - i.plan.recordedIncomeCents,
          spendingRealCents: i.summary.paidCashCents,
          spendingProjectedCents: i.summary.pendingCents,
          investmentRealCents: i.plan.investmentRealizedCents,
          investmentProjectedCents:
              i.plan.investmentProjectedCents - i.plan.investmentRealizedCents,
          savingsGoalCents: i.plan.savingsGoalCents,
          customized: i.plan.customized,
        ),
    ],
  );
}
