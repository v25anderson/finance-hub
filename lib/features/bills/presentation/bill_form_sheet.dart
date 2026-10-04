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
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final svc = ref.read(billServiceProvider);
    final cents = parseCents(_amount.text)!;
    String? id;
    final ok = await runGuarded(context, () async {
      if (widget.mode == BillFormMode.edit) {
        id = widget.source!.id;
        await svc.update(id!,
            name: _name.text, plannedCents: cents, dueDate: _due, categoryId: _categoryId, expenseType: _type, favorite: _favorite, note: _note.text);
      } else {
        id = await svc.create(
            name: _name.text, plannedCents: cents, dueDate: _due, categoryId: _categoryId, expenseType: _type, favorite: _favorite, note: _note.text);
      }
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, id);
    } else {
      setState(() => _saving = false);
    }
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
            decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
          ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(labelText: 'Vencimento', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today, size: 18)),
              child: Text(formatDay(_due)),
            ),
          ),
          const SizedBox(height: Space.md),
          DropdownButtonFormField<String>(
            initialValue: categories.any((x) => x.id == _categoryId) ? _categoryId : null,
            decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
            items: [for (final cat in categories) DropdownMenuItem(value: cat.id, child: Text(cat.name))],
            onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
          ),
          const SizedBox(height: Space.md),
          Text('TIPO', style: AppText.label(c.textSecondary)),
          const SizedBox(height: Space.sm),
          SegmentedButton<ExpenseType>(
            showSelectedIcon: false,
            segments: [for (final t in ExpenseType.values) ButtonSegment(value: t, label: Text(expenseTypeLabel(t)))],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: Space.md),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Recorrência', border: OutlineInputBorder(), enabled: false),
            child: Text('Não se repete (recorrências chegam na Fase 5)', style: AppText.body(c.textSecondary)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favorita'),
            value: _favorite,
            onChanged: (v) => setState(() => _favorite = v),
          ),
          TextFormField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Observação', border: OutlineInputBorder()),
          ),
          const SizedBox(height: Space.lg),
          FilledButton(onPressed: _saving ? null : _save, child: const Padding(padding: EdgeInsets.all(Space.sm), child: Text('Salvar'))),
        ]),
      ),
    );
  }
}
