import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../domain/bill.dart';
import '../../domain/value_range.dart';
import '../db/app_database.dart';
import 'repo_base.dart';

/// Leitura de contas mapeadas para o domínio (a UI nunca vê as linhas do Drift).
class BillRepository extends RepoBase {
  BillRepository(super.db);

  /// Reemite quando `transactions` ou `payments` mudam.
  Stream<void> _changes() => db.customSelect('SELECT 1', readsFrom: {db.transactions, db.payments}).watch();

  Stream<List<Bill>> watchMonth(String yearMonth) => _changes().asyncMap((_) => getMonth(yearMonth));

  Stream<Bill?> watchBill(String id) => _changes().asyncMap((_) => getBill(id));

  /// Contas ainda a pagar com vencimento até hoje + [windowDays] (inclui vencidas de qualquer mês).
  /// Base dos alertas de vencimento, que independem do mês exibido.
  Stream<List<Bill>> watchOpenBills(DateTime today, {int windowDays = 30}) =>
      _changes().asyncMap((_) => getOpenBills(today, windowDays: windowDays));

  Future<List<Bill>> getOpenBills(DateTime today, {int windowDays = 30}) async {
    final limit = isoDate(dateOnly(today).add(Duration(days: windowDays)));
    final txs = await (db.select(db.transactions)
          ..where((t) => t.deletedAt.isNull() & t.canceledAt.isNull() & t.dueDate.isSmallerOrEqualValue(limit))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
    final bills = await _withPayments(txs);
    return bills.where((b) => b.remainingCents > 0).toList();
  }

  Future<List<Bill>> getMonth(String yearMonth) async {
    final r = monthRange(yearMonth);
    final txs = await (db.select(db.transactions)
          ..where((t) =>
              t.deletedAt.isNull() & t.dueDate.isBiggerOrEqualValue(r.start) & t.dueDate.isSmallerThanValue(r.endExclusive))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate), (t) => OrderingTerm.asc(t.name)]))
        .get();
    return _withPayments(txs);
  }

  /// Ocorrências ativas de uma recorrência, por vencimento (base do histórico de valores).
  Stream<List<Bill>> watchOccurrences(String recurringId) => _changes().asyncMap((_) => getOccurrences(recurringId));

  Future<List<Bill>> getOccurrences(String recurringId) async {
    final txs = await (db.select(db.transactions)
          ..where((t) => t.recurringId.equals(recurringId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
    return _withPayments(txs);
  }

  Future<Bill?> getBill(String id) async {
    final tx = await (db.select(db.transactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (tx == null) return null;
    return (await _withPayments([tx])).single;
  }

  Future<List<Bill>> _withPayments(List<TransactionRow> txs) async {
    if (txs.isEmpty) return const [];
    final ids = txs.map((t) => t.id).toList();
    final pays = await (db.select(db.payments)
          ..where((p) => p.transactionId.isIn(ids) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.paidAt)]))
        .get();
    final byBill = <String, List<Payment>>{};
    for (final p in pays) {
      byBill.putIfAbsent(p.transactionId, () => []).add(Payment(
            id: p.id,
            billId: p.transactionId,
            amountCents: p.amountCents,
            paidAt: p.paidAt,
            note: p.note,
          ));
    }
    return [for (final t in txs) _toBill(t, byBill[t.id] ?? const [])];
  }

  Bill _toBill(TransactionRow t, List<Payment> payments) => Bill(
        id: t.id,
        name: t.name,
        plannedCents: t.plannedAmountCents,
        dueDate: parseIsoDate(t.dueDate),
        categoryId: t.categoryId,
        expenseType: t.expenseType,
        createdAt: t.createdAt,
        favorite: t.favorite,
        note: t.note,
        canceledAt: t.canceledAt,
        recurringId: t.recurringId,
        occurrenceDate: t.occurrenceDate == null ? null : parseIsoDate(t.occurrenceDate!),
        range: (t.plannedMinCents == null || t.plannedMaxCents == null) ? null : ValueRange(t.plannedMinCents!, t.plannedMaxCents!),
        payments: payments,
      );
}
