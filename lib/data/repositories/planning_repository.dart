import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/app_database.dart';
import 'repo_base.dart';

class PlanningRepository extends RepoBase {
  PlanningRepository(super.db);

  // ── Padrões globais ───────────────────────────────────────────

  Stream<PlanningRow> watchPlanning() =>
      (db.select(db.plannings)..where((p) => p.id.equals(planningId))).watchSingle();

  Future<PlanningRow> getPlanning() => watchPlanning().first;

  Future<void> updatePlanning({
    int? salaryCents,
    int? extraIncomeCents,
    int? savingsGoalCents,
    int? investmentCents,
  }) async {
    for (final v in [salaryCents, extraIncomeCents, savingsGoalCents, investmentCents]) {
      if (v != null && v < 0) throw ValidationError('Valor não pode ser negativo');
    }
    final row = await getPlanning();
    await (db.update(db.plannings)..where((p) => p.id.equals(planningId))).write(PlanningsCompanion(
      defaultSalaryCents: salaryCents == null ? const Value.absent() : Value(salaryCents),
      defaultExtraIncomeCents: extraIncomeCents == null ? const Value.absent() : Value(extraIncomeCents),
      defaultSavingsGoalCents: savingsGoalCents == null ? const Value.absent() : Value(savingsGoalCents),
      defaultInvestmentCents: investmentCents == null ? const Value.absent() : Value(investmentCents),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  // ── Configuração por mês ──────────────────────────────────────

  Future<MonthConfigRow?> getMonthConfig(String yearMonth) =>
      (db.select(db.monthConfigurations)..where((m) => m.yearMonth.equals(yearMonth))).getSingleOrNull();

  Stream<MonthConfigRow?> watchMonthConfig(String yearMonth) =>
      (db.select(db.monthConfigurations)..where((m) => m.yearMonth.equals(yearMonth))).watchSingleOrNull();

  /// Define os overrides do mês. Os valores nulos significam "herdar o padrão".
  /// Somente o mês informado é afetado.
  Future<void> setMonthConfig(
    String yearMonth, {
    int? salaryCents,
    int? extraIncomeCents,
    int? savingsGoalCents,
    int? investmentCents,
  }) async {
    for (final v in [salaryCents, extraIncomeCents, savingsGoalCents, investmentCents]) {
      if (v != null && v < 0) throw ValidationError('Valor não pode ser negativo');
    }
    final existing = await getMonthConfig(yearMonth);
    final t = now();
    final device = await db.currentDeviceId();
    if (existing == null) {
      await db.into(db.monthConfigurations).insert(MonthConfigurationsCompanion.insert(
            id: newId(),
            createdAt: t,
            updatedAt: t,
            deviceId: Value(device),
            yearMonth: yearMonth,
            salaryCents: Value(salaryCents),
            extraIncomeCents: Value(extraIncomeCents),
            savingsGoalCents: Value(savingsGoalCents),
            investmentCents: Value(investmentCents),
          ));
    } else {
      await (db.update(db.monthConfigurations)..where((m) => m.id.equals(existing.id))).write(MonthConfigurationsCompanion(
        salaryCents: Value(salaryCents),
        extraIncomeCents: Value(extraIncomeCents),
        savingsGoalCents: Value(savingsGoalCents),
        investmentCents: Value(investmentCents),
        deletedAt: const Value(null),
        updatedAt: Value(t),
        version: Value(existing.version + 1),
        deviceId: Value(device),
      ));
    }
  }

  /// Volta o mês a herdar todos os padrões (desmarca "Personalizar este mês").
  Future<void> clearMonthConfig(String yearMonth) async {
    if (await getMonthConfig(yearMonth) != null) await setMonthConfig(yearMonth);
  }

  // ── Rendas ────────────────────────────────────────────────────

  Stream<List<IncomeRow>> watchIncomes(String yearMonth) => (db.select(db.incomes)
        ..where((i) => i.yearMonth.equals(yearMonth) & i.deletedAt.isNull())
        ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
      .watch();

  Future<String> addIncome({
    required String yearMonth,
    required IncomeKind kind,
    required int amountCents,
    String description = '',
    bool received = false,
  }) async {
    if (amountCents < 0) throw ValidationError('Valor não pode ser negativo');
    final id = newId();
    final t = now();
    await db.into(db.incomes).insert(IncomesCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          yearMonth: yearMonth,
          kind: kind,
          amountCents: amountCents,
          description: Value(description),
          received: Value(received),
        ));
    return id;
  }

  Future<void> deleteIncome(String id) async {
    final row = await (db.select(db.incomes)..where((i) => i.id.equals(id) & i.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('income', id);
    final t = now();
    await (db.update(db.incomes)..where((i) => i.id.equals(id))).write(IncomesCompanion(
      deletedAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  // ── Investimentos ─────────────────────────────────────────────

  Stream<List<InvestmentRow>> watchInvestments(String yearMonth) => (db.select(db.investments)
        ..where((i) => i.yearMonth.equals(yearMonth) & i.deletedAt.isNull())
        ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
      .watch();

  Future<String> addInvestment({
    required String yearMonth,
    int plannedCents = 0,
    int realizedCents = 0,
    String description = '',
  }) async {
    if (plannedCents < 0 || realizedCents < 0) throw ValidationError('Valor não pode ser negativo');
    final id = newId();
    final t = now();
    await db.into(db.investments).insert(InvestmentsCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          yearMonth: yearMonth,
          plannedCents: Value(plannedCents),
          realizedCents: Value(realizedCents),
          description: Value(description),
        ));
    return id;
  }

  Future<void> setInvestmentRealized(String id, int realizedCents) async {
    if (realizedCents < 0) throw ValidationError('Valor não pode ser negativo');
    final row = await (db.select(db.investments)..where((i) => i.id.equals(id) & i.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('investment', id);
    await (db.update(db.investments)..where((i) => i.id.equals(id))).write(InvestmentsCompanion(
      realizedCents: Value(realizedCents),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }
}
