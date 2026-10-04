import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../tokens/spacing.dart';

bool _reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Valor em reais que "conta" até o número final na primeira exibição e a cada mudança.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.cents, {super.key, required this.style, this.compact = false});
  final int cents;
  final TextStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fmt = compact ? formatCentsCompact : formatCents;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: cents.toDouble()),
      duration: _reduceMotion(context) ? Duration.zero : Motion.slow,
      curve: Motion.curve,
      builder: (_, v, _) => Text(fmt(v.round()), style: style),
    );
  }
}

/// Barra de progresso arredondada, com preenchimento animado.
class AppProgress extends StatelessWidget {
  const AppProgress({super.key, required this.value, required this.color, required this.track, this.height = 10});
  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: _reduceMotion(context) ? Duration.zero : Motion.slow,
      curve: Motion.curve,
      builder: (_, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Stack(children: [
          Container(height: height, color: track),
          FractionallySizedBox(widthFactor: v, child: Container(height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.pill)))),
        ]),
      ),
    );
  }
}

/// Entrada suave (aparece subindo levemente), escalonada por [index]. Sem timers: usa curva com atraso.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    const base = 320;
    final delay = (index * 55).clamp(0, 330);
    final total = base + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Motion.curve),
      builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: c)),
      child: child,
    );
  }
}
