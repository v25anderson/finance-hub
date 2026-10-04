import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Fundo "aurora" do cabeçalho: degradê da marca, halos de luz e anéis concêntricos (assinatura visual do app).
/// Só desenho: não captura toques e não altera o layout.
class Aurora extends StatelessWidget {
  const Aurora({super.key, required this.child, this.borderRadius = BorderRadius.zero, this.padding = EdgeInsets.zero, this.rings = true});
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final bool rings;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroStart, c.heroEnd])),
        child: CustomPaint(
          painter: _AuroraPainter(glow: c.heroGlow, rings: rings),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.glow, required this.rings});
  final Color glow;
  final bool rings;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    void halo(Offset center, double radius, Color color, double alpha) {
      final paint = Paint()
        ..shader = RadialGradient(colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawRect(rect, paint);
    }

    halo(Offset(size.width * 0.92, size.height * 0.02), size.width * 0.85, glow, 0.55);
    halo(Offset(size.width * 0.02, size.height * 1.02), size.width * 0.7, const Color(0xFFFF5CA8), 0.20);
    if (!rings) return;
    final center = Offset(size.width * 0.98, size.height * 0.04);
    for (var i = 0; i < 5; i++) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.16 - i * 0.028);
      canvas.drawCircle(center, size.width * (0.22 + i * 0.16), stroke);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.glow != glow || old.rings != rings;
}
