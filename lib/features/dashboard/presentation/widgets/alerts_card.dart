import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/shell_index_provider.dart';
import '../../../../core/money.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../domain/alerts.dart';
import '../dashboard_format.dart';

/// Alertas discretos de vencimento. Toque leva à tela de Contas.
class AlertsCard extends ConsumerWidget {
  const AlertsCard({super.key, required this.alerts});
  final List<DueAlert> alerts;

  static (Tone, IconData) _style(AlertKind k) => switch (k) {
        AlertKind.overdue => (Tone.danger, Icons.error_outline),
        AlertKind.today || AlertKind.tomorrow => (Tone.warning, Icons.schedule),
        AlertKind.week => (Tone.warning, Icons.event_outlined),
        AlertKind.month => (Tone.neutral, Icons.event_outlined),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    if (alerts.isEmpty) {
      return AppCard(
        child: Row(children: [
          Icon(Icons.check_circle_outline, color: c.success),
          const SizedBox(width: Space.sm),
          Expanded(child: Text('Nada vencendo nos próximos 30 dias.', style: AppText.body(c.textSecondary))),
        ]),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Column(children: [
        for (final a in alerts)
          InkWell(
            onTap: () => ref.read(shellIndexProvider.notifier).select(billsTabIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm + 2),
              child: Row(children: [
                Icon(_style(a.kind).$2, size: 20, color: c.tone(_style(a.kind).$1)),
                const SizedBox(width: Space.sm + 2),
                Expanded(child: Text(alertText(a), style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600))),
                Text(formatCents(a.totalCents), style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
              ]),
            ),
          ),
      ]),
    );
  }
}
