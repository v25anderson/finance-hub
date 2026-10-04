import 'dart:convert';
import 'dart:typed_data';

import 'merge.dart';

class SyncFormatError implements Exception {
  SyncFormatError(this.message);
  final String message;
  @override
  String toString() => 'SyncFormatError: $message';
}

/// Tabelas sincronizadas, na ordem de aplicação (pais antes dos filhos). Comprovantes ficam de fora:
/// o caminho local é específico do aparelho e o recurso ainda não existe.
const syncTables = <String>[
  'categories',
  'recurring_transactions',
  'transactions',
  'payments',
  'incomes',
  'investments',
  'plannings',
  'month_configurations',
];

class RecordChange {
  const RecordChange(this.table, this.row);
  final String table;
  final Fields row;
  String get id => row['id'] as String;
}

/// Arquivo de mudanças de um aparelho: cópias completas dos registros alterados desde a última sincronização.
/// Estado completo (não operações): aplicar duas vezes dá o mesmo resultado.
class ChangeFile {
  const ChangeFile({required this.deviceId, required this.seq, required this.schemaVersion, required this.createdAt, required this.changes});

  static const formatName = 'finance-hub-sync';
  static const currentFormatVersion = 1;

  final String deviceId;
  final int seq;
  final int schemaVersion;
  final DateTime createdAt;
  final List<RecordChange> changes;

  Uint8List encode() => Uint8List.fromList(utf8.encode(jsonEncode({
        'format': formatName,
        'formatVersion': currentFormatVersion,
        'schemaVersion': schemaVersion,
        'deviceId': deviceId,
        'seq': seq,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'changes': [for (final c in changes) {'table': c.table, 'row': c.row}],
      })));

  static ChangeFile decode(List<int> bytes, {required int maxSchemaVersion}) {
    final Object? raw;
    try {
      raw = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw SyncFormatError('Arquivo de sincronização inválido.');
    }
    if (raw is! Map<String, dynamic> || raw['format'] != formatName) throw SyncFormatError('Arquivo de sincronização inválido.');
    final fv = raw['formatVersion'], sv = raw['schemaVersion'], seq = raw['seq'], dev = raw['deviceId'];
    if (fv is! int || sv is! int || seq is! int || dev is! String) throw SyncFormatError('Arquivo de sincronização incompleto.');
    if (fv > currentFormatVersion || sv > maxSchemaVersion) throw SyncFormatError('Há dados de uma versão mais nova do app. Atualize o app para sincronizar.');
    final created = DateTime.tryParse('${raw['createdAt']}');
    final list = raw['changes'];
    if (created == null || list is! List) throw SyncFormatError('Arquivo de sincronização incompleto.');
    final changes = <RecordChange>[];
    for (final c in list) {
      if (c is! Map<String, dynamic> || c['table'] is! String || c['row'] is! Map<String, dynamic> || !syncTables.contains(c['table'])) {
        throw SyncFormatError('Arquivo de sincronização corrompido.');
      }
      final row = Map<String, Object?>.from(c['row'] as Map);
      if (row['id'] is! String) throw SyncFormatError('Arquivo de sincronização corrompido.');
      changes.add(RecordChange(c['table'] as String, row));
    }
    return ChangeFile(deviceId: dev, seq: seq, schemaVersion: sv, createdAt: created, changes: changes);
  }
}

/// Posição de leitura: último arquivo aplicado de cada outro aparelho e nosso próximo número.
class SyncCursor {
  const SyncCursor({this.ownSeq = 0, this.peers = const {}});
  final int ownSeq;
  final Map<String, int> peers;

  SyncCursor copyWith({int? ownSeq, Map<String, int>? peers}) => SyncCursor(ownSeq: ownSeq ?? this.ownSeq, peers: peers ?? this.peers);

  String encode() => jsonEncode({'ownSeq': ownSeq, 'peers': peers});

  static SyncCursor decode(String? s) {
    if (s == null || s.isEmpty) return const SyncCursor();
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return SyncCursor(ownSeq: m['ownSeq'] as int? ?? 0, peers: {for (final e in (m['peers'] as Map? ?? const {}).entries) '${e.key}': e.value as int});
    } catch (_) {
      return const SyncCursor();
    }
  }
}
