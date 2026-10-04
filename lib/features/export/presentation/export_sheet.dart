import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/export_service.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/repo_base.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/app_segmented.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/export/csv.dart';
import '../../../domain/export/export_data.dart';
import '../../../domain/export/exporter.dart';

Future<void> showExportSheet(BuildContext context) => showAdaptiveSheet<void>(context, builder: (_) => const ExportSheet());

/// Exportação dos dados: escolha de formato, separador, conjuntos e itens excluídos. Nada sai do aparelho sem o usuário salvar.
class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key});

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  final _datasets = <ExportDataset>{ExportDataset.bills, ExportDataset.payments};
  var _delimiter = CsvDelimiter.comma;
  var _includeDeleted = false;
  var _busy = false;

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    String? message;
    var close = false;
    try {
      final outcome = await ref.read(exportServiceProvider).export(
            ExportOptions(datasets: _datasets, delimiter: _delimiter, includeDeleted: _includeDeleted),
          );
      close = outcome == ExportOutcome.saved;
      message = close ? 'Exportação salva.' : 'Exportação cancelada.';
    } on ValidationError catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Não foi possível exportar. Tente novamente.';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
    if (close) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.lg),
        children: [
          Text('Exportar dados', style: AppText.title(c.textPrimary)),
          const SizedBox(height: Space.xs),
          Text('Gera arquivos com os dados deste aparelho. Você escolhe onde salvar.', style: AppText.body(c.textSecondary)),
          const SizedBox(height: Space.lg),
          Text('Formato', style: AppText.label(c.textSecondary)),
          const SizedBox(height: Space.xs),
          Wrap(spacing: Space.xs, runSpacing: Space.xs, children: [
            for (final f in ExportFormat.values)
              ChoiceChip(
                key: Key('export-format-${f.name}'),
                label: Text(f.available ? f.label : '${f.label} · em breve'),
                selected: f == ExportFormat.csv,
                onSelected: f.available ? (_) {} : null,
              ),
          ]),
          const SizedBox(height: Space.lg),
          Text('Separador do CSV', style: AppText.label(c.textSecondary)),
          const SizedBox(height: Space.xs),
          AppSegmented<CsvDelimiter>(
            options: const [(CsvDelimiter.comma, 'Vírgula'), (CsvDelimiter.semicolon, 'Ponto e vírgula')],
            selected: _delimiter,
            onChanged: (v) => setState(() => _delimiter = v),
          ),
          const SizedBox(height: Space.xs),
          Text(
            _delimiter == CsvDelimiter.comma
                ? 'Decimais com ponto (1234.56). Bom para Google Planilhas e programas.'
                : 'Decimais com vírgula (1234,56). Abre direto no Excel em português.',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.lg),
          Text('Dados', style: AppText.label(c.textSecondary)),
          for (final d in ExportDataset.values)
            CheckboxListTile(
              key: Key('export-dataset-${d.name}'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(d.label),
              subtitle: Text(d.description),
              value: _datasets.contains(d),
              onChanged: (v) => setState(() => v == true ? _datasets.add(d) : _datasets.remove(d)),
            ),
          SwitchListTile(
            key: const Key('export-include-deleted'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Incluir itens excluídos'),
            subtitle: const Text('Adiciona a coluna excluido_em.'),
            value: _includeDeleted,
            onChanged: (v) => setState(() => _includeDeleted = v),
          ),
          const SizedBox(height: Space.sm),
          Text(
            'Os arquivos podem conter valores financeiros. Guarde-os em local seguro. Vários conjuntos viram um ZIP com um LEIA-ME.',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.md),
          FilledButton(
            key: const Key('export-submit'),
            onPressed: _datasets.isEmpty || _busy ? null : _export,
            child: Text(_busy ? 'Exportando…' : 'Exportar'),
          ),
        ],
      ),
    );
  }
}
