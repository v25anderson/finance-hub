import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../domain/month_plan.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../bills/presentation/ui_helpers.dart';
import '../../shared/presentation/period_selector.dart';
import '../../../design_system/components/app_snack.dart';

/// "Personalizar este mês": valores só deste mês. Campo vazio = usa o padrão. Os demais meses não mudam.
class MonthOverrideCard extends ConsumerStatefulWidget {
  const MonthOverrideCard({super.key});
  @override
  ConsumerState<MonthOverrideCard> createState() => _MonthOverrideCardState();
}

class _MonthOverrideCardState extends ConsumerState<MonthOverrideCard> {
  /// Escolha do usuário enquanto edita; nulo = seguir o que está salvo. Reinicia ao trocar de mês.
  bool? _userOn;
  String? _forMonth;

  @override
  Widget build(BuildContext context) {
    final ym = ref.watch(selectedYearMonthProvider);
    if (_forMonth != ym) {
      _forMonth = ym;
      _userOn = null;
    }
    final config = ref.watch(monthConfigProvider(ym)).value;
    final defaults = ref.watch(defaultsTimelineProvider).value?.atOrZero(ym);
    final saved =
        config != null &&
        (config.salaryCents != null ||
            config.extraIncomeCents != null ||
            config.savingsGoalCents != null ||
            config.investmentCents != null);
    final on = _userOn ?? saved;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Planejamento do mês'),
          const SizedBox(height: Space.sm),
          const Align(alignment: Alignment.centerLeft, child: PeriodSelector()),
          const SizedBox(height: Space.sm),
          // ListTile precisa de um Material próprio quando o ancestral tem cor (o cartão).
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              key: const Key('customize-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Personalizar este mês'),
              value: on,
              onChanged: (v) => _toggle(v, ym, saved),
            ),
          ),
          if (on && defaults != null)
            _OverrideForm(
              key: ValueKey('$ym-${config?.version}'),
              yearMonth: ym,
              config: config,
              defaults: defaults,
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(bool v, String ym, bool saved) async {
    if (v) {
      setState(() => _userOn = true);
      return;
    }
    setState(() => _userOn = false);
    if (saved) {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await runGuarded(
        context,
        () => ref.read(planningServiceProvider).clearMonth(ym),
      );
      if (ok && mounted) {
        showAppSnack(messenger, 'Este mês voltou a usar os valores padrão.');
      }
    }
  }
}

class _OverrideForm extends ConsumerStatefulWidget {
  const _OverrideForm({
    super.key,
    required this.yearMonth,
    required this.config,
    required this.defaults,
  });
  final String yearMonth;
  final MonthConfigRow? config;
  final PlanningDefaults defaults;
  @override
  ConsumerState<_OverrideForm> createState() => _OverrideFormState();
}

class _OverrideFormState extends ConsumerState<_OverrideForm> {
  final _form = GlobalKey<FormState>();
  late final _salary = TextEditingController(
    text: _fmt(widget.config?.salaryCents),
  );
  late final _extra = TextEditingController(
    text: _fmt(widget.config?.extraIncomeCents),
  );
  late final _savings = TextEditingController(
    text: _fmt(widget.config?.savingsGoalCents),
  );
  late final _invest = TextEditingController(
    text: _fmt(widget.config?.investmentCents),
  );

  static String _fmt(int? v) => v == null ? '' : centsToInput(v);

  @override
  void dispose() {
    _salary.dispose();
    _extra.dispose();
    _savings.dispose();
    _invest.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) =>
      c.text.trim().isEmpty ? null : parseCents(c.text);

  String? _validate(String? v) {
    if ((v ?? '').trim().isEmpty) return null; // vazio = usa o padrão
    final c = parseCents(v!);
    return (c == null || c < 0) ? 'Valor inválido' : null;
  }

  Widget _field(TextEditingController c, String label, int defaultCents) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Space.md),
        child: TextFormField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            prefixText: 'R\$ ',
            hintText: 'Padrão: ${formatCents(defaultCents)}',
          ),
          validator: _validate,
        ),
      );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await runGuarded(
      context,
      () => ref
          .read(planningServiceProvider)
          .setMonthOverrides(
            widget.yearMonth,
            salaryCents: _parse(_salary),
            extraIncomeCents: _parse(_extra),
            savingsGoalCents: _parse(_savings),
            investmentCents: _parse(_invest),
          ),
    );
    if (ok && mounted) {
      showAppSnack(messenger, 'Planejamento do mês salvo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = widget.defaults;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Space.sm),
          Text(
            'Deixe em branco o que deve seguir o padrão.',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.md),
          _field(_salary, 'Salário líquido', d.salaryCents),
          _field(_extra, 'Renda extra', d.extraIncomeCents),
          _field(_savings, 'Meta de economia', d.savingsGoalCents),
          _field(_invest, 'Investimento planejado', d.investmentCents),
          FilledButton(onPressed: _save, child: const Text('Salvar este mês')),
        ],
      ),
    );
  }
}
