import 'dart:async';

import '../core/dates.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/recurring_repository.dart';
import '../data/repositories/repo_base.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/bill.dart';
import '../domain/enums.dart';
import '../domain/recurrence.dart';

/// Recorrências: gera ocorrências (materializadas, D05), edita e exclui por escopo.
///
/// Garantias:
/// - a geração é idempotente e nunca recria uma ocorrência excluída;
/// - ocorrências passadas e com pagamentos nunca são apagadas por exclusões em lote;
/// - mudar o valor "daqui para frente" não altera ocorrências já geradas que foram editadas à mão
///   ou que já têm pagamentos.
class RecurrenceService {
  RecurrenceService({
    required this.rules,
    required this.transactions,
    required this.bills,
    DateTime Function()? clock,
    this.horizonMonths = 12,
  }) : _clock = clock ?? DateTime.now;

  final RecurringRepository rules;
  final TransactionRepository transactions;
  final BillRepository bills;
  final DateTime Function() _clock;

  /// Quantos meses à frente de hoje sempre ficam gerados.
  final int horizonMonths;

  Future<void> _queue = Future.value();

  DateTime get _today => dateOnly(_clock());

  /// Serializa as gerações para evitar trabalho duplicado concorrente.
  Future<T> _serial<T>(Future<T> Function() job) {
    final c = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        c.complete(await job());
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    return c.future;
  }

  /// Cria a regra e gera as ocorrências até o horizonte. Retorna o id da regra.
  Future<String> createRecurring({
    required String name,
    required int amountCents,
    required DateTime firstDue,
    required String categoryId,
    required ExpenseType expenseType,
    required Frequency frequency,
    int interval = 1,
    DateTime? end,
    bool favorite = false,
  }) async {
    final id = await rules.create(
      name: name,
      baseAmountCents: amountCents,
      categoryId: categoryId,
      expenseType: expenseType,
      frequency: frequency,
      start: dateOnly(firstDue),
      interval: interval,
      end: end == null ? null : dateOnly(end),
      favorite: favorite,
    );
    await ensureThrough(_horizon());
    return id;
  }

  DateTime _horizon() => DateTime(_today.year, _today.month + horizonMonths + 1, 0);

  /// Garante que todas as regras ativas tenham ocorrências até [until] (e até o horizonte padrão).
  /// Retorna quantas ocorrências foram criadas.
  Future<int> ensureThrough(DateTime until) => _serial(() async {
        final limit = dateOnly(until).isAfter(_horizon()) ? dateOnly(until) : _horizon();
        var created = 0;
        for (final rule in await rules.getActiveRules()) {
          final wanted = occurrenceDates(rule, from: rule.start, to: limit);
          final have = await transactions.existingOccurrenceDates(rule.id);
          final missing = [for (final d in wanted) if (!have.contains(isoDate(d))) d];
          if (missing.isEmpty) continue;
          await transactions.insertOccurrences(
            recurringId: rule.id,
            name: rule.name,
            plannedAmountCents: rule.baseAmountCents,
            categoryId: rule.categoryId,
            expenseType: rule.expenseType,
            favorite: rule.favorite,
            dates: missing,
          );
          created += missing.length;
        }
        return created;
      });

  /// Garante as ocorrências até o fim do mês `yyyy-MM`.
  Future<int> ensureMonth(String yearMonth) => ensureThrough(parseIsoDate(monthRange(yearMonth).endExclusive).subtract(const Duration(days: 1)));

  // ── Edição ────────────────────────────────────────────────────

  /// Edita uma ocorrência.
  /// - [EditScope.thisOnly]: só esta (marcada como editada à mão).
  /// - [EditScope.thisAndFollowing]: esta e as próximas. Atualiza a regra (novas ocorrências usarão
  ///   os novos dados) e as próximas já geradas que não foram editadas à mão e não têm pagamentos.
  ///   Não permite mudar o vencimento (use "somente esta").
  Future<int> editOccurrence(
    String billId,
    EditScope scope, {
    String? name,
    int? plannedCents,
    String? categoryId,
    ExpenseType? expenseType,
    bool? favorite,
    String? note,
    DateTime? dueDate,
  }) async {
    final bill = await bills.getBill(billId);
    if (bill == null) throw NotFoundError('bill', billId);
    if (plannedCents != null && plannedCents <= 0) throw ValidationError('Informe um valor maior que zero');
    final follows = scope == EditScope.thisAndFollowing && bill.recurringId != null;
    if (follows && dueDate != null && dateOnly(dueDate) != dateOnly(bill.dueDate)) {
      throw ValidationError('Para mudar o vencimento, edite somente esta ocorrência.');
    }

    await transactions.update(
      billId,
      name: name,
      plannedAmountCents: plannedCents,
      categoryId: categoryId,
      expenseType: expenseType,
      favorite: favorite,
      note: note,
      dueDate: dueDate,
    );
    if (!follows) return 0;

    final ruleId = bill.recurringId!;
    await transactions.clearOverridden(billId); // esta também passa a seguir a regra
    await rules.updateBase(ruleId, name: name, baseAmountCents: plannedCents, categoryId: categoryId, expenseType: expenseType, favorite: favorite);

    var updated = 0;
    final from = bill.occurrenceDate ?? bill.dueDate;
    for (final row in await transactions.activeOccurrencesFrom(ruleId, isoDate(from))) {
      if (row.id == billId || row.overridden || row.canceledAt != null) continue;
      if (await transactions.paymentCount(row.id) > 0) continue;
      await transactions.update(
        row.id,
        name: name,
        plannedAmountCents: plannedCents,
        categoryId: categoryId,
        expenseType: expenseType,
        favorite: favorite,
      );
      // Seguir a regra não é "edição manual": mantém a ocorrência livre para futuras mudanças em lote.
      await transactions.clearOverridden(row.id);
      updated++;
    }
    return updated;
  }

  // ── Exclusão ──────────────────────────────────────────────────

  /// Exclui por escopo. **Nunca** apaga em silêncio o que já aconteceu:
  /// - [DeleteScope.thisOnly]: só esta (soft delete; não é recriada).
  /// - [DeleteScope.thisAndFollowing]: esta e as próximas sem pagamentos; a regra termina antes desta.
  /// - [DeleteScope.all]: todas as futuras sem pagamentos e encerra a regra; ocorrências passadas
  ///   e as com pagamentos permanecem como histórico.
  Future<RecurrenceDeleteResult> deleteOccurrence(String billId, DeleteScope scope) async {
    final bill = await bills.getBill(billId);
    if (bill == null) throw NotFoundError('bill', billId);
    final ruleId = bill.recurringId;
    if (ruleId == null || scope == DeleteScope.thisOnly) {
      await transactions.softDelete(billId);
      return const RecurrenceDeleteResult(deleted: 1, keptWithPayments: 0, keptPast: 0);
    }

    final today = _today;
    var deleted = 0, keptPaid = 0, keptPast = 0;

    if (scope == DeleteScope.thisAndFollowing) {
      final from = bill.occurrenceDate ?? bill.dueDate;
      final all = await transactions.activeOccurrencesFrom(ruleId, isoDate(from));
      for (final row in all) {
        final isSelected = row.id == billId;
        if (!isSelected && await transactions.paymentCount(row.id) > 0) {
          keptPaid++;
          continue;
        }
        await transactions.softDelete(row.id);
        deleted++;
      }
      final newEnd = dateOnly(from).subtract(const Duration(days: 1));
      final rule = await rules.getRule(ruleId);
      if (rule != null) {
        if (newEnd.isBefore(rule.start)) {
          await rules.softDelete(ruleId);
        } else {
          await rules.setEnd(ruleId, newEnd);
        }
      }
      return RecurrenceDeleteResult(deleted: deleted, keptWithPayments: keptPaid, keptPast: 0);
    }

    // all
    final all = await transactions.activeOccurrencesFrom(ruleId, '0000-01-01');
    for (final row in all) {
      final due = parseIsoDate(row.dueDate);
      final isSelected = row.id == billId;
      if (due.isBefore(today) && !isSelected) {
        keptPast++;
        continue;
      }
      if (!isSelected && await transactions.paymentCount(row.id) > 0) {
        keptPaid++;
        continue;
      }
      await transactions.softDelete(row.id);
      deleted++;
    }
    if (await rules.getRule(ruleId) != null) await rules.softDelete(ruleId);
    return RecurrenceDeleteResult(deleted: deleted, keptWithPayments: keptPaid, keptPast: keptPast);
  }
}
