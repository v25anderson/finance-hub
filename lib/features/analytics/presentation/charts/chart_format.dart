import 'dart:math' as math;

/// Marcas "redondas" de eixo de 0 até pelo menos [maxValue] (passos 1, 2, 2,5 ou 5 × 10^k).
List<double> niceTicks(double maxValue, {int target = 4}) {
  if (maxValue <= 0 || maxValue.isNaN || maxValue.isInfinite) return const [0, 1];
  final raw = maxValue / target;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final norm = raw / magnitude;
  final step = (norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 2.5 ? 2.5 : norm <= 5 ? 5 : 10) * magnitude;
  final ticks = <double>[];
  for (var v = 0.0; ; v += step) {
    ticks.add(double.parse(v.toStringAsFixed(10)));
    if (v >= maxValue - 1e-9) break;
    if (ticks.length > 12) break;
  }
  return ticks;
}

String _trim(double v) {
  final s = v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
  return s.replaceAll('.', ',');
}

/// Rótulo compacto de eixo para dinheiro (entrada em centavos): `0`, `800`, `2,5 mil`, `1,2 mi`.
String formatAxisMoney(double cents) {
  final v = cents.abs() / 100;
  final sign = cents < 0 ? '-' : '';
  if (v >= 1000000) return '$sign${_trim(v / 1000000)} mi';
  if (v >= 1000) return '$sign${_trim(v / 1000)} mil';
  return '$sign${_trim(v)}';
}

/// Rótulo de eixo para taxas (entrada como fração): `0%`, `12,5%`.
String formatAxisPercent(double fraction) => '${_trim(fraction * 100)}%';

/// Índice do mês sob a posição [x] (em pixels). Fora da área, prende nas pontas.
int nearestSlotIndex(double x, {required double left, required double width, required int count}) {
  if (count <= 1 || width <= 0) return 0;
  final i = ((x - left) / (width / count)).floor();
  return i.clamp(0, count - 1);
}
