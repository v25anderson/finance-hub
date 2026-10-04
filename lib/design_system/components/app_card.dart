import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'pressable.dart';

/// Cartão base: cantos grandes, espaço generoso e toque com feedback próprio.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(Space.lg), this.color});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        // no escuro, um brilho sutil no topo dá profundidade (efeito "tela de cinema"); no claro, sombra suave
        gradient: color == null && !isLight
            ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.alphaBlend(Colors.white.withValues(alpha: 0.045), c.surface), c.surface])
            : null,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: isLight ? c.border.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.07)),
        boxShadow: isLight ? [BoxShadow(color: const Color(0xFF3A1096).withValues(alpha: 0.07), blurRadius: 28, offset: const Offset(0, 10))] : null,
      ),
      child: child,
    );
    return onTap == null ? card : Pressable(onTap: onTap, scale: 0.985, child: card);
  }
}

/// Rótulo em caixa alta usado acima de números.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: AppText.label(color ?? context.colors.textSecondary));
}
