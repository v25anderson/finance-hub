import 'bill.dart';

class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.plannedCents, required this.fraction});
  final String categoryId;
  final int plannedCents;

  /// Parte do total do mês (0 a 1).
  final double fraction;
}

/// Totais de um mês. Contas canceladas ficam de fora de todos os valores.
///
/// - `totalCents`: soma dos valores previstos.
/// - `paidCents`: pago **dentro do previsto** (por conta, no máximo o previsto).
/// - `pendingCents`: soma do que ainda falta pagar.
/// - `excessCents`: pago além do previsto (separado, nunca descartado).
/// Invariante: `paidCents + pendingCents == totalCents`.
class MonthSummary {
  const MonthSummary({
    required this.totalCents,
    required this.paidCents,
    required this.pendingCents,
    required this.excessCents,
    required this.paidBills,
    required this.pendingBills,
    required this.overdueBills,
    required this.partiallyPaidBills,
    required this.futureBills,
    required this.byCategory,
    required this.activeCount,
    required this.rangeMinCents,
    required this.rangeMaxCents,
    required this.hasRange,
  });

  final int totalCents;
  final int paidCents;
  final int pendingCents;
  final int excessCents;

  /// Totalmente pagas.
  final List<Bill> paidBills;

  /// Com valor a pagar e não vencidas (inclui previstas e parcialmente pagas no prazo).
  final List<Bill> pendingBills;
  final List<Bill> overdueBills;

  /// Pagou algo e ainda falta (pode estar vencida).
  final List<Bill> partiallyPaidBills;

  /// Vencimento além da janela de "pendente" (estado "prevista").
  final List<Bill> futureBills;
  final List<CategoryTotal> byCategory;
  final int activeCount;

  /// Faixa **informada** pelo usuário para o total do mês: contas com faixa entram com o mínimo e o máximo dela,
  /// as demais com o valor previsto. Só existe quando alguma conta do mês tem faixa ([hasRange]); não é previsão do app.
  final int rangeMinCents;
  final int rangeMaxCents;
  final bool hasRange;

  /// Saída de caixa real: pago dentro do previsto + excedente.
  int get paidCashCents => paidCents + excessCents;

  /// Fração quitada (0 a 1). Mês sem gastos → 0.
  double get paidFraction => totalCents == 0 ? 0 : paidCents / totalCents;

  /// Fração restante (0 a 1). Mês sem gastos → 0.
  double get remainingFraction => totalCents == 0 ? 0 : pendingCents / totalCents;

  bool get isEmpty => activeCount == 0;
}

MonthSummary computeMonthSummary(List<Bill> bills, DateTime today, {int pendingWindowDays = defaultPendingWindowDays}) {
  final active = bills.where((b) => !b.isCanceled).toList();
  var total = 0, paid = 0, pending = 0, excess = 0, rangeMin = 0, rangeMax = 0;
  var anyRange = false;
  final paidBills = <Bill>[], pendingBills = <Bill>[], overdueBills = <Bill>[], partial = <Bill>[], future = <Bill>[];
  final perCategory = <String, int>{};

  for (final b in active) {
    total += b.plannedCents;
    rangeMin += b.range?.minCents ?? b.plannedCents;
    rangeMax += b.range?.maxCents ?? b.plannedCents;
    if (b.hasRange) anyRange = true;
    paid += b.paidCents < b.plannedCents ? b.paidCents : b.plannedCents;
    pending += b.remainingCents;
    excess += b.excessCents;
    perCategory[b.categoryId] = (perCategory[b.categoryId] ?? 0) + b.plannedCents;

    final status = b.statusOn(today, pendingWindowDays: pendingWindowDays);
    if (status == BillStatus.paid) paidBills.add(b);
    if (status == BillStatus.overdue) overdueBills.add(b);
    if (b.remainingCents > 0 && status != BillStatus.overdue) pendingBills.add(b);
    if (b.isPartiallyPaid) partial.add(b);
    if (status == BillStatus.planned) future.add(b);
  }

  final categories = [
    for (final e in perCategory.entries)
      CategoryTotal(categoryId: e.key, plannedCents: e.value, fraction: total == 0 ? 0 : e.value / total),
  ]..sort((a, b) {
      final c = b.plannedCents.compareTo(a.plannedCents);
      return c != 0 ? c : a.categoryId.compareTo(b.categoryId);
    });

  return MonthSummary(
    totalCents: total,
    paidCents: paid,
    pendingCents: pending,
    excessCents: excess,
    paidBills: paidBills,
    pendingBills: pendingBills,
    overdueBills: overdueBills,
    partiallyPaidBills: partial,
    futureBills: future,
    byCategory: categories,
    activeCount: active.length,
    rangeMinCents: rangeMin,
    rangeMaxCents: rangeMax,
    hasRange: anyRange,
  );
}
