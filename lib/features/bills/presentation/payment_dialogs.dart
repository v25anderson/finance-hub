import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../domain/bill.dart';

class PaymentInput {
  const PaymentInput({required this.amountCents, required this.paidAt, required this.note});
  final int amountCents;
  final DateTime paidAt;
  final String note;
}

/// Diálogo de pagamento. Em modo "total", o valor é fixo (o restante); em "parcial", o usuário informa.
Future<PaymentInput?> showPaymentDialog(
  BuildContext context, {
  required Bill bill,
  required bool total,
  required DateTime now,
}) =>
    showDialog<PaymentInput>(
      context: context,
      builder: (_) => _PaymentDialog(bill: bill, total: total, now: now),
    );

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.bill, required this.total, required this.now});
  final Bill bill;
  final bool total;
  final DateTime now;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date = DateTime(widget.now.year, widget.now.month, widget.now.day);
  late TimeOfDay _time = TimeOfDay(hour: widget.now.hour, minute: widget.now.minute);

  @override
  void initState() {
    super.initState();
    if (widget.total) _amount.text = centsToInput(widget.bill.remainingCents);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _cents => parseCents(_amount.text);

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final paidAt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute).toUtc();
    Navigator.pop(context, PaymentInput(amountCents: _cents!, paidAt: paidAt, note: _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final entered = _cents;
    final excess = entered != null && entered > bill.remainingCents ? entered - bill.remainingCents : 0;
    return AlertDialog(
      title: Text(widget.total ? 'Marcar como pago' : 'Registrar pagamento'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${bill.name} · restam ${formatCents(bill.remainingCents)}'),
              const SizedBox(height: Space.md),
              TextFormField(
                controller: _amount,
                autofocus: !widget.total,
                readOnly: widget.total,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final c = parseCents(v ?? '');
                  if (c == null || c <= 0) return 'Informe um valor maior que zero';
                  return null;
                },
              ),
              if (excess > 0)
                Padding(
                  padding: const EdgeInsets.only(top: Space.sm),
                  child: Text('Excede o restante em ${formatCents(excess)}; será registrado como excedente.'),
                ),
              const SizedBox(height: Space.md),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(formatDay(_date)),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                  ),
                ),
                const SizedBox(width: Space.sm),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 16),
                  label: Text(_time.format(context)),
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: _time);
                    if (t != null) setState(() => _time = t);
                  },
                ),
              ]),
              const SizedBox(height: Space.md),
              TextFormField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Observação (opcional)'),
              ),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: Text(widget.total ? 'Confirmar pagamento' : 'Registrar')),
      ],
    );
  }
}
