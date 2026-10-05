import 'package:flutter/material.dart';

import '../../../../core/money.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../domain/enums.dart';
import '../../../bills/presentation/ui_helpers.dart';
import '../../../../design_system/components/app_snack.dart';

String incomeKindLabel(IncomeKind k) => switch (k) {
      IncomeKind.salary => 'Salário',
      IncomeKind.extra => 'Renda extra',
      IncomeKind.other => 'Outra renda',
    };

/// Um lançamento do mês (renda ou investimento) com o botão de desfazer.
class EntryRow extends StatelessWidget {
  const EntryRow({super.key, required this.title, this.subtitle, required this.cents, required this.removeTooltip, required this.onRemove});
  final String title;
  final String? subtitle;
  final int cents;
  final String removeTooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            if (subtitle != null && subtitle!.isNotEmpty) Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5)),
          ]),
        ),
        const SizedBox(width: Space.sm),
        Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: MoneyText(cents))),
        IconButton(tooltip: removeTooltip, visualDensity: VisualDensity.compact, icon: Icon(Icons.undo_rounded, size: 20, color: c.textSecondary), onPressed: onRemove),
      ]),
    );
  }
}

/// Remove um lançamento e oferece "Desfazer" (nada é apagado de verdade).
Future<void> removeWithUndo(
  BuildContext context, {
  required Future<void> Function() remove,
  required Future<void> Function() restore,
  required String message,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final done = await runGuarded(context, remove);
  if (!done) return;
  showAppSnack(messenger, message, actionLabel: 'Desfazer', onAction: () => restore());
}

String entryMoney(int cents) => formatCents(cents);
