import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/providers.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/value_history.dart';

/// Histórico de valores de uma recorrência: gráfico valor × tempo e as mudanças (fatos, sem motivo).
class ValueHistorySection extends ConsumerWidget {
  const ValueHistorySection({super.key, required this.ruleId});
  final String ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final today = ref.watch(todayProvider);
    final async = ref.watch(occurrencesProvider(ruleId));
    return async.when(
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Text('Não foi possível carregar o histórico de valores.'),
      data: (occurrences) {
        final history = buildValueHistory(occurrences);
        if (history.isEmpty) return Text('Sem ocorrências.', style: AppText.body(c.textSecondary));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (history.points.length > 1)
            SizedBox(
              height: 170,
              child: Semantics(
                label: 'Gráfico de valor por tempo, de ${formatCents(history.points.first.cents)} a ${formatCents(history.points.last.cents)}',
                child: CustomPaint(
                  key: const Key('value-history-chart'),
                  size: Size.infinite,
                  painter: _ChartPainter(history: history, today: today, colors: c),
                ),
              ),
            )
          else
            Text('Uma ocorrência: ${formatCents(history.points.single.cents)}.', style: AppText.body(c.textSecondary)),
          const SizedBox(height: Space.sm),
          if (history.changes.isEmpty)
            Text('Valor sem alterações nas ocorrências.', key: const Key('value-history-unchanged'), style: AppText.body(c.textSecondary).copyWith(fontSize: 13))
          else
            for (final ch in history.changes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${formatMonthShort(ch.date)}: ${formatCents(ch.fromCents)} para ${formatCents(ch.toCents)} (${ch.deltaCents > 0 ? '+' : '−'}${formatCents(ch.deltaCents.abs())})',
                  style: AppText.body(c.textPrimary).copyWith(fontSize: 13),
                ),
              ),
          if (history.points.any((p) => p.date.isAfter(today)))
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text('Linha tracejada: ocorrências futuras (previstas).', style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
            ),
        ]);
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.history, required this.today, required this.colors});
  final ValueHistory history;
  final DateTime today;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 8.0, padR = 8.0, padT = 26.0, padB = 22.0;
    final pts = history.points;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final t0 = pts.first.date.millisecondsSinceEpoch.toDouble();
    final t1 = pts.last.date.millisecondsSinceEpoch.toDouble();
    var lo = pts.map((p) => p.cents).reduce((a, b) => a < b ? a : b).toDouble();
    var hi = pts.map((p) => p.cents).reduce((a, b) => a > b ? a : b).toDouble();
    if (hi == lo) {
      lo -= 1;
      hi += 1;
    }
    final pad = (hi - lo) * 0.2;
    lo -= pad;
    hi += pad;

    double x(DateTime d) => padL + (t1 == t0 ? w / 2 : (d.millisecondsSinceEpoch - t0) / (t1 - t0) * w);
    double y(int cents) => padT + h - (cents - lo) / (hi - lo) * h;

    final base = Paint()
      ..color = colors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(padL, padT + h), Offset(padL + w, padT + h), base);

    final solid = Paint()
      ..color = colors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final dashed = Paint()
      ..color = colors.accent.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Degraus: segura o valor até a próxima ocorrência e então muda.
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final future = a.date.isAfter(today);
      final path = Path()
        ..moveTo(x(a.date), y(a.cents))
        ..lineTo(x(b.date), y(a.cents))
        ..lineTo(x(b.date), y(b.cents));
      canvas.drawPath(future ? _dash(path) : path, future ? dashed : solid);
    }

    final dot = Paint()..color = colors.accent;
    final dotFuture = Paint()..color = colors.accent.withValues(alpha: 0.55);
    for (final p in pts) {
      canvas.drawCircle(Offset(x(p.date), y(p.cents)), 3, p.date.isAfter(today) ? dotFuture : dot);
    }

    // Rótulos de valor: primeiro, mudanças e último.
    final labelled = <ValuePoint>[pts.first, for (final c in history.changes) ValuePoint(date: c.date, cents: c.toCents), pts.last];
    double? lastX;
    for (final p in labelled) {
      final px = x(p.date);
      if (lastX != null && (px - lastX).abs() < 50) continue;
      lastX = px;
      _text(canvas, formatCents(p.cents), Offset(px, y(p.cents) - 20), colors.textPrimary, 11, bold: true, size: size);
    }
    _text(canvas, formatMonthShort(pts.first.date), Offset(padL + 18, size.height - 14), colors.textSecondary, 11, size: size);
    _text(canvas, formatMonthShort(pts.last.date), Offset(size.width - padR - 18, size.height - 14), colors.textSecondary, 11, size: size);
  }

  Path _dash(Path source) {
    final out = Path();
    for (final m in source.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        out.addPath(m.extractPath(d, (d + 5).clamp(0, m.length)), Offset.zero);
        d += 9;
      }
    }
    return out;
  }

  void _text(Canvas canvas, String s, Offset center, Color color, double fontSize, {bool bold = false, required Size size}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final dx = (center.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
    tp.paint(canvas, Offset(dx, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.history != history || old.today != today || old.colors != colors;
}
