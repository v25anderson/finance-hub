import '../data/repositories/planning_repository.dart';
import '../data/repositories/repo_base.dart';
import '../domain/enums.dart';

/// Renda e investimentos do mês. A edição completa do planejamento entra na Fase 7.
class IncomeInvestmentService {
  IncomeInvestmentService(this.planning);
  final PlanningRepository planning;

  /// Padrões **a partir de** [fromYearMonth] (valem até a próxima mudança); os meses anteriores não mudam.
  Future<void> setDefaults({
    required String fromYearMonth,
    required int salaryCents,
    required int extraIncomeCents,
    required int savingsGoalCents,
    required int investmentCents,
  }) => planning.setDefaultsFrom(
    fromYearMonth,
    salaryCents: salaryCents,
    extraIncomeCents: extraIncomeCents,
    savingsGoalCents: savingsGoalCents,
    investmentCents: investmentCents,
  );

  Future<String> addIncome(
    String yearMonth,
    IncomeKind kind,
    int cents, {
    String description = '',
  }) {
    if (cents <= 0) throw ValidationError('Informe um valor maior que zero');
    return planning.addIncome(
      yearMonth: yearMonth,
      kind: kind,
      amountCents: cents,
      description: description,
      received: true,
    );
  }

  /// Remove um lançamento de renda (dá para desfazer com [restoreIncome]).
  Future<void> removeIncome(String id) => planning.deleteIncome(id);
  Future<void> restoreIncome(String id) => planning.restoreIncome(id);

  /// Remove um lançamento de investimento (dá para desfazer com [restoreInvestment]).
  Future<void> removeInvestment(String id) => planning.deleteInvestment(id);
  Future<void> restoreInvestment(String id) => planning.restoreInvestment(id);

  /// Registra um investimento **realizado** no mês.
  Future<String> registerInvestment(
    String yearMonth,
    int cents, {
    String description = '',
  }) {
    if (cents <= 0) throw ValidationError('Informe um valor maior que zero');
    return planning.addInvestment(
      yearMonth: yearMonth,
      realizedCents: cents,
      description: description,
    );
  }
}
