import 'bill.dart';

/// Faixas de vencimento exclusivas (cada conta cai em uma só), a partir de hoje.
enum AlertKind {
  overdue, // já venceu
  today, // vence hoje
  tomorrow, // vence amanhã
  week, // daqui a 2–7 dias
  month, // daqui a 8–30 dias
}

class DueAlert {
  const DueAlert({required this.kind, required this.count, required this.totalCents});
  final AlertKind kind;
  final int count;

  /// Soma do que ainda falta pagar nas contas da faixa.
  final int totalCents;
}

/// Alertas discretos (sem notificações agressivas). Só contas com valor a pagar e não canceladas.
/// Retorna apenas faixas com pelo menos uma conta, na ordem de urgência.
List<DueAlert> computeAlerts(List<Bill> bills, DateTime today) {
  final t = dateOnly(today);
  final counts = <AlertKind, (int, int)>{};
  for (final b in bills) {
    if (b.isCanceled || b.remainingCents <= 0) continue;
    final days = dateOnly(b.dueDate).difference(t).inDays;
    final AlertKind? kind = days < 0
        ? AlertKind.overdue
        : days == 0
            ? AlertKind.today
            : days == 1
                ? AlertKind.tomorrow
                : days <= 7
                    ? AlertKind.week
                    : days <= 30
                        ? AlertKind.month
                        : null;
    if (kind == null) continue;
    final cur = counts[kind] ?? (0, 0);
    counts[kind] = (cur.$1 + 1, cur.$2 + b.remainingCents);
  }
  return [
    for (final k in AlertKind.values)
      if (counts[k] != null) DueAlert(kind: k, count: counts[k]!.$1, totalCents: counts[k]!.$2),
  ];
}
