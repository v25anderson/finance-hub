import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../design_system/components/app_segmented.dart';
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
}) => showDialog<int>(
  context: context,
  builder: (_) => _AmountDialog(
    title: title,
    confirmLabel: confirmLabel,
    label: label,
    initialCents: initialCents,
    hint: hint,
  ),
);

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.confirmLabel,
    required this.label,
    this.initialCents,
    this.hint,
  });
  final String title, confirmLabel, label;
  final int? initialCents;
  final String? hint;
  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _form = GlobalKey<FormState>();
  late final _c = TextEditingController(
    text: widget.initialCents == null ? '' : centsToInput(widget.initialCents!),
  );
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ok() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, parseCents(_c.text));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: Text(widget.hint!),
            ),
          TextFormField(
            controller: _c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: widget.label,
              prefixText: 'R\$ ',
            ),
            onFieldSubmitted: (_) => _ok(),
            validator: (v) {
              final c = parseCents(v ?? '');
              return (c == null || c <= 0)
                  ? 'Informe um valor maior que zero'
                  : null;
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
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
Future<IncomeInput?> showAddIncomeDialog(BuildContext context) =>
    showDialog<IncomeInput>(
      context: context,
      builder: (_) => const _IncomeDialog(),
    );

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSegmented<IncomeKind>(
            options: const [
              (IncomeKind.extra, 'Renda extra'),
              (IncomeKind.other, 'Outras'),
            ],
            selected: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
            ),
            validator: (v) {
              final c = parseCents(v ?? '');
              return (c == null || c <= 0)
                  ? 'Informe um valor maior que zero'
                  : null;
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, IncomeInput(_kind, parseCents(_c.text)!));
          }
        },
        child: const Text('Adicionar'),
      ),
    ],
  );
}

class DefaultsInput {
  const DefaultsInput({
    required this.salaryCents,
    required this.extraCents,
    required this.savingsCents,
    required this.investmentCents,
  });
  final int salaryCents, extraCents, savingsCents, investmentCents;
}

/// Edita os valores padrão, que valem a partir do mês indicado (os meses anteriores não mudam).
Future<DefaultsInput?> showDefaultsDialog(
  BuildContext context, {
  required String fromLabel,
  required int salaryCents,
  required int extraCents,
  required int savingsCents,
  required int investmentCents,
}) => showDialog<DefaultsInput>(
  context: context,
  builder: (_) => _DefaultsDialog(
    fromLabel: fromLabel,
    salaryCents: salaryCents,
    extraCents: extraCents,
    savingsCents: savingsCents,
    investmentCents: investmentCents,
  ),
);

class _DefaultsDialog extends StatefulWidget {
  const _DefaultsDialog({
    required this.fromLabel,
    required this.salaryCents,
    required this.extraCents,
    required this.savingsCents,
    required this.investmentCents,
  });
  final String fromLabel;
  final int salaryCents, extraCents, savingsCents, investmentCents;
  @override
  State<_DefaultsDialog> createState() => _DefaultsDialogState();
}

class _DefaultsDialogState extends State<_DefaultsDialog> {
  final _form = GlobalKey<FormState>();
  late final _salary = TextEditingController(
    text: widget.salaryCents == 0 ? '' : centsToInput(widget.salaryCents),
  );
  late final _extra = TextEditingController(
    text: widget.extraCents == 0 ? '' : centsToInput(widget.extraCents),
  );
  late final _savings = TextEditingController(
    text: widget.savingsCents == 0 ? '' : centsToInput(widget.savingsCents),
  );
  late final _invest = TextEditingController(
    text: widget.investmentCents == 0
        ? ''
        : centsToInput(widget.investmentCents),
  );
  @override
  void dispose() {
    _salary.dispose();
    _extra.dispose();
    _savings.dispose();
    _invest.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if ((v ?? '').trim().isEmpty) return null; // vazio = 0
    final c = parseCents(v!);
    return (c == null || c < 0) ? 'Valor inválido' : null;
  }

  int _cents(TextEditingController c) =>
      c.text.trim().isEmpty ? 0 : parseCents(c.text)!;

  Widget _field(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: Space.md),
    child: TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixText: 'R\$ '),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Text(
                  'Vale a partir de ${widget.fromLabel}. Meses anteriores não mudam.',
                  key: const Key('defaults-from-note'),
                ),
              ),
              _field(_salary, 'Salário líquido padrão'),
              _field(_extra, 'Renda extra padrão'),
              _field(_savings, 'Meta de economia padrão'),
              _field(_invest, 'Investimento planejado padrão'),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(
              context,
              DefaultsInput(
                salaryCents: _cents(_salary),
                extraCents: _cents(_extra),
                savingsCents: _cents(_savings),
                investmentCents: _cents(_invest),
              ),
            );
          }
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}
