import 'month_summary.dart';

class CategoryChange {
  const CategoryChange({required this.categoryId, required this.currentCents, required this.previousCents});
  final String categoryId;
  final int currentCents;
  final int previousCents;
  int get deltaCents => currentCents - previousCents;
}

/// Comparação neutra entre dois meses: só números, sem conclusões.
class MonthComparison {
  const MonthComparison({required this.currentCents, required this.previousCents, required this.topChanges});
  final int currentCents;
  final int previousCents;

  /// Categorias com maior variação absoluta (maior primeiro).
  final List<CategoryChange> topChanges;

  int get deltaCents => currentCents - previousCents;

  /// Variação percentual como fração (0,083 = +8,3%). Nulo quando o mês anterior não tem gastos
  /// (a divisão por zero não tem significado).
  double? get deltaFraction => previousCents == 0 ? null : deltaCents / previousCents;

  /// Não há base de comparação: nenhum dos dois meses tem gastos.
  bool get isEmpty => currentCents == 0 && previousCents == 0;
}

MonthComparison compareMonths(MonthSummary current, MonthSummary previous, {int top = 3}) {
  final cur = {for (final c in current.byCategory) c.categoryId: c.plannedCents};
  final prev = {for (final c in previous.byCategory) c.categoryId: c.plannedCents};
  final ids = {...cur.keys, ...prev.keys};
  final changes = [
    for (final id in ids) CategoryChange(categoryId: id, currentCents: cur[id] ?? 0, previousCents: prev[id] ?? 0),
  ].where((c) => c.deltaCents != 0).toList()
    ..sort((a, b) {
      final c = b.deltaCents.abs().compareTo(a.deltaCents.abs());
      return c != 0 ? c : a.categoryId.compareTo(b.categoryId);
    });
  return MonthComparison(
    currentCents: current.totalCents,
    previousCents: previous.totalCents,
    topChanges: changes.take(top).toList(),
  );
}
