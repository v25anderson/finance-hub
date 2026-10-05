import '../data/repositories/bill_repository.dart';
import '../data/repositories/repo_base.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/enums.dart';
import '../domain/value_range.dart';

/// Casos de uso de contas e pagamentos. A UI só fala com esta classe.
class BillService {
  BillService({required this.bills, required this.transactions, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final BillRepository bills;
  final TransactionRepository transactions;
  final DateTime Function() _clock;

  Future<String> create({
    required String name,
    required int plannedCents,
    required DateTime dueDate,
    required String categoryId,
    required ExpenseType expenseType,
    bool favorite = false,
    String note = '',
    ValueRange? range,
  }) async {
    if (plannedCents <= 0) throw ValidationError('Informe um valor maior que zero');
    final effective = expenseType == ExpenseType.variable ? range : null; // faixa só existe em gasto variável
    checkRange(effective, plannedCents);
    return transactions.create(
      name: name,
      plannedAmountCents: plannedCents,
      dueDate: dueDate,
      categoryId: categoryId,
      expenseType: expenseType,
      favorite: favorite,
      note: note,
      range: effective,
    );
  }

  /// O valor esperado precisa estar dentro da faixa informada.
  static void checkRange(ValueRange? range, int plannedCents) {
    if (range == null) return;
    if (!range.isValid) throw ValidationError('Faixa de valor inválida: o mínimo deve ser maior que zero e o máximo não pode ser menor que o mínimo');
    if (!range.contains(plannedCents)) throw ValidationError('O valor esperado deve estar dentro da faixa');
  }

  Future<void> update(
    String id, {
    String? name,
    int? plannedCents,
    DateTime? dueDate,
    String? categoryId,
    ExpenseType? expenseType,
    bool? favorite,
    String? note,
    ValueRange? range,
    bool clearRange = false,
  }) async {
    if (plannedCents != null && plannedCents <= 0) throw ValidationError('Informe um valor maior que zero');
    if (range != null) {
      final current = await bills.getBill(id);
      if (current == null) throw NotFoundError('bill', id);
      if ((expenseType ?? current.expenseType) != ExpenseType.variable) throw ValidationError('Faixa de valor só vale para gasto variável');
      checkRange(range, plannedCents ?? current.plannedCents);
    }
    return transactions.update(
      id,
      name: name,
      plannedAmountCents: plannedCents,
      dueDate: dueDate,
      categoryId: categoryId,
      expenseType: expenseType,
      favorite: favorite,
      note: note,
      range: range,
      // deixar de ser variável apaga a faixa junto
      clearRange: clearRange || (expenseType != null && expenseType != ExpenseType.variable),
    );
  }

  Future<void> toggleFavorite(String id) async {
    final bill = await bills.getBill(id);
    if (bill == null) throw NotFoundError('bill', id);
    await transactions.update(id, favorite: !bill.favorite);
  }

  Future<String> duplicate(String id, {String? name, DateTime? dueDate}) =>
      transactions.duplicate(id, name: name, dueDate: dueDate);

  /// Exclusão simples (soft delete). A exclusão de recorrências entra na Fase 5.
  Future<void> delete(String id) => transactions.softDelete(id);

  Future<void> restore(String id) => transactions.restore(id);

  /// Registra um pagamento parcial (ou qualquer valor). Vários são permitidos.
  Future<String> registerPayment(String billId, int amountCents, {DateTime? paidAt, String note = ''}) =>
      transactions.addPayment(transactionId: billId, amountCents: amountCents, paidAt: paidAt ?? _clock(), note: note);

  /// "Marcar como pago": registra o **valor restante** na data/hora informada.
  /// O histórico anterior é mantido; nada é apagado.
  Future<String> markAsPaid(String billId, {DateTime? paidAt, String note = ''}) async {
    final bill = await bills.getBill(billId);
    if (bill == null) throw NotFoundError('bill', billId);
    if (bill.isCanceled) throw ValidationError('Conta cancelada não pode ser paga');
    if (bill.remainingCents <= 0) throw ValidationError('Esta conta já está quitada');
    return registerPayment(billId, bill.remainingCents, paidAt: paidAt, note: note);
  }

  Future<void> deletePayment(String paymentId) => transactions.deletePayment(paymentId);
  Future<void> restorePayment(String paymentId) => transactions.restorePayment(paymentId);

  /// "Desmarcar como pago": remove TODOS os pagamentos da conta (exclusão lógica) e devolve os ids, para poder desfazer.
  /// A conta volta ao estado derivado de antes do pagamento (pendente, vencida ou prevista).
  Future<List<String>> removeAllPayments(String billId) async {
    final bill = await bills.getBill(billId);
    if (bill == null) throw NotFoundError('bill', billId);
    final ids = [for (final p in bill.payments) p.id];
    for (final id in ids) {
      await transactions.deletePayment(id);
    }
    return ids;
  }

  /// Desfaz [removeAllPayments] (ou a exclusão de um pagamento).
  Future<void> restorePayments(List<String> ids) async {
    for (final id in ids) {
      await transactions.restorePayment(id);
    }
  }
}
