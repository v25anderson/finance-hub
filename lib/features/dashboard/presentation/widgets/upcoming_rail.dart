import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting.dart';
import '../../../../core/money.dart';
import '../../../../data/db/app_database.dart';
import '../../../../data/providers.dart';
import '../../../../design_system/components/pressable.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../domain/bill.dart';
import '../../../bills/presentation/bill_detail_sheet.dart';
import '../../../shared/presentation/category_icon.dart';

String relativeDue(DateTime due, DateTime today) {
  final d = dateOnly(due).difference(dateOnly(today)).inDays;
  if (d < -1) return 'Venceu há ${-d} dias';
  if (d == -1) return 'Venceu ontem';
  if (d == 0) return 'Vence hoje';
  if (d == 1) return 'Amanhã';
  return 'Em $d dias';
}

/// "Próximas contas": carrossel horizontal de cartões em formato de pôster, no estilo das prateleiras de streaming.
/// Vencidas primeiro, depois por data. Toque abre os detalhes.
class UpcomingRail extends ConsumerWidget {
  const UpcomingRail({super.key, required this.categories});
  final Map<String, CategoryRow> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final today = ref.watch(todayProvider);
    final bills = (ref.watch(openBillsProvider).value ?? const <Bill>[]).take(12).toList();
    if (bills.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.sm + 2),
        child: Row(children: [
          Expanded(child: Text('Próximas contas', style: AppText.headline(c.textPrimary))),
          Text(bills.length == 1 ? '1 a pagar' : '${bills.length} a pagar', style: AppText.body(c.textSecondary).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
      SizedBox(
        height: 212,
        child: ListView.separated(
          key: const Key('upcoming-rail'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          itemCount: bills.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _Poster(bill: bills[i], category: categories[bills[i].categoryId], today: today),
        ),
      ),
    ]);
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.bill, required this.category, required this.today});
  final Bill bill;
  final CategoryRow? category;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final base = Color(category?.color ?? 0xFF6D5BD0);
    final overdue = dateOnly(bill.dueDate).isBefore(dateOnly(today));
    final top = Color.lerp(base, Colors.white, 0.12)!;
    final bottom = Color.lerp(base, const Color(0xFF0B0616), 0.62)!;
    return Pressable(
      key: Key('poster-${bill.id}'),
      onTap: () => showBillDetail(context, bill.id),
      scale: 0.96,
      semanticLabel: '${bill.name}, ${relativeDue(bill.dueDate, today)}',
      child: Container(
        width: 156,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.xl),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [top, bottom]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [BoxShadow(color: base.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Stack(children: [
          Positioned(right: -18, bottom: 22, child: Icon(categoryIcon(category?.icon), size: 110, color: Colors.white.withValues(alpha: 0.13))),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${bill.dueDate.day}', style: AppText.display(Colors.white).copyWith(fontSize: 44, letterSpacing: -2)),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(formatMonthName(bill.dueDate.month).substring(0, 3).toUpperCase(), style: AppText.label(Colors.white.withValues(alpha: 0.85))),
                  ),
                ]),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: overdue ? Colors.white : Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(Radii.pill)),
                child: Text(
                  relativeDue(bill.dueDate, today),
                  maxLines: 1,
                  style: AppText.body(overdue ? context.colors.danger : Colors.white).copyWith(fontSize: 11.5, fontWeight: FontWeight.w800, height: 1.2),
                ),
              ),
              const Spacer(),
              Text(bill.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body(Colors.white).copyWith(fontWeight: FontWeight.w700, fontSize: 15, height: 1.2)),
              const SizedBox(height: 3),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(formatCents(bill.remainingCents), style: AppText.number(Colors.white).copyWith(fontSize: 17))),
            ]),
          ),
        ]),
      ),
    );
  }
}
