import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/formatting.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// `← Outubro 2026 →` com seleção manual de mês e ano (inclui meses futuros).
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final c = context.colors;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(tooltip: 'Mês anterior', onPressed: notifier.previous, icon: const Icon(Icons.chevron_left)),
      Flexible(
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.sm),
          onTap: () => _pick(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
            child: Text(formatMonthYear(month), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title(c.textPrimary).copyWith(fontSize: 18)),
          ),
        ),
      ),
      IconButton(tooltip: 'Próximo mês', onPressed: notifier.next, icon: const Icon(Icons.chevron_right)),
    ]);
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedMonthProvider);
    final result = await showDialog<DateTime>(context: context, builder: (_) => _MonthPickerDialog(initial: current));
    if (result != null) ref.read(selectedMonthProvider.notifier).set(result.year, result.month);
  }
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
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(tooltip: 'Ano anterior', onPressed: () => setState(() => _year--), icon: const Icon(Icons.chevron_left)),
        Text('$_year'),
        IconButton(tooltip: 'Próximo ano', onPressed: () => setState(() => _year++), icon: const Icon(Icons.chevron_right)),
      ]),
      content: SizedBox(
        width: 320,
        child: Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
          for (var m = 1; m <= 12; m++)
            ChoiceChip(
              label: Text(formatMonthName(m).substring(0, 3)),
              selected: _year == widget.initial.year && m == widget.initial.month,
              onSelected: (_) => Navigator.pop(context, DateTime(_year, m)),
            ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))],
    );
  }
}
