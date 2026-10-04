import 'package:flutter/material.dart';

import '../../../design_system/tokens/spacing.dart';
import '../../../domain/recurrence.dart';

/// Escolha de escopo ao salvar a edição de uma ocorrência recorrente.
Future<EditScope?> showEditScopeDialog(BuildContext context, {required bool allowFollowing}) => showDialog<EditScope>(
      context: context,
      builder: (_) => _ScopeDialog<EditScope>(
        title: 'Aplicar a quais ocorrências?',
        confirmLabel: 'Salvar',
        initial: EditScope.thisOnly,
        options: [
          const _Option(EditScope.thisOnly, 'Somente esta ocorrência', 'As demais continuam como estão.'),
          _Option(
            EditScope.thisAndFollowing,
            'Esta e as próximas',
            allowFollowing
                ? 'Muda a regra daqui para frente. Passadas, editadas à mão e com pagamento não mudam.'
                : 'Indisponível ao mudar o vencimento (use "somente esta").',
            enabled: allowFollowing,
          ),
        ],
      ),
    );

/// Escolha de escopo ao excluir uma ocorrência recorrente. Descreve o que é preservado.
Future<DeleteScope?> showDeleteScopeDialog(BuildContext context) => showDialog<DeleteScope>(
      context: context,
      builder: (_) => _ScopeDialog<DeleteScope>(
        title: 'Excluir recorrência',
        confirmLabel: 'Excluir',
        initial: DeleteScope.thisOnly,
        options: const [
          _Option(DeleteScope.thisOnly, 'Excluir apenas esta ocorrência', 'Não será recriada. As outras continuam.'),
          _Option(DeleteScope.thisAndFollowing, 'Excluir esta e as próximas', 'A recorrência termina antes desta. Anteriores e contas com pagamento ficam.'),
          _Option(DeleteScope.all, 'Excluir toda a recorrência', 'Remove as futuras sem pagamento e encerra a regra. O passado e o que já tem pagamento ficam no histórico.'),
        ],
      ),
    );

class _Option<T> {
  const _Option(this.value, this.title, this.subtitle, {this.enabled = true});
  final T value;
  final String title, subtitle;
  final bool enabled;
}

class _ScopeDialog<T> extends StatefulWidget {
  const _ScopeDialog({required this.title, required this.confirmLabel, required this.initial, required this.options});
  final String title, confirmLabel;
  final T initial;
  final List<_Option<T>> options;
  @override
  State<_ScopeDialog<T>> createState() => _ScopeDialogState<T>();
}

class _ScopeDialogState<T> extends State<_ScopeDialog<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true, // as opções têm legendas longas: precisa rolar em telas baixas
        title: Text(widget.title),
        content: SizedBox(
          width: 400,
          child: RadioGroup<T>(
            groupValue: _value,
            onChanged: (v) => setState(() => _value = v ?? _value),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final o in widget.options)
                RadioListTile<T>(
                  contentPadding: EdgeInsets.zero,
                  value: o.value,
                  enabled: o.enabled,
                  title: Text(o.title),
                  subtitle: Padding(padding: const EdgeInsets.only(top: Space.xs), child: Text(o.subtitle)),
                ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, _value), child: Text(widget.confirmLabel)),
        ],
      );
}

/// Resumo do que foi mantido (nada é apagado em silêncio).
String describeDeleteResult(RecurrenceDeleteResult r) {
  final parts = <String>[r.deleted == 1 ? '1 ocorrência excluída' : '${r.deleted} ocorrências excluídas'];
  if (r.keptPast > 0) parts.add('${r.keptPast} anteriores mantidas');
  if (r.keptWithPayments > 0) parts.add('${r.keptWithPayments} com pagamento mantidas');
  return parts.join(' · ');
}
