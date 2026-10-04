import 'enums.dart';

/// Estados de uma conta. O estado é **derivado** (DECISIONS D04), nunca armazenado.
enum BillStatus { planned, pending, partiallyPaid, paid, overdue, canceled }

class Payment {
  const Payment({required this.id, required this.billId, required this.amountCents, required this.paidAt, this.note = ''});
  final String id;
  final String billId;
  final int amountCents;
  final DateTime paidAt;
  final String note;
}

/// Janela padrão (dias) para uma conta prevista passar a "pendente" (DECISIONS D11).
const defaultPendingWindowDays = 30;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Conta (lançamento) com seus pagamentos. Entidade pura: sem Flutter nem banco.
class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.plannedCents,
    required this.dueDate,
    required this.categoryId,
    required this.expenseType,
    required this.createdAt,
    this.favorite = false,
    this.note = '',
    this.canceledAt,
    this.recurringId,
    this.payments = const [],
  });

  final String id;
  final String name;

  /// Valor previsto, em centavos.
  final int plannedCents;

  /// Data pura (sem hora).
  final DateTime dueDate;
  final String categoryId;
  final ExpenseType expenseType;
  final DateTime createdAt;
  final bool favorite;
  final String note;
  final DateTime? canceledAt;
  final String? recurringId;
  final List<Payment> payments;

  bool get isCanceled => canceledAt != null;
  bool get isRecurring => recurringId != null;

  /// Soma dos pagamentos.
  int get paidCents => payments.fold(0, (s, p) => s + p.amountCents);

  /// Quanto falta pagar (nunca negativo).
  int get remainingCents => plannedCents > paidCents ? plannedCents - paidCents : 0;

  /// Quanto foi pago além do previsto (nunca truncado, só registrado).
  int get excessCents => paidCents > plannedCents ? paidCents - plannedCents : 0;

  /// Fração paga entre 0 e 1. Conta de valor zero tem 0.
  double get paidFraction => plannedCents <= 0 ? 0 : (paidCents / plannedCents).clamp(0.0, 1.0);

  bool get isFullyPaid => plannedCents > 0 && paidCents >= plannedCents;

  /// Parcialmente paga: pagou algo, mas ainda falta (independe de estar vencida).
  bool get isPartiallyPaid => !isCanceled && paidCents > 0 && paidCents < plannedCents;

  /// Vencida: ainda há valor a pagar e o vencimento é anterior a hoje.
  /// Vencer **hoje** não é estar vencida.
  bool isOverdueOn(DateTime today) =>
      !isCanceled && remainingCents > 0 && dateOnly(dueDate).isBefore(dateOnly(today));

  /// Estado em [today], na ordem de DATA_MODEL: cancelada, paga, vencida,
  /// parcialmente paga, pendente (dentro da janela) e prevista.
  BillStatus statusOn(DateTime today, {int pendingWindowDays = defaultPendingWindowDays}) {
    if (isCanceled) return BillStatus.canceled;
    if (isFullyPaid) return BillStatus.paid;
    if (isOverdueOn(today)) return BillStatus.overdue;
    if (isPartiallyPaid) return BillStatus.partiallyPaid;
    final limit = dateOnly(today).add(Duration(days: pendingWindowDays));
    return dateOnly(dueDate).isAfter(limit) ? BillStatus.planned : BillStatus.pending;
  }

  Bill copyWith({List<Payment>? payments, bool? favorite}) => Bill(
        id: id,
        name: name,
        plannedCents: plannedCents,
        dueDate: dueDate,
        categoryId: categoryId,
        expenseType: expenseType,
        createdAt: createdAt,
        favorite: favorite ?? this.favorite,
        note: note,
        canceledAt: canceledAt,
        recurringId: recurringId,
        payments: payments ?? this.payments,
      );
}
