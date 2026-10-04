import '../data/repositories/planning_repository.dart';
import '../data/repositories/repo_base.dart';

/// Planejamento: valores padrão e personalização por mês. Só o mês personalizado muda.
class PlanningService {
  PlanningService(this.planning);
  final PlanningRepository planning;

  Future<void> setDefaults({
    required int salaryCents,
    required int extraIncomeCents,
    required int savingsGoalCents,
    required int investmentCents,
  }) => planning.updatePlanning(
    salaryCents: salaryCents,
    extraIncomeCents: extraIncomeCents,
    savingsGoalCents: savingsGoalCents,
    investmentCents: investmentCents,
  );

  /// Personaliza o mês. Campo nulo = usa o padrão; zero é zero explícito.
  /// Exige ao menos um valor (senão não há o que personalizar).
  Future<void> setMonthOverrides(
    String yearMonth, {
    int? salaryCents,
    int? extraIncomeCents,
    int? savingsGoalCents,
    int? investmentCents,
  }) {
    if (salaryCents == null &&
        extraIncomeCents == null &&
        savingsGoalCents == null &&
        investmentCents == null) {
      throw ValidationError(
        'Preencha ao menos um valor ou desligue "Personalizar este mês".',
      );
    }
    return planning.setMonthConfig(
      yearMonth,
      salaryCents: salaryCents,
      extraIncomeCents: extraIncomeCents,
      savingsGoalCents: savingsGoalCents,
      investmentCents: investmentCents,
    );
  }

  /// Volta o mês a usar todos os padrões.
  Future<void> clearMonth(String yearMonth) =>
      planning.clearMonthConfig(yearMonth);
}
