import 'bill.dart';

/// Um ponto do histórico de valores de uma recorrência.
class ValuePoint {
  const ValuePoint({required this.date, required this.cents});
  final DateTime date;
  final int cents;
}

/// Mudança de valor entre duas ocorrências consecutivas (apenas o fato, sem motivo).
class ValueChange {
  const ValueChange({required this.date, required this.fromCents, required this.toCents});
  final DateTime date;
  final int fromCents;
  final int toCents;
  int get deltaCents => toCents - fromCents;
}

class ValueHistory {
  const ValueHistory({required this.points, required this.changes});
  final List<ValuePoint> points;
  final List<ValueChange> changes;
  bool get isEmpty => points.isEmpty;
}

/// Histórico a partir das ocorrências (valor previsto por vencimento). Canceladas ficam de fora.
ValueHistory buildValueHistory(List<Bill> occurrences) {
  final sorted = occurrences.where((b) => !b.isCanceled).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  final points = [for (final b in sorted) ValuePoint(date: dateOnly(b.dueDate), cents: b.plannedCents)];
  final changes = <ValueChange>[];
  for (var i = 1; i < points.length; i++) {
    if (points[i].cents != points[i - 1].cents) {
      changes.add(ValueChange(date: points[i].date, fromCents: points[i - 1].cents, toCents: points[i].cents));
    }
  }
  return ValueHistory(points: points, changes: changes);
}
