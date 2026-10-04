import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/formatting.dart';
import '../../../design_system/components/app_segmented.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// `‹ Outubro 2026 ›` em pílula, com seleção manual de mês e ano (inclui meses futuros).
/// [onHero]: versão clara para usar sobre o cabeçalho de destaque.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key, this.onHero = false});
  final bool onHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final c = context.colors;
    final fg = onHero ? AppColors.onHero : c.textPrimary;
    return Container(
      decoration: BoxDecoration(
        color: onHero ? Colors.white.withValues(alpha: 0.16) : c.surface,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: onHero ? null : Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Arrow(icon: Icons.chevron_left_rounded, tooltip: 'Mês anterior', color: fg, onTap: notifier.previous),
        Flexible(
          child: Pressable(
            onTap: () => _pick(context, ref),
            scale: 0.98,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(formatMonthYear(month), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(fg).copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        _Arrow(icon: Icons.chevron_right_rounded, tooltip: 'Próximo mês', color: fg, onTap: notifier.next),
      ]),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedMonthProvider);
    final result = await showDialog<DateTime>(context: context, builder: (_) => _MonthPickerDialog(initial: current));
    if (result != null) ref.read(selectedMonthProvider.notifier).set(result.year, result.month);
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, required this.color, required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Pressable(onTap: onTap, scale: 0.9, child: SizedBox(width: 38, height: 38, child: Icon(icon, color: color, size: 24))),
      );
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.initial});
  final DateTime initial;
  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(tooltip: 'Ano anterior', onPressed: () => setState(() => _year--), icon: const Icon(Icons.chevron_left_rounded)),
        Text('$_year', style: AppText.headline(c.textPrimary)),
        IconButton(tooltip: 'Próximo ano', onPressed: () => setState(() => _year++), icon: const Icon(Icons.chevron_right_rounded)),
      ]),
      content: SizedBox(
        width: 320,
        child: Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
          for (var m = 1; m <= 12; m++)
            AppChoice(
              label: formatMonthName(m).substring(0, 3),
              selected: _year == widget.initial.year && m == widget.initial.month,
              onTap: () => Navigator.pop(context, DateTime(_year, m)),
            ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))],
    );
  }
}
