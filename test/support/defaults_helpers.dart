import 'package:finance_hub/data/repositories/planning_repository.dart';

extension DefaultsTestX on PlanningRepository {
  /// Define os padrões a partir de [ym], com zero nos campos não informados.
  Future<void> defaultsFrom(String ym, {int salary = 0, int extra = 0, int savings = 0, int investment = 0}) =>
      setDefaultsFrom(ym, salaryCents: salary, extraIncomeCents: extra, savingsGoalCents: savings, investmentCents: investment);
}
