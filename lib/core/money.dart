import 'package:intl/intl.dart';

/// Dinheiro é sempre representado em centavos inteiros (DECISIONS D03).
final NumberFormat _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
final NumberFormat _brlCompact = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

/// Formata centavos como `R$ 1.234,56`.
String formatCents(int cents) => _brl.format(cents / 100).replaceAll(' ', ' ');

/// Formata centavos sem casas decimais (`R$ 5.240`), para KPIs.
String formatCentsCompact(int cents) => _brlCompact.format(cents / 100).replaceAll(' ', ' ');

/// Converte texto digitado (`1.234,56`, `24,9`, `R$ 10`) em centavos. Retorna null se inválido.
int? parseCents(String input) {
  var s = input.replaceAll(RegExp(r'[^0-9,.\-]'), '');
  if (s.isEmpty) return null;
  if (s.contains(',')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'\.\d{3}(\.|$)').hasMatch(s)) {
    s = s.replaceAll('.', '');
  }
  final v = double.tryParse(s);
  if (v == null) return null;
  return (v * 100).round();
}
