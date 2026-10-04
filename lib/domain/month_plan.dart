import 'enums.dart';

class PlanningDefaults {
  const PlanningDefaults({this.salaryCents = 0, this.extraIncomeCents = 0, this.savingsGoalCents = 0, this.investmentCents = 0});
  final int salaryCents;
  final int extraIncomeCents;
  final int savingsGoalCents;
  final int investmentCents;
}

/// Overrides de um mês. Nulo = herda o padrão; zero = zero explícito.
class MonthOverrides {
  const MonthOverrides({this.salaryCents, this.extraIncomeCents, this.savingsGoalCents, this.investmentCents});
  final int? salaryCents;
  final int? extraIncomeCents;
  final int? savingsGoalCents;
  final int? investmentCents;

  bool get isCustomized => salaryCents != null || extraIncomeCents != null || savingsGoalCents != null || investmentCents != null;
}

/// Lançamento de renda do mês (somado à base: padrão ou override).
class IncomeEntry {
  const IncomeEntry(this.kind, this.cents);
  final IncomeKind kind;
  final int cents;
}

/// Renda e investimento resolvidos para um mês.
///
/// - salário = (override ?? padrão) + lançamentos de salário
/// - renda extra = (override ?? padrão) + lançamentos de renda extra
/// - outras = lançamentos de outras rendas
/// - meta de investimento = override ?? padrão; realizado = soma dos investimentos registrados.
class MonthPlan {
  const MonthPlan({
    required this.salaryCents,
    required this.extraCents,
    required this.otherCents,
    required this.investmentTargetCents,
    required this.investmentRealizedCents,
    required this.savingsGoalCents,
    required this.customized,
  });

  final int salaryCents;
  final int extraCents;
  final int otherCents;
  final int investmentTargetCents;
  final int investmentRealizedCents;
  final int savingsGoalCents;
  final bool customized;

  int get totalIncomeCents => salaryCents + extraCents + otherCents;

  /// Quanto falta para a meta (negativo = meta ultrapassada).
  int get investmentGapCents => investmentTargetCents - investmentRealizedCents;

  /// Realizado ÷ meta. Pode passar de 1. Sem meta → 0.
  double get investmentFraction => investmentTargetCents <= 0 ? 0 : investmentRealizedCents / investmentTargetCents;

  /// Valor do mês se o restante da meta for investido (nunca menor que o já realizado).
  int get investmentProjectedCents =>
      investmentTargetCents > investmentRealizedCents ? investmentTargetCents : investmentRealizedCents;
}

MonthPlan resolveMonthPlan({
  required PlanningDefaults defaults,
  MonthOverrides overrides = const MonthOverrides(),
  List<IncomeEntry> incomes = const [],
  int investmentRealizedCents = 0,
}) {
  int sum(IncomeKind k) => incomes.where((i) => i.kind == k).fold(0, (s, i) => s + i.cents);
  return MonthPlan(
    salaryCents: (overrides.salaryCents ?? defaults.salaryCents) + sum(IncomeKind.salary),
    extraCents: (overrides.extraIncomeCents ?? defaults.extraIncomeCents) + sum(IncomeKind.extra),
    otherCents: sum(IncomeKind.other),
    investmentTargetCents: overrides.investmentCents ?? defaults.investmentCents,
    investmentRealizedCents: investmentRealizedCents,
    savingsGoalCents: overrides.savingsGoalCents ?? defaults.savingsGoalCents,
    customized: overrides.isCustomized,
  );
}
