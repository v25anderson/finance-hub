import '../data/repositories/planning_repository.dart';
import '../data/repositories/repo_base.dart';
import '../domain/enums.dart';

/// Renda e investimentos do mês. A edição completa do planejamento entra na Fase 7.
class IncomeInvestmentService {
  IncomeInvestmentService(this.planning);
  final PlanningRepository planning;

  /// Padrões globais (aplicam-se a todos os meses sem personalização).
  Future<void> setDefaults({int? salaryCents, int? extraIncomeCents, int? investmentCents}) =>
      planning.updatePlanning(salaryCents: salaryCents, extraIncomeCents: extraIncomeCents, investmentCents: investmentCents);

  Future<String> addIncome(String yearMonth, IncomeKind kind, int cents, {String description = ''}) {
    if (cents <= 0) throw ValidationError('Informe um valor maior que zero');
    return planning.addIncome(yearMonth: yearMonth, kind: kind, amountCents: cents, description: description, received: true);
  }

  /// Registra um investimento **realizado** no mês.
  Future<String> registerInvestment(String yearMonth, int cents, {String description = ''}) {
    if (cents <= 0) throw ValidationError('Informe um valor maior que zero');
    return planning.addInvestment(yearMonth: yearMonth, realizedCents: cents, description: description);
  }
}
