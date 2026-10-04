import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import '../../../domain/enums.dart';
import 'recurrence_dialogs.dart';
import '../../../design_system/components/app_segmented.dart';
import 'status_style.dart';
import 'ui_helpers.dart';

enum BillFormMode { create, edit, duplicate }

/// Abre o cadastro rápido. Em [BillFormMode.edit]/[BillFormMode.duplicate], [source] preenche o formulário.
/// Duplicar cria uma nova entidade (novo id) só ao salvar.
Future<String?> showBillForm(BuildContext context, {BillFormMode mode = BillFormMode.create, Bill? source}) =>
    showAdaptiveSheet<String>(context, builder: (_) => BillFormSheet(mode: mode, source: source));

class BillFormSheet extends ConsumerStatefulWidget {
  const BillFormSheet({super.key, required this.mode, this.source});
  final BillFormMode mode;
  final Bill? source;
  @override
  ConsumerState<BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends ConsumerState<BillFormSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _due;
  late String _categoryId;
  late ExpenseType _type;
  late bool _favorite;
  bool _saving = false;
  Frequency? _frequency; // nulo = não se repete (só na criação)
  final _interval = TextEditingController(text: '1');
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final s = widget.source;
    final today = ref.read(todayProvider);
    final shown = ref.read(selectedMonthProvider);
    _name = TextEditingController(text: s == null ? '' : (widget.mode == BillFormMode.duplicate ? '${s.name} (cópia)' : s.name));
    _amount = TextEditingController(text: s == null ? '' : centsToInput(s.plannedCents));
    _note = TextEditingController(text: s?.note ?? '');
    // Novo: hoje, se o mês exibido é o atual; senão o dia 1 do mês exibido.
    _due = s?.dueDate ?? (shown.year == today.year && shown.month == today.month ? today : DateTime(shown.year, shown.month));
    _categoryId = s?.categoryId ?? 'cat-outros';
    _type = s?.expenseType ?? ExpenseType.variable;
    _favorite = s?.favorite ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    _interval.dispose();
    super.dispose();
  }

  int get _intervalValue => int.tryParse(_interval.text.trim()) ?? 1;

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final svc = ref.read(billServiceProvider);
    final recurrence = ref.read(recurrenceServiceProvider);
    final cents = parseCents(_amount.text)!;
    final src = widget.source;
    String? id;
    var ok = false;

    if (widget.mode == BillFormMode.edit && src != null && src.isRecurring) {
      final dateChanged = dateOnly(_due) != dateOnly(src.dueDate);
      final scope = await showEditScopeDialog(context, allowFollowing: !dateChanged);
      if (scope == null || !mounted) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      id = src.id;
      ok = await runGuarded(context, () async {
        await recurrence.editOccurrence(src.id, scope,
            name: _name.text,
            plannedCents: cents,
            categoryId: _categoryId,
            expenseType: _type,
            favorite: _favorite,
            note: _note.text,
            dueDate: dateChanged ? _due : null);
      });
    } else {
      ok = await runGuarded(context, () async {
        if (widget.mode == BillFormMode.edit) {
          id = src!.id;
          await svc.update(id!,
              name: _name.text, plannedCents: cents, dueDate: _due, categoryId: _categoryId, expenseType: _type, favorite: _favorite, note: _note.text);
        } else if (widget.mode == BillFormMode.create && _frequency != null) {
          id = await recurrence.createRecurring(
              name: _name.text,
              amountCents: cents,
              firstDue: _due,
              categoryId: _categoryId,
              expenseType: _type,
              frequency: _frequency!,
              interval: _intervalValue,
              end: _end,
              favorite: _favorite);
        } else {
          id = await svc.create(
              name: _name.text, plannedCents: cents, dueDate: _due, categoryId: _categoryId, expenseType: _type, favorite: _favorite, note: _note.text);
        }
      });
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, id);
    } else {
      setState(() => _saving = false);
    }
  }

  String get _intervalUnit => switch (_frequency) {
        Frequency.weekly => 'semanas',
        Frequency.monthly => 'meses',
        Frequency.yearly => 'anos',
        Frequency.custom => 'dias',
        null => '',
      };

  Widget _recurrenceSection(BuildContext context) {
    final c = context.colors;
    final src = widget.source;
    if (widget.mode == BillFormMode.create) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<Frequency?>(
          key: const Key('recurrence-dropdown'),
          isExpanded: true,
          borderRadius: BorderRadius.circular(Radii.md),
          initialValue: _frequency,
          decoration: const InputDecoration(labelText: 'Recorrência'),
          items: const [
            DropdownMenuItem(value: null, child: Text('Não se repete')),
            DropdownMenuItem(value: Frequency.weekly, child: Text('Semanal')),
            DropdownMenuItem(value: Frequency.monthly, child: Text('Mensal')),
            DropdownMenuItem(value: Frequency.yearly, child: Text('Anual')),
            DropdownMenuItem(value: Frequency.custom, child: Text('Personalizado (a cada N dias)')),
          ],
          onChanged: (v) => setState(() {
            _frequency = v;
            if (v == Frequency.custom && _interval.text.trim() == '1') _interval.text = '30';
          }),
        ),
        if (_frequency != null) ...[
          const SizedBox(height: Space.md),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'A cada ($_intervalUnit)'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return (n == null || n < 1 || n > 999) ? 'Use de 1 a 999' : null;
                },
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.sm),
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _end ?? _due, firstDate: _due, lastDate: DateTime(2100));
                  if (d != null) setState(() => _end = d);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Termina em (opcional)',
                    suffixIcon: _end == null
                        ? const Icon(Icons.calendar_today_rounded, size: 18)
                        : IconButton(tooltip: 'Remover data final', icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _end = null)),
                  ),
                  child: Text(_end == null ? 'Sem fim' : formatDay(_end!)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: Space.xs),
          Text('Primeiro vencimento: ${formatDay(_due)}. As ocorrências futuras são criadas automaticamente.', style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
        ],
      ]);
    }
    final text = (widget.mode == BillFormMode.edit && src != null && src.isRecurring) ? 'Recorrente (escolha o alcance ao salvar)' : 'Não se repete';
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Recorrência', enabled: false),
      child: Text(text, style: AppText.body(c.textSecondary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final title = switch (widget.mode) {
      BillFormMode.create => 'Nova conta',
      BillFormMode.edit => 'Editar conta',
      BillFormMode.duplicate => 'Duplicar conta',
    };
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(title, style: AppText.title(c.textPrimary)),
        actions: [IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xl), children: [
          TextFormField(
            controller: _name,
            autofocus: widget.mode == BillFormMode.create,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
          ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
            validator: (v) {
              final cents = parseCents(v ?? '');
              return (cents == null || cents <= 0) ? 'Informe um valor maior que zero' : null;
            },
          ),
          const SizedBox(height: Space.md),
          InkWell(
            borderRadius: BorderRadius.circular(Radii.sm),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _due, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _due = d);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Vencimento', suffixIcon: Icon(Icons.calendar_today_rounded, size: 18)),
              child: Text(formatDay(_due)),
            ),
          ),
          const SizedBox(height: Space.md),
          DropdownButtonFormField<String>(
            isExpanded: true,
            borderRadius: BorderRadius.circular(Radii.md),
            initialValue: categories.any((x) => x.id == _categoryId) ? _categoryId : null,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [for (final cat in categories) DropdownMenuItem(value: cat.id, child: Text(cat.name))],
            onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
          ),
          const SizedBox(height: Space.md),
          Text('TIPO', style: AppText.label(c.textSecondary)),
          const SizedBox(height: Space.sm),
          AppSegmented<ExpenseType>(
            options: [for (final t in ExpenseType.values) (t, expenseTypeLabel(t))],
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: Space.md),
          _recurrenceSection(context),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favorita'),
            value: _favorite,
            onChanged: (v) => setState(() => _favorite = v),
          ),
          TextFormField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Observação'),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(onPressed: _saving ? null : _save, child: const Padding(padding: EdgeInsets.all(Space.sm), child: Text('Salvar'))),
        ]),
      ),
    );
  }
}
