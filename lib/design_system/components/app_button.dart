import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'pressable.dart';

enum AppButtonKind {
  /// Ação principal: degradê da marca com brilho.
  primary,

  /// Ação secundária: fundo suave da cor de destaque.
  tonal,

  /// Ação discreta: só contorno.
  ghost,
}

/// Botão em pílula com ícone, toque com feedback próprio e três níveis de ênfase.
/// Em linha com outros, use [expand] dentro de um `Expanded` para dividir a largura por igual.
class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.icon, this.kind = AppButtonKind.tonal, this.expand = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonKind kind;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final (Color fg, BoxDecoration deco) = switch (kind) {
      AppButtonKind.primary => (
          Colors.white,
          BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.pill),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroGlow, c.heroStart]),
            boxShadow: [BoxShadow(color: c.heroStart.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))],
          ),
        ),
      AppButtonKind.tonal => (
          c.accent,
          BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.pill),
            color: c.accentSoft,
            border: Border.all(color: c.accent.withValues(alpha: 0.28)),
          ),
        ),
      AppButtonKind.ghost => (
          c.textPrimary,
          BoxDecoration(borderRadius: BorderRadius.circular(Radii.pill), border: Border.all(color: c.border, width: 1.5)),
        ),
    };
    final content = Row(mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon, size: 19, color: fg), const SizedBox(width: 8)],
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(fg).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5, height: 1.1, letterSpacing: -0.1))),
    ]);
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: onPressed,
        scale: 0.96,
        semanticLabel: label,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: deco,
          child: content,
        ),
      ),
    );
  }
}
