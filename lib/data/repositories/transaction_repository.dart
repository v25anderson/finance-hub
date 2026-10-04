import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../core/dates.dart';
import '../../domain/enums.dart';
import '../db/app_database.dart';
import 'repo_base.dart';

class TransactionRepository extends RepoBase {
  TransactionRepository(super.db);

  SimpleSelectStatement<$TransactionsTable, TransactionRow> _active() =>
      db.select(db.transactions)..where((t) => t.deletedAt.isNull());

  Future<TransactionRow?> getById(String id) =>
      (db.select(db.transactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  /// Lançamentos com vencimento no mês `yyyy-MM`, ordenados por data.
  Stream<List<TransactionRow>> watchByMonth(String yearMonth) {
    final r = monthRange(yearMonth);
    return (_active()
          ..where((t) => t.dueDate.isBiggerOrEqualValue(r.start) & t.dueDate.isSmallerThanValue(r.endExclusive))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate), (t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<TransactionRow>> getByMonth(String yearMonth) => watchByMonth(yearMonth).first;

  Future<String> create({
    required String name,
    required int plannedAmountCents,
    required DateTime dueDate,
    required String categoryId,
    ExpenseType expenseType = ExpenseType.variable,
    bool favorite = false,
    String note = '',
    String? recurringId,
    DateTime? occurrenceDate,
  }) async {
    if (name.trim().isEmpty) throw ValidationError('Nome é obrigatório');
    if (plannedAmountCents < 0) throw ValidationError('Valor não pode ser negativo');
    final id = newId();
    final t = now();
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          name: name.trim(),
          plannedAmountCents: plannedAmountCents,
          dueDate: isoDate(dueDate),
          categoryId: categoryId,
          expenseType: expenseType,
          favorite: Value(favorite),
          note: Value(note),
          recurringId: Value(recurringId),
          occurrenceDate: Value(occurrenceDate == null ? null : isoDate(occurrenceDate)),
        ));
    return id;
  }

  /// Atualiza campos informados. Editar uma ocorrência de recorrência a marca como `overridden`.
  Future<void> update(
    String id, {
    String? name,
    int? plannedAmountCents,
    DateTime? dueDate,
    String? categoryId,
    ExpenseType? expenseType,
    bool? favorite,
    String? note,
  }) async {
    final row = await getById(id);
    if (row == null) throw NotFoundError('transaction', id);
    if (name != null && name.trim().isEmpty) throw ValidationError('Nome é obrigatório');
    if (plannedAmountCents != null && plannedAmountCents < 0) throw ValidationError('Valor não pode ser negativo');
    final contentChanged = name != null || plannedAmountCents != null || dueDate != null || categoryId != null || expenseType != null;
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(TransactionsCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      plannedAmountCents: plannedAmountCents == null ? const Value.absent() : Value(plannedAmountCents),
      dueDate: dueDate == null ? const Value.absent() : Value(isoDate(dueDate)),
      categoryId: categoryId == null ? const Value.absent() : Value(categoryId),
      expenseType: expenseType == null ? const Value.absent() : Value(expenseType),
      favorite: favorite == null ? const Value.absent() : Value(favorite),
      note: note == null ? const Value.absent() : Value(note),
      overridden: contentChanged && row.recurringId != null ? const Value(true) : const Value.absent(),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Volta a ocorrência a "seguir a regra" (usado ao propagar edições "esta e as próximas").
  Future<void> clearOverridden(String id) =>
      (db.update(db.transactions)..where((t) => t.id.equals(id))).write(const TransactionsCompanion(overridden: Value(false)));

  /// Cancela (a conta continua no histórico, fora dos totais).
  Future<void> cancel(String id) async {
    final row = await getById(id);
    if (row == null) throw NotFoundError('transaction', id);
    final t = now();
    await (db.update(db.transactions)..where((x) => x.id.equals(id))).write(TransactionsCompanion(
      canceledAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Soft delete: pagamentos e anexos permanecem no banco (histórico nunca é apagado).
  Future<void> softDelete(String id) async {
    final row = await getById(id);
    if (row == null) throw NotFoundError('transaction', id);
    final t = now();
    await (db.update(db.transactions)..where((x) => x.id.equals(id))).write(TransactionsCompanion(
      deletedAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  Future<void> restore(String id) async {
    final row = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('transaction', id);
    await (db.update(db.transactions)..where((x) => x.id.equals(id))).write(TransactionsCompanion(
      deletedAt: const Value(null),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Cria uma nova entidade (novo id), sem vínculo de recorrência e sem pagamentos.
  Future<String> duplicate(String id, {String? name, DateTime? dueDate}) async {
    final row = await getById(id);
    if (row == null) throw NotFoundError('transaction', id);
    return create(
      name: name ?? '${row.name} (cópia)',
      plannedAmountCents: row.plannedAmountCents,
      dueDate: dueDate ?? parseIsoDate(row.dueDate),
      categoryId: row.categoryId,
      expenseType: row.expenseType,
      favorite: row.favorite,
      note: row.note,
    );
  }

  // ── Recorrência ───────────────────────────────────────────────

  /// Datas (ISO) de todas as ocorrências já criadas para a regra, **inclusive as excluídas**:
  /// uma ocorrência excluída não é recriada pela geração.
  Future<Set<String>> existingOccurrenceDates(String recurringId) async {
    final rows = await (db.select(db.transactions)..where((t) => t.recurringId.equals(recurringId))).get();
    return {for (final r in rows) if (r.occurrenceDate != null) r.occurrenceDate!};
  }

  /// Id determinístico: o mesmo (regra, data) gera o mesmo id em qualquer aparelho, então ocorrências
  /// geradas separadamente em dois aparelhos são o MESMO registro na sincronização.
  static String occurrenceId(String recurringId, DateTime date) =>
      const Uuid().v5(Namespace.url.value, 'finance-hub/occurrence/$recurringId/${isoDate(date)}');

  /// Insere ocorrências em lote. O índice único (regra, data) torna a operação idempotente:
  /// repetir não duplica.
  Future<void> insertOccurrences({
    required String recurringId,
    required String name,
    required int plannedAmountCents,
    required String categoryId,
    required ExpenseType expenseType,
    required bool favorite,
    required List<DateTime> dates,
  }) async {
    if (dates.isEmpty) return;
    final t = now();
    final device = await db.currentDeviceId();
    await db.batch((b) {
      b.insertAll(
        db.transactions,
        [
          for (final d in dates)
            TransactionsCompanion.insert(
              id: occurrenceId(recurringId, d),
              createdAt: t,
              updatedAt: t,
              deviceId: Value(device),
              name: name,
              plannedAmountCents: plannedAmountCents,
              dueDate: isoDate(d),
              categoryId: categoryId,
              expenseType: expenseType,
              favorite: Value(favorite),
              recurringId: Value(recurringId),
              occurrenceDate: Value(isoDate(d)),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Ocorrências ativas da regra com `occurrenceDate >= from` (ISO), em ordem.
  Future<List<TransactionRow>> activeOccurrencesFrom(String recurringId, String from) =>
      (db.select(db.transactions)
            ..where((t) => t.recurringId.equals(recurringId) & t.deletedAt.isNull() & t.occurrenceDate.isBiggerOrEqualValue(from))
            ..orderBy([(t) => OrderingTerm.asc(t.occurrenceDate)]))
          .get();

  /// Quantidade de pagamentos ativos de uma conta.
  Future<int> paymentCount(String transactionId) async =>
      (await (db.select(db.payments)..where((p) => p.transactionId.equals(transactionId) & p.deletedAt.isNull())).get()).length;

  // ── Pagamentos ────────────────────────────────────────────────

  Stream<List<PaymentRow>> watchPayments(String transactionId) => (db.select(db.payments)
        ..where((p) => p.transactionId.equals(transactionId) & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.asc(p.paidAt)]))
      .watch();

  Future<List<PaymentRow>> getPayments(String transactionId) => watchPayments(transactionId).first;

  /// Todos os pagamentos ativos de lançamentos ativos de um mês (para totais do dashboard).
  Future<List<PaymentRow>> getPaymentsForMonth(String yearMonth) async {
    final r = monthRange(yearMonth);
    final q = db.select(db.payments).join([
      innerJoin(db.transactions, db.transactions.id.equalsExp(db.payments.transactionId)),
    ])
      ..where(db.payments.deletedAt.isNull() &
          db.transactions.deletedAt.isNull() &
          db.transactions.dueDate.isBiggerOrEqualValue(r.start) &
          db.transactions.dueDate.isSmallerThanValue(r.endExclusive));
    return (await q.get()).map((row) => row.readTable(db.payments)).toList();
  }

  /// Registra um pagamento (parcial ou total). Pagamentos acima do previsto são aceitos
  /// e ficam registrados como excedente; nada é truncado.
  Future<String> addPayment({
    required String transactionId,
    required int amountCents,
    DateTime? paidAt,
    String note = '',
  }) async {
    if (amountCents <= 0) throw ValidationError('Valor do pagamento deve ser maior que zero');
    final tx = await getById(transactionId);
    if (tx == null) throw NotFoundError('transaction', transactionId);
    if (tx.canceledAt != null) throw ValidationError('Conta cancelada não aceita pagamento');
    final id = newId();
    final t = now();
    await db.into(db.payments).insert(PaymentsCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          transactionId: transactionId,
          amountCents: amountCents,
          paidAt: (paidAt ?? t).toUtc(),
          note: Value(note),
        ));
    return id;
  }

  Future<void> deletePayment(String paymentId) async {
    final row = await (db.select(db.payments)..where((p) => p.id.equals(paymentId) & p.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('payment', paymentId);
    final t = now();
    await (db.update(db.payments)..where((p) => p.id.equals(paymentId))).write(PaymentsCompanion(
      deletedAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }
}
