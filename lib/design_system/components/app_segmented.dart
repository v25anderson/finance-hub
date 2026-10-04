import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'pressable.dart';

/// Controle segmentado em pílula, com o item ativo destacado (substitui o SegmentedButton do Material).
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({super.key, required this.options, required this.selected, required this.onChanged});
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Row(children: [
        for (final (value, label) in options)
          Expanded(
            child: Pressable(
              onTap: () => onChanged(value),
              scale: 0.98,
              semanticLabel: label,
              child: AnimatedContainer(
                duration: reduce ? Duration.zero : Motion.normal,
                curve: Motion.curve,
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == selected ? (Theme.of(context).brightness == Brightness.light ? c.surface : c.border) : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.pill),
                  boxShadow: value == selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, style: AppText.body(value == selected ? c.textPrimary : c.textSecondary).copyWith(fontSize: 14, fontWeight: value == selected ? FontWeight.w700 : FontWeight.w600)),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Chip de seleção em pílula (substitui ChoiceChip). Selecionado = cor de destaque suave com texto de destaque.
class AppChoice extends StatelessWidget {
  const AppChoice({super.key, required this.label, required this.selected, required this.onTap, this.leading});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : Motion.normal,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.accentSoft : c.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: selected ? c.accent.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(label, style: AppText.body(selected ? c.accent : c.textPrimary).copyWith(fontSize: 13.5, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
