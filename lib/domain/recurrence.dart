import 'bill.dart';
import 'enums.dart';

/// Regra de recorrência (entidade pura).
///
/// - [Frequency.weekly]: a cada [interval] semanas.
/// - [Frequency.monthly]: a cada [interval] meses, no mesmo dia do mês (limitado ao último dia).
/// - [Frequency.yearly]: a cada [interval] anos, no mesmo dia e mês.
/// - [Frequency.custom]: a cada [interval] dias.
class RecurrenceRule {
  const RecurrenceRule({
    required this.id,
    required this.name,
    required this.baseAmountCents,
    required this.categoryId,
    required this.expenseType,
    required this.frequency,
    required this.start,
    this.interval = 1,
    this.end,
    this.favorite = false,
  });

  final String id;
  final String name;
  final int baseAmountCents;
  final String categoryId;
  final ExpenseType expenseType;
  final Frequency frequency;
  final int interval;

  /// Primeiro vencimento (data pura). O dia dele ancora as próximas datas.
  final DateTime start;

  /// Último vencimento permitido (inclusive); nulo = sem fim.
  final DateTime? end;
  final bool favorite;

  RecurrenceRule copyWith({DateTime? end, bool clearEnd = false}) => RecurrenceRule(
        id: id,
        name: name,
        baseAmountCents: baseAmountCents,
        categoryId: categoryId,
        expenseType: expenseType,
        frequency: frequency,
        start: start,
        interval: interval,
        end: clearEnd ? null : (end ?? this.end),
        favorite: favorite,
      );
}

/// Texto curto da frequência (`Mensal`, `A cada 2 semanas`…).
String describeFrequency(Frequency f, int interval) {
  if (interval <= 1) {
    return switch (f) {
      Frequency.weekly => 'Semanal',
      Frequency.monthly => 'Mensal',
      Frequency.yearly => 'Anual',
      Frequency.custom => 'Todo dia',
    };
  }
  return switch (f) {
    Frequency.weekly => 'A cada $interval semanas',
    Frequency.monthly => 'A cada $interval meses',
    Frequency.yearly => 'A cada $interval anos',
    Frequency.custom => 'A cada $interval dias',
  };
}

DateTime _lastClamped(int year, int month, int day) {
  final last = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > last ? last : day);
}

/// Vencimentos da regra dentro de `[from, to]` (inclusive), em ordem crescente.
/// Nunca antes de `rule.start` nem depois de `rule.end`. A k-ésima data é sempre calculada a partir
/// do início da regra (sem acumular erro): 31/01 → 28/02 → 31/03 → 30/04.
List<DateTime> occurrenceDates(RecurrenceRule rule, {required DateTime from, required DateTime to}) {
  final start = dateOnly(rule.start);
  var lo = dateOnly(from);
  var hi = dateOnly(to);
  if (lo.isBefore(start)) lo = start;
  if (rule.end != null && dateOnly(rule.end!).isBefore(hi)) hi = dateOnly(rule.end!);
  if (hi.isBefore(lo) || rule.interval < 1) return const [];

  final out = <DateTime>[];
  DateTime nth(int k) {
    switch (rule.frequency) {
      case Frequency.weekly:
        return DateTime(start.year, start.month, start.day + 7 * rule.interval * k);
      case Frequency.custom:
        return DateTime(start.year, start.month, start.day + rule.interval * k);
      case Frequency.monthly:
        return _lastClamped(start.year, start.month + rule.interval * k, start.day);
      case Frequency.yearly:
        return _lastClamped(start.year + rule.interval * k, start.month, start.day);
    }
  }

  // Salta direto para perto de `lo` (evita iterar anos de histórico) e então varre.
  var k = _firstIndexNear(rule, start, lo);
  while (true) {
    final d = nth(k);
    if (d.isAfter(hi)) break;
    if (!d.isBefore(lo)) out.add(d);
    k++;
    if (out.length > 5000) break; // trava de segurança
  }
  return out;
}

int _firstIndexNear(RecurrenceRule rule, DateTime start, DateTime lo) {
  final i = rule.interval;
  int k;
  switch (rule.frequency) {
    case Frequency.weekly:
      k = lo.difference(start).inDays ~/ (7 * i);
    case Frequency.custom:
      k = lo.difference(start).inDays ~/ i;
    case Frequency.monthly:
      k = ((lo.year - start.year) * 12 + (lo.month - start.month)) ~/ i;
    case Frequency.yearly:
      k = (lo.year - start.year) ~/ i;
  }
  return k > 0 ? k - 1 : 0; // uma folga garante não pular a primeira data válida
}

/// Resultado de excluir ocorrências, para informar o usuário (nada é apagado em silêncio).
class RecurrenceDeleteResult {
  const RecurrenceDeleteResult({required this.deleted, required this.keptWithPayments, required this.keptPast});
  final int deleted;
  final int keptWithPayments;
  final int keptPast;
}

enum EditScope { thisOnly, thisAndFollowing }

enum DeleteScope { thisOnly, thisAndFollowing, all }
