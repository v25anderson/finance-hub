import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/enums.dart';

/// Diálogo de um valor em reais. Retorna centavos (> 0) ou null se cancelado.
Future<int?> showAmountDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String label = 'Valor',
  int? initialCents,
  String? hint,
}) =>
    showDialog<int>(
      context: context,
      builder: (_) => _AmountDialog(title: title, confirmLabel: confirmLabel, label: label, initialCents: initialCents, hint: hint),
    );

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.title, required this.confirmLabel, required this.label, this.initialCents, this.hint});
  final String title, confirmLabel, label;
  final int? initialCents;
  final String? hint;
  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _form = GlobalKey<FormState>();
  late final _c = TextEditingController(text: widget.initialCents == null ? '' : centsToInput(widget.initialCents!));
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ok() {
    if (_form.currentState!.validate()) Navigator.pop(context, parseCents(_c.text));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.hint != null) Padding(padding: const EdgeInsets.only(bottom: Space.md), child: Text(widget.hint!)),
            TextFormField(
              controller: _c,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: widget.label, prefixText: 'R\$ ', border: const OutlineInputBorder()),
              onFieldSubmitted: (_) => _ok(),
              validator: (v) {
                final c = parseCents(v ?? '');
                return (c == null || c <= 0) ? 'Informe um valor maior que zero' : null;
              },
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: _ok, child: Text(widget.confirmLabel)),
        ],
      );
}

class IncomeInput {
  const IncomeInput(this.kind, this.cents);
  final IncomeKind kind;
  final int cents;
}

/// Lançar uma renda do mês (extra ou outras).
Future<IncomeInput?> showAddIncomeDialog(BuildContext context) => showDialog<IncomeInput>(context: context, builder: (_) => const _IncomeDialog());

class _IncomeDialog extends StatefulWidget {
  const _IncomeDialog();
  @override
  State<_IncomeDialog> createState() => _IncomeDialogState();
}

class _IncomeDialogState extends State<_IncomeDialog> {
  final _form = GlobalKey<FormState>();
  final _c = TextEditingController();
  IncomeKind _kind = IncomeKind.extra;
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Adicionar renda'),
        content: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            SegmentedButton<IncomeKind>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: IncomeKind.extra, label: Text('Renda extra')),
                ButtonSegment(value: IncomeKind.other, label: Text('Outras')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: Space.md),
            TextFormField(
              controller: _c,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', border: OutlineInputBorder()),
              validator: (v) {
                final c = parseCents(v ?? '');
                return (c == null || c <= 0) ? 'Informe um valor maior que zero' : null;
              },
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) Navigator.pop(context, IncomeInput(_kind, parseCents(_c.text)!));
            },
            child: const Text('Adicionar'),
          ),
        ],
      );
}

class DefaultsInput {
  const DefaultsInput({required this.salaryCents, required this.extraCents, required this.investmentCents});
  final int salaryCents, extraCents, investmentCents;
}

/// Edita os valores padrão (valem para todos os meses sem personalização).
Future<DefaultsInput?> showDefaultsDialog(
  BuildContext context, {
  required int salaryCents,
  required int extraCents,
  required int investmentCents,
}) =>
    showDialog<DefaultsInput>(
      context: context,
      builder: (_) => _DefaultsDialog(salaryCents: salaryCents, extraCents: extraCents, investmentCents: investmentCents),
    );

class _DefaultsDialog extends StatefulWidget {
  const _DefaultsDialog({required this.salaryCents, required this.extraCents, required this.investmentCents});
  final int salaryCents, extraCents, investmentCents;
  @override
  State<_DefaultsDialog> createState() => _DefaultsDialogState();
}

class _DefaultsDialogState extends State<_DefaultsDialog> {
  final _form = GlobalKey<FormState>();
  late final _salary = TextEditingController(text: widget.salaryCents == 0 ? '' : centsToInput(widget.salaryCents));
  late final _extra = TextEditingController(text: widget.extraCents == 0 ? '' : centsToInput(widget.extraCents));
  late final _invest = TextEditingController(text: widget.investmentCents == 0 ? '' : centsToInput(widget.investmentCents));
  @override
  void dispose() {
    _salary.dispose();
    _extra.dispose();
    _invest.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if ((v ?? '').trim().isEmpty) return null; // vazio = 0
    final c = parseCents(v!);
    return (c == null || c < 0) ? 'Valor inválido' : null;
  }

  int _cents(TextEditingController c) => c.text.trim().isEmpty ? 0 : parseCents(c.text)!;

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: Space.md),
        child: TextFormField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, prefixText: 'R\$ ', border: const OutlineInputBorder()),
          validator: _validate,
        ),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Valores padrão'),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: Space.md),
                  child: Text('Valem para todos os meses que não foram personalizados. Deixe vazio para zero.'),
                ),
                _field(_salary, 'Salário líquido padrão'),
                _field(_extra, 'Renda extra padrão'),
                _field(_invest, 'Investimento planejado padrão'),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                Navigator.pop(context, DefaultsInput(salaryCents: _cents(_salary), extraCents: _cents(_extra), investmentCents: _cents(_invest)));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
}
