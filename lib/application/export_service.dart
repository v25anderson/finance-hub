import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../core/dates.dart';
import '../data/repositories/export_repository.dart';
import '../data/repositories/repo_base.dart';
import '../domain/export/csv_exporter.dart';
import '../domain/export/exporter.dart';
import 'file_saver.dart';

enum ExportOutcome { saved, cancelled }

/// Orquestra a exportação: lê os dados, gera os arquivos do formato, empacota (ZIP se houver mais de um) e entrega.
class ExportService {
  ExportService({required this.repository, required this.saver, required this.clock, List<DataExporter>? exporters})
      : _exporters = {for (final e in exporters ?? const [CsvExporter()]) e.format: e};

  final ExportRepository repository;
  final FileSaver saver;
  final DateTime Function() clock;
  final Map<ExportFormat, DataExporter> _exporters;

  /// Gera o arquivo final sem entregá-lo (usado também em testes).
  Future<ExportFile> build(ExportOptions options) async {
    if (options.datasets.isEmpty) throw ValidationError('Selecione ao menos um conjunto de dados.');
    final exporter = _exporters[options.format];
    if (exporter == null || !options.format.available) throw ValidationError('Formato ainda não disponível.');

    final now = clock();
    final data = await repository.load(exportedAt: now, includeDeleted: options.includeDeleted);
    final files = exporter.export(data, options);
    final stamp = isoDate(now);

    if (files.length == 1) {
      final f = files.single;
      final dot = f.name.lastIndexOf('.');
      return ExportFile(name: '${f.name.substring(0, dot)}_$stamp${f.name.substring(dot)}', bytes: f.bytes, mime: f.mime);
    }

    final archive = Archive();
    for (final f in files) {
      archive.addFile(ArchiveFile(f.name, f.bytes.length, f.bytes));
    }
    final readme = const CsvExporter().readme(data, options, files).bytes;
    archive.addFile(ArchiveFile('LEIA-ME.txt', readme.length, readme));
    final zip = ZipEncoder().encode(archive);
    return ExportFile(name: 'finance_hub_$stamp.zip', bytes: Uint8List.fromList(zip), mime: 'application/zip');
  }

  Future<ExportOutcome> export(ExportOptions options) async {
    final file = await build(options);
    final saved = await saver.save(fileName: file.name, bytes: file.bytes, mime: file.mime);
    return saved ? ExportOutcome.saved : ExportOutcome.cancelled;
  }
}
