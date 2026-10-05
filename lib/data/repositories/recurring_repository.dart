import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../domain/enums.dart';
import '../../domain/recurrence.dart';
import '../../domain/value_range.dart';
import '../db/app_database.dart';
import 'repo_base.dart';

/// Regras de recorrência (RecurringTransaction). Retorna entidades de domínio.
class RecurringRepository extends RepoBase {
  RecurringRepository(super.db);

  Future<String> create({
    required String name,
    required int baseAmountCents,
    required String categoryId,
    required ExpenseType expenseType,
    required Frequency frequency,
    required DateTime start,
    int interval = 1,
    DateTime? end,
    bool favorite = false,
    ValueRange? range,
  }) async {
    if (range != null && !range.isValid) throw ValidationError('Faixa de valor inválida');
    if (name.trim().isEmpty) throw ValidationError('Nome é obrigatório');
    if (baseAmountCents <= 0) throw ValidationError('Informe um valor maior que zero');
    if (interval < 1 || interval > 999) throw ValidationError('Intervalo inválido');
    if (start.year < 2000) throw ValidationError('Data inicial inválida');
    if (end != null && end.isBefore(start)) throw ValidationError('A data final deve ser depois da inicial');
    final id = newId();
    final t = now();
    await db.into(db.recurringTransactions).insert(RecurringTransactionsCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          name: name.trim(),
          baseAmountCents: baseAmountCents,
          categoryId: categoryId,
          expenseType: expenseType,
          frequency: frequency,
          intervalCount: Value(interval),
          dueDay: start.day,
          startDate: isoDate(start),
          endDate: Value(end == null ? null : isoDate(end)),
          favorite: Value(favorite),
          baseMinCents: Value(range?.minCents),
          baseMaxCents: Value(range?.maxCents),
        ));
    return id;
  }

  RecurrenceRule _map(RecurringRow r) => RecurrenceRule(
        id: r.id,
        name: r.name,
        baseAmountCents: r.baseAmountCents,
        categoryId: r.categoryId,
        expenseType: r.expenseType,
        frequency: r.frequency,
        interval: r.intervalCount,
        start: parseIsoDate(r.startDate),
        end: r.endDate == null ? null : parseIsoDate(r.endDate!),
        favorite: r.favorite,
        range: (r.baseMinCents == null || r.baseMaxCents == null) ? null : ValueRange(r.baseMinCents!, r.baseMaxCents!),
      );

  /// Regra ativa (não excluída). Nulo se não existe ou foi excluída.
  Future<RecurrenceRule?> getRule(String id) async {
    final r = await (db.select(db.recurringTransactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Inclui regras excluídas (para mostrar o histórico de ocorrências que permaneceram).
  Future<RecurrenceRule?> getRuleIncludingDeleted(String id) async {
    final r = await (db.select(db.recurringTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  Stream<RecurrenceRule?> watchRule(String id) =>
      (db.select(db.recurringTransactions)..where((t) => t.id.equals(id))).watchSingleOrNull().map((r) => r == null ? null : _map(r));

  Future<List<RecurrenceRule>> getActiveRules() async {
    final rows = await (db.select(db.recurringTransactions)..where((t) => t.deletedAt.isNull())).get();
    return rows.map(_map).toList();
  }

  /// Altera os dados-base usados nas **próximas** ocorrências geradas.
  Future<void> updateBase(String id, {String? name, int? baseAmountCents, String? categoryId, ExpenseType? expenseType, bool? favorite, ValueRange? range, bool clearRange = false}) async {
    if (range != null && !range.isValid) throw ValidationError('Faixa de valor inválida');
    final row = await (db.select(db.recurringTransactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('recurring', id);
    if (baseAmountCents != null && baseAmountCents <= 0) throw ValidationError('Informe um valor maior que zero');
    await (db.update(db.recurringTransactions)..where((t) => t.id.equals(id))).write(RecurringTransactionsCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      baseAmountCents: baseAmountCents == null ? const Value.absent() : Value(baseAmountCents),
      categoryId: categoryId == null ? const Value.absent() : Value(categoryId),
      expenseType: expenseType == null ? const Value.absent() : Value(expenseType),
      favorite: favorite == null ? const Value.absent() : Value(favorite),
      baseMinCents: clearRange ? const Value(null) : (range == null ? const Value.absent() : Value(range.minCents)),
      baseMaxCents: clearRange ? const Value(null) : (range == null ? const Value.absent() : Value(range.maxCents)),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Define a data final (inclusive). `null` remove o fim.
  Future<void> setEnd(String id, DateTime? end) async {
    final row = await (db.select(db.recurringTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('recurring', id);
    await (db.update(db.recurringTransactions)..where((t) => t.id.equals(id))).write(RecurringTransactionsCompanion(
      endDate: Value(end == null ? null : isoDate(end)),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Soft delete da regra: nenhuma ocorrência nova é gerada; as existentes permanecem.
  Future<void> softDelete(String id) async {
    final row = await (db.select(db.recurringTransactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('recurring', id);
    final t = now();
    await (db.update(db.recurringTransactions)..where((x) => x.id.equals(id))).write(RecurringTransactionsCompanion(
      deletedAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }
}
