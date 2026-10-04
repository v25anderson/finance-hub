import 'package:flutter/material.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';

/// Trecho de uma barra de composição. [projected] = hachurado (projeção); senão sólido (dado real).
class BarSegment {
  const BarSegment(this.value, this.color, {required this.projected});
  final int value;
  final Color color;
  final bool projected;
}

/// Barra horizontal de composição: **sólido = dado real**, **hachurado = projeção**.
/// [markerFraction] desenha um traço vertical (0 a 1), usado para mostrar onde termina a renda quando há déficit.
class HatchedBar extends StatelessWidget {
  const HatchedBar({
    super.key,
    required this.segments,
    this.markerFraction,
    this.height = 14,
  });
  final List<BarSegment> segments;
  final double? markerFraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          segments: segments,
          track: c.surfaceAlt,
          marker: c.textPrimary,
          markerFraction: markerFraction,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.segments,
    required this.track,
    required this.marker,
    this.markerFraction,
  });
  final List<BarSegment> segments;
  final Color track;
  final Color marker;
  final double? markerFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawRect(Offset.zero & size, Paint()..color = track);

    final total = segments.fold<int>(
      0,
      (s, e) => s + (e.value > 0 ? e.value : 0),
    );
    if (total > 0) {
      var x = 0.0;
      for (final s in segments) {
        if (s.value <= 0) continue;
        final w = size.width * s.value / total;
        final rect = Rect.fromLTWH(x, 0, w, size.height);
        if (s.projected) {
          canvas.drawRect(
            rect,
            Paint()..color = s.color.withValues(alpha: 0.2),
          );
          canvas.save();
          canvas.clipRect(rect);
          final stripe = Paint()
            ..color = s.color.withValues(alpha: 0.85)
            ..strokeWidth = 2;
          for (
            var dx = rect.left - size.height;
            dx < rect.right + size.height;
            dx += 6
          ) {
            canvas.drawLine(
              Offset(dx, size.height),
              Offset(dx + size.height, 0),
              stripe,
            );
          }
          canvas.restore();
        } else {
          canvas.drawRect(rect, Paint()..color = s.color);
        }
        x += w;
        // separador fino entre trechos
        if (x < size.width - 0.5) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.height),
            Paint()
              ..color = track
              ..strokeWidth = 1.5,
          );
        }
      }
    }
    canvas.restore();

    final m = markerFraction;
    if (m != null && m > 0 && m < 1) {
      final px = size.width * m;
      canvas.drawLine(
        Offset(px, -2),
        Offset(px, size.height + 2),
        Paint()
          ..color = marker
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.segments != segments ||
      old.track != track ||
      old.markerFraction != markerFraction;
}

/// Legenda: sólido = dado real, hachurado = projeção.
class RealProjectedLegend extends StatelessWidget {
  const RealProjectedLegend({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.xs,
      children: [
        _swatch(c, 'Dado real', projected: false),
        _swatch(c, 'Projeção', projected: true),
      ],
    );
  }

  Widget _swatch(AppColors c, String label, {required bool projected}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 26,
        height: 10,
        child: HatchedBar(
          height: 10,
          segments: [BarSegment(1, c.accent, projected: projected)],
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
        ),
      ),
    ],
  );
}
