import 'dart:convert';
import 'dart:typed_data';

/// Falha ao ler um backup (arquivo corrompido, de outro app ou de versão mais nova).
class BackupFormatError implements Exception {
  BackupFormatError(this.message);
  final String message;
  @override
  String toString() => 'BackupFormatError: $message';
}

/// Tabelas incluídas no backup, na ordem de inserção (respeita chaves estrangeiras).
/// Metadados de sincronização e conflitos são específicos do aparelho e ficam de fora.
const backupTables = <String>[
  'categories',
  'recurring_transactions',
  'transactions',
  'payments',
  'attachments',
  'incomes',
  'investments',
  'plannings',
  'month_configurations',
];

/// Envelope de um backup. O conteúdo das tabelas é opaco aqui; só contagens são expostas.
class BackupSnapshot {
  const BackupSnapshot({required this.createdAt, required this.deviceId, required this.schemaVersion, required this.tables, this.formatVersion = currentFormatVersion});

  static const formatName = 'finance-hub-backup';
  static const currentFormatVersion = 1;

  final int formatVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final String deviceId;
  final Map<String, List<Map<String, Object?>>> tables;

  /// Quantos registros por tabela (sem expor valores).
  Map<String, int> get counts => {for (final t in backupTables) t: tables[t]?.length ?? 0};

  int get totalRecords => counts.values.fold(0, (a, b) => a + b);

  Map<String, Object?> toJson() => {
        'format': formatName,
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'deviceId': deviceId,
        'counts': counts,
        'tables': {for (final t in backupTables) t: tables[t] ?? const []},
      };

  Uint8List encode() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  /// Lê e valida. [maxSchemaVersion] é o esquema do banco deste app: backups mais novos são recusados.
  static BackupSnapshot decode(List<int> bytes, {required int maxSchemaVersion}) {
    final Object? raw;
    try {
      raw = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw BackupFormatError('O arquivo não é um backup válido.');
    }
    if (raw is! Map<String, dynamic> || raw['format'] != formatName) throw BackupFormatError('O arquivo não é um backup do Finance Hub.');
    final fv = raw['formatVersion'];
    final sv = raw['schemaVersion'];
    if (fv is! int || sv is! int) throw BackupFormatError('Backup sem versão.');
    if (fv > currentFormatVersion) throw BackupFormatError('Backup criado por uma versão mais nova do app. Atualize o app.');
    if (sv > maxSchemaVersion) throw BackupFormatError('Backup criado por uma versão mais nova do app. Atualize o app.');
    final created = DateTime.tryParse('${raw['createdAt']}');
    final tablesRaw = raw['tables'];
    if (created == null || tablesRaw is! Map<String, dynamic>) throw BackupFormatError('Backup incompleto.');
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in backupTables) {
      final rows = tablesRaw[t];
      if (rows is! List) throw BackupFormatError('Backup incompleto: falta "$t".');
      tables[t] = [
        for (final r in rows)
          if (r is Map<String, dynamic>) r else throw BackupFormatError('Backup corrompido em "$t".'),
      ];
    }
    return BackupSnapshot(createdAt: created, deviceId: '${raw['deviceId']}', schemaVersion: sv, formatVersion: fv, tables: tables);
  }
}
