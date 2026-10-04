import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../domain/alerts.dart';

/// `+R$ 402,00` / `−R$ 90,00` / `R$ 0,00`.
String formatSigned(int cents) {
  if (cents == 0) return formatCents(0);
  return '${cents > 0 ? '+' : '−'}${formatCents(cents.abs())}';
}

/// `+8,3%` / `−20%`.
String formatSignedPercent(double fraction) {
  final base = formatPercent(fraction.abs());
  if (fraction == 0) return base;
  return '${fraction > 0 ? '+' : '−'}$base';
}

/// Texto do alerta, no singular ou plural.
String alertText(DueAlert a) {
  final one = a.count == 1;
  final n = a.count;
  return switch (a.kind) {
    AlertKind.overdue => one ? '1 conta está vencida' : '$n contas estão vencidas',
    AlertKind.today => one ? '1 conta vence hoje' : '$n contas vencem hoje',
    AlertKind.tomorrow => one ? 'Vence amanhã' : '$n contas vencem amanhã',
    AlertKind.week => one ? '1 conta vence esta semana' : '$n contas vencem esta semana',
    AlertKind.month => one ? '1 conta vence nos próximos 30 dias' : '$n contas vencem nos próximos 30 dias',
  };
}
