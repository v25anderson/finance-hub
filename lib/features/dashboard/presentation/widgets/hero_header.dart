import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_mode_provider.dart';
import '../../../../design_system/components/aurora.dart';
import '../../../../application/dashboard_data.dart';
import '../../../../core/formatting.dart';
import '../../../../core/money.dart';
import '../../../../design_system/components/animated_value.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/components/pressable.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../shared/presentation/page_header.dart';
import '../../../shared/presentation/period_selector.dart';

const _paidTint = Color(0xFF7DF2B4);
const _pendingTint = Color(0xFFFFD68A);

/// Cabeçalho de destaque: degradê da marca com o seletor de período e o KPI "Gastos do mês".
/// Em celular vai de ponta a ponta (sob a barra de status); em telas largas vira um cartão grande.
class HeroHeader extends ConsumerWidget {
  const HeroHeader({super.key, required this.data, required this.onOpenDetail, required this.edgeToEdge});
  final DashboardData? data;
  final VoidCallback onOpenDetail;
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = edgeToEdge ? topInset(context) : 0.0;
    final radius = edgeToEdge ? const BorderRadius.vertical(bottom: Radius.circular(40)) : BorderRadius.circular(Radii.xl + 8);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: edgeToEdge ? EdgeInsets.zero : const EdgeInsets.fromLTRB(Space.md, Space.lg, Space.md, 0),
      child: Aurora(
        borderRadius: radius,
        padding: EdgeInsets.fromLTRB(Space.lg, top + Space.lg, Space.lg, Space.lg + 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Visão geral', style: AppText.title(AppColors.onHero).copyWith(fontSize: 28))),
            Pressable(
              key: const Key('theme-toggle'),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(context),
              semanticLabel: 'Alternar tema',
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.16), border: Border.all(color: Colors.white.withValues(alpha: 0.22))),
                child: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: AppColors.onHero, size: 20),
              ),
            ),
          ]),
          const SizedBox(height: Space.sm + 2),
          const PeriodSelector(onHero: true),
          const SizedBox(height: Space.lg + 4),
          if (data == null)
            const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.onHero)))
          else
            _Kpi(data: data!, onTap: onOpenDetail),
        ]),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.data, required this.onTap});
  final DashboardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    final dim = AppColors.onHero.withValues(alpha: 0.78);
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      semanticLabel: 'Ver detalhes do mês',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('GASTOS DO MÊS', style: AppText.label(dim))),
          Icon(Icons.arrow_forward_rounded, color: dim, size: 20, semanticLabel: 'Ver detalhes'),
        ]),
        const SizedBox(height: Space.sm),
        MoneyText(s.totalCents, size: MoneySize.hero, color: AppColors.onHero),
        const SizedBox(height: Space.lg),
        if (s.isEmpty)
          Text('Nenhuma conta neste mês.', style: AppText.body(dim))
        else ...[
          AppProgress(value: s.paidFraction, color: AppColors.onHero, track: Colors.white.withValues(alpha: 0.2), height: 12),
          const SizedBox(height: Space.md),
          Row(children: [
            Expanded(child: _Part('PAGO', s.paidCents, _paidTint)),
            Expanded(child: _Part('PENDENTE', s.pendingCents, _pendingTint)),
          ]),
          const SizedBox(height: Space.md),
          Wrap(spacing: Space.md, children: [
            Text('${formatPercent(s.paidFraction)} quitado', style: AppText.number(AppColors.onHero).copyWith(fontSize: 15)),
            Text('${formatPercent(s.remainingFraction)} restante', style: AppText.body(dim).copyWith(fontSize: 15)),
          ]),
          if (s.excessCents > 0) ...[
            const SizedBox(height: Space.sm),
            Text('Pago além do previsto: +${formatCents(s.excessCents)}', style: AppText.body(dim).copyWith(fontSize: 13)),
          ],
        ],
      ]),
    );
  }
}

class _Part extends StatelessWidget {
  const _Part(this.label, this.cents, this.tint);
  final String label;
  final int cents;
  final Color tint;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: tint, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppText.label(AppColors.onHero.withValues(alpha: 0.78))),
        ]),
        const SizedBox(height: Space.xs),
        MoneyText(cents, color: AppColors.onHero),
      ]);
}
