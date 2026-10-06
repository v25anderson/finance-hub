import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/sync/sync_repository.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/sync/merge.dart';

Future<void> showConflictsSheet(BuildContext context) => showAdaptiveSheet<void>(context, builder: (_) => const ConflictsSheet());

const _entityLabels = {
  'categories': 'Categoria',
  'recurring_transactions': 'Recorrência',
  'transactions': 'Conta',
  'payments': 'Pagamento',
  'incomes': 'Renda',
  'investments': 'Investimento',
  'plannings': 'Planejamento (legado)',
  'planning_defaults_versions': 'Padrões do planejamento',
  'month_configurations': 'Mês personalizado',
};

const _fieldLabels = {
  'name': 'Nome',
  'effectiveFrom': 'Vale a partir de',
  'plannedAmountCents': 'Valor previsto',
  'dueDate': 'Vencimento',
  'categoryId': 'Categoria',
  'expenseType': 'Tipo',
  'favorite': 'Favorita',
  'note': 'Observação',
  'canceledAt': 'Cancelada em',
  'deletedAt': 'Excluída em',
  'amountCents': 'Valor',
  'paidAt': 'Pago em',
  'description': 'Descrição',
  'received': 'Recebida',
  'kind': 'Tipo',
  'plannedCents': 'Planejado',
  'realizedCents': 'Realizado',
  'color': 'Cor',
  'icon': 'Ícone',
  'baseAmountCents': 'Valor base',
  'endDate': 'Fim',
  'startDate': 'Início',
  'frequency': 'Frequência',
  'intervalCount': 'Intervalo',
  'defaultSalaryCents': 'Salário padrão',
  'defaultExtraIncomeCents': 'Renda extra padrão',
  'defaultSavingsGoalCents': 'Meta de economia padrão',
  'defaultInvestmentCents': 'Investimento padrão',
  'salaryCents': 'Salário',
  'extraIncomeCents': 'Renda extra',
  'savingsGoalCents': 'Meta de economia',
  'investmentCents': 'Investimento',
};

String fieldLabel(String key) => _fieldLabels[key] ?? key;

String fieldValue(String key, Object? v) {
  if (v == null) return '—';
  if (key.endsWith('Cents') && v is int) return formatCents(v);
  if (key.endsWith('At') && v is int) return formatDateTime(DateTime.fromMillisecondsSinceEpoch(v, isUtc: true));
  if (v is bool) return v ? 'Sim' : 'Não';
  final s = '$v';
  return s.isEmpty ? '(vazio)' : s;
}

/// Registros que mudaram nos dois aparelhos de forma incompatível. Nada é decidido sem o usuário.
class ConflictsSheet extends ConsumerWidget {
  const ConflictsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final conflicts = ref.watch(openConflictsProvider).value ?? const <SyncConflictRow>[];
    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.lg),
        children: [
          Text('Conflitos de sincronização', style: AppText.title(c.textPrimary)),
          const SizedBox(height: Space.xs),
          Text('Alterado nos dois aparelhos. Escolha qual vale; até lá nada é sobrescrito.', style: AppText.body(c.textSecondary)),
          const SizedBox(height: Space.lg),
          if (conflicts.isEmpty) Text('Nenhum conflito.', key: const Key('conflicts-empty'), style: AppText.body(c.textSecondary)),
          for (final k in conflicts) _ConflictCard(k),
        ],
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard(this.conflict);
  final SyncConflictRow conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final local = Map<String, Object?>.from(jsonDecode(conflict.localJson) as Map);
    final remote = Map<String, Object?>.from(jsonDecode(conflict.remoteJson) as Map);
    final fields = differingFields(local, remote);
    final title = '${_entityLabels[conflict.entity] ?? conflict.entity}: ${local['name'] ?? local['description'] ?? remote['name'] ?? remote['description'] ?? ''}'.trim();
    Future<void> choose(ConflictChoice choice) => ref.read(syncRepositoryProvider).resolve(conflict.id, choice);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: AppCard(
        key: Key('conflict-${conflict.id}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.headline(c.textPrimary)),
          const SizedBox(height: Space.sm),
          for (final f in fields)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fieldLabel(f), style: AppText.label(c.textSecondary)),
                Text('Este aparelho: ${fieldValue(f, local[f])}'),
                Text('Outro aparelho: ${fieldValue(f, remote[f])}'),
              ]),
            ),
          const SizedBox(height: Space.sm),
          Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
            FilledButton(key: Key('conflict-keep-${conflict.id}'), onPressed: () => choose(ConflictChoice.keepLocal), child: const Text('Manter este aparelho')),
            OutlinedButton(key: Key('conflict-remote-${conflict.id}'), onPressed: () => choose(ConflictChoice.useRemote), child: const Text('Usar o outro')),
          ]),
        ]),
      ),
    );
  }
}
