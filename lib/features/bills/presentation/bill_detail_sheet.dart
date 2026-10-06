import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/components/status_chip.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import '../../../domain/enums.dart';
import '../../../domain/recurrence.dart';
import 'bill_form_sheet.dart';
import 'payment_dialogs.dart';
import 'recurrence_dialogs.dart';
import 'value_history_chart.dart';
import 'range_text.dart';
import 'status_style.dart';
import 'ui_helpers.dart';
import '../../../design_system/components/app_snack.dart';

Future<void> showBillDetail(BuildContext context, String billId) =>
    showAdaptiveSheet<void>(context, builder: (_) => BillDetailSheet(billId: billId));

class BillDetailSheet extends ConsumerWidget {
  const BillDetailSheet({super.key, required this.billId});
  final String billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(billProvider(billId));
    final today = ref.watch(todayProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Não foi possível carregar a conta.')),
      data: (bill) {
        if (bill == null) {
          return const Center(child: Text('Esta conta não existe mais.'));
        }
        return _Content(bill: bill, today: today);
      },
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.bill, required this.today});
  final Bill bill;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final svc = ref.read(billServiceProvider);
    final st = styleFor(bill, today);
    final category = ref.watch(categoriesProvider).value?.where((x) => x.id == bill.categoryId).firstOrNull;
    final canPay = !bill.isCanceled && bill.remainingCents > 0;

    return ListView(padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xl), children: [
      Row(children: [
        Expanded(child: Text(bill.name, style: AppText.title(c.textPrimary))),
        IconButton(
          tooltip: bill.favorite ? 'Remover dos favoritos' : 'Favoritar',
          onPressed: () => runGuarded(context, () => svc.toggleFavorite(bill.id)),
          icon: Icon(bill.favorite ? Icons.star_rounded : Icons.star_outline_rounded, color: bill.favorite ? c.warning : c.textSecondary),
        ),
        IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ]),
      const SizedBox(height: Space.sm),
      Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
        StatusChip(label: st.label, tone: st.tone, icon: st.icon),
        if (bill.isPartiallyPaid && bill.statusOn(today) == BillStatus.overdue)
          StatusChip(label: '${formatPercent(bill.paidFraction)} paga', tone: Tone.info, icon: Icons.timelapse),
      ]),
      const SizedBox(height: Space.lg),
      const SectionLabelText('Valor previsto'),
      MoneyText(bill.plannedCents, size: MoneySize.display),
      if (bill.range != null) ...[
        const SizedBox(height: Space.xs),
        Row(children: [
          Icon(Icons.swap_vert_rounded, size: 18, color: c.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text('Faixa informada: ${formatRange(bill.range!)}', key: const Key('bill-range'), style: AppText.body(c.textSecondary).copyWith(fontWeight: FontWeight.w600))),
        ]),
        if (bill.paidRangePosition != null) Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(rangePositionText(bill.paidRangePosition!), key: const Key('bill-range-position'), style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
        ),
      ],
      const SizedBox(height: Space.md),
      Row(children: [
        Expanded(child: _Metric('Pago', bill.paidCents, Tone.success)),
        Expanded(child: _Metric('Restante', bill.remainingCents, bill.remainingCents > 0 ? Tone.warning : Tone.neutral)),
        if (bill.excessCents > 0) Expanded(child: _Metric('Excedente', bill.excessCents, Tone.info)),
      ]),
      const SizedBox(height: Space.md),
      ClipRRect(
        borderRadius: BorderRadius.circular(Radii.pill),
        child: LinearProgressIndicator(value: bill.paidFraction, minHeight: 8, backgroundColor: c.surfaceAlt, color: c.success),
      ),
      const SizedBox(height: Space.xs),
      Text('${formatPercent(bill.paidFraction)} pago', style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
      const SizedBox(height: Space.md),
      Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
        if (bill.paidCents > 0)
          OutlinedButton.icon(
            key: const Key('unpay-button'),
            onPressed: () => _unpay(context, ref),
            icon: const Icon(Icons.undo_rounded),
            label: Text(bill.isFullyPaid ? 'Desmarcar como pago' : 'Desfazer pagamentos'),
          ),
        FilledButton.icon(
          onPressed: canPay ? () => _pay(context, ref, total: true) : null,
          icon: const Icon(Icons.check),
          label: const Text('Marcar como pago'),
        ),
        OutlinedButton.icon(
          onPressed: canPay ? () => _pay(context, ref, total: false) : null,
          icon: const Icon(Icons.payments_outlined),
          label: const Text('Pagamento parcial'),
        ),
      ]),
      const SizedBox(height: Space.lg),
      _Info('Vencimento', formatDay(bill.dueDate)),
      _Info('Criada em', formatDay(bill.createdAt.toLocal())),
      _Info('Categoria', category?.name ?? '—'),
      _Info('Tipo', expenseTypeLabel(bill.expenseType)),
      _RecurrenceInfo(bill: bill),
      if (bill.note.isNotEmpty) _Info('Observação', bill.note),
      const SizedBox(height: Space.lg),
      const SizedBox(height: Space.lg),
      Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
        OutlinedButton.icon(
          onPressed: () => showBillForm(context, mode: BillFormMode.edit, source: bill),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final id = await showBillForm(context, mode: BillFormMode.duplicate, source: bill);
            if (id != null && context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Duplicar'),
        ),
        const Tooltip(
          message: 'Comprovantes ainda não estão disponíveis',
          child: OutlinedButton(onPressed: null, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.attach_file, size: 18), SizedBox(width: 6), Text('Anexar comprovante')])),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: c.danger),
          onPressed: () => _delete(context, ref),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Excluir'),
        ),
      ]),
      if (bill.isRecurring) ...[
        const SizedBox(height: Space.xl),
        const SectionLabelText('Histórico de valores'),
        const SizedBox(height: Space.sm),
        ValueHistorySection(ruleId: bill.recurringId!),
      ],
      const SizedBox(height: Space.xl),
      const SectionLabelText('Histórico de pagamentos'),
      const SizedBox(height: Space.sm),
      if (bill.payments.isEmpty)
        Text('Nenhum pagamento registrado.', style: AppText.body(c.textSecondary))
      else
        for (final p in bill.payments.reversed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: MoneyText(p.amountCents),
            subtitle: Text([formatDateTime(p.paidAt), if (p.note.isNotEmpty) p.note].join(' · ')),
            trailing: IconButton(
              tooltip: 'Excluir pagamento',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deletePayment(context, ref, p),
            ),
          ),
    ]);
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, {required bool total}) async {
    final svc = ref.read(billServiceProvider);
    final now = ref.read(clockProvider)();
    final input = await showPaymentDialog(context, bill: bill, total: total, now: now);
    if (input == null || !context.mounted) return;
    await runGuarded(context, () async {
      if (total && bill.expenseType == ExpenseType.variable && bill.paidCents == 0) {
        await svc.payActual(bill.id, input.amountCents, paidAt: input.paidAt, note: input.note);
      } else if (total) {
        await svc.markAsPaid(bill.id, paidAt: input.paidAt, note: input.note);
      } else {
        await svc.registerPayment(bill.id, input.amountCents, paidAt: input.paidAt, note: input.note);
      }
    });
  }

  /// Remove todos os pagamentos da conta, com confirmação e "Desfazer". Nada é apagado de verdade.
  Future<void> _unpay(BuildContext context, WidgetRef ref) async {
    final svc = ref.read(billServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final n = bill.payments.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(bill.isFullyPaid ? 'Desmarcar como pago?' : 'Desfazer os pagamentos?'),
        content: Text(
          n == 1
              ? 'O pagamento de ${formatCents(bill.paidCents)} será removido e a conta volta a ficar em aberto. Você pode desfazer logo em seguida.'
              : '$n pagamentos (${formatCents(bill.paidCents)} no total) serão removidos e a conta volta a ficar em aberto. Você pode desfazer logo em seguida.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
          FilledButton(key: const Key('unpay-confirm'), onPressed: () => Navigator.pop(d, true), child: const Text('Desmarcar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    List<String>? removed;
    final done = await runGuarded(context, () async => removed = await svc.removeAllPayments(bill.id));
    if (!done || removed == null || !context.mounted) return;
    // A barra de aviso fica atrás da folha modal (o toque cairia na área escura): fecha a folha e oferece o "Desfazer" na lista.
    Navigator.pop(context);
    showAppSnack(messenger, 'Pagamentos removidos', actionLabel: 'Desfazer', onAction: () => svc.restorePayments(removed!));
  }

  Future<void> _deletePayment(BuildContext context, WidgetRef ref, Payment p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Excluir pagamento?'),
        content: Text('${formatCents(p.amountCents)} em ${formatDateTime(p.paidAt)}. O estado da conta será recalculado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await runGuarded(context, () => ref.read(billServiceProvider).deletePayment(p.id));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final svc = ref.read(billServiceProvider);
    final recurrence = ref.read(recurrenceServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (bill.isRecurring) {
      final scope = await showDeleteScopeDialog(context);
      if (scope == null || !context.mounted) return;
      RecurrenceDeleteResult? result;
      final done = await runGuarded(context, () async => result = await recurrence.deleteOccurrence(bill.id, scope));
      if (!done || !context.mounted) return;
      Navigator.pop(context);
      showAppSnack(messenger, describeDeleteResult(result!));
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text('A conta sai das listas, mas o histórico de pagamentos é preservado e você pode desfazer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await runGuarded(context, () => svc.delete(bill.id));
    if (!done || !context.mounted) return;
    Navigator.pop(context);
    showAppSnack(messenger, 'Conta excluída', actionLabel: 'Desfazer', onAction: () => svc.restore(bill.id));
  }
}

/// Linha "Recorrência" com a frequência e o fim, vindos da regra.
class _RecurrenceInfo extends ConsumerWidget {
  const _RecurrenceInfo({required this.bill});
  final Bill bill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!bill.isRecurring) return const _Info('Recorrência', 'Não se repete');
    final rule = ref.watch(recurrenceRuleProvider(bill.recurringId!)).value;
    final text = rule == null
        ? 'Recorrência encerrada'
        : '${describeFrequency(rule.frequency, rule.interval)}${rule.end != null ? ' · até ${formatDay(rule.end!)}' : ''}';
    return _Info('Recorrência', text);
  }
}

class SectionLabelText extends StatelessWidget {
  const SectionLabelText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: AppText.label(context.colors.textSecondary));
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.cents, this.tone);
  final String label;
  final int cents;
  final Tone tone;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabelText(label),
        const SizedBox(height: Space.xs),
        MoneyText(cents, tone: tone),
      ]);
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs + 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: AppText.body(c.textSecondary))),
        Expanded(child: Text(value, style: AppText.body(c.textPrimary))),
      ]),
    );
  }
}
