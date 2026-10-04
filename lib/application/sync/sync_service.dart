import '../../data/db/app_database.dart';
import '../../data/sync/sync_repository.dart';
import '../../domain/enums.dart';
import '../../domain/sync/change_file.dart';
import 'sync_transport.dart';

/// Sincronização entre aparelhos: lê o que os outros publicaram, aplica com merge de três vias e publica o que mudou aqui.
class SyncService {
  SyncService({required this.repository, required this.transport, required this.db, required this.clock});

  final SyncRepository repository;
  final SyncTransport transport;
  final AppDatabase db;
  final DateTime Function() clock;

  var _running = false;

  /// Escolhe os arquivos a ler: só de outros aparelhos, em sequência sem buracos a partir do cursor.
  /// Aparelho nunca visto começa no menor arquivo disponível. O resto aguarda (consistência eventual do Drive).
  static ({List<RemoteChangeFile> files, int waiting}) select(List<RemoteChangeFile> all, SyncCursor cursor, String ownDevice) {
    final byDevice = <String, Map<int, RemoteChangeFile>>{};
    for (final f in all.where((f) => f.deviceId != ownDevice)) {
      final m = byDevice.putIfAbsent(f.deviceId, () => {});
      final prev = m[f.seq];
      if (prev == null || f.modifiedAt.isAfter(prev.modifiedAt)) m[f.seq] = f; // número repetido (envio refeito): vale o mais recente
    }
    final chosen = <RemoteChangeFile>[];
    var waiting = 0;
    for (final e in byDevice.entries) {
      final seqs = e.value.keys.toList()..sort();
      var next = cursor.peers.containsKey(e.key) ? cursor.peers[e.key]! + 1 : seqs.first;
      for (final s in seqs.where((s) => s >= next)) {
        if (s == next) {
          chosen.add(e.value[s]!);
          next++;
        } else {
          waiting++;
        }
      }
    }
    chosen.sort((a, b) => a.modifiedAt != b.modifiedAt ? a.modifiedAt.compareTo(b.modifiedAt) : '${a.deviceId}${a.seq}'.compareTo('${b.deviceId}${b.seq}'));
    return (files: chosen, waiting: waiting);
  }

  Future<SyncReport> sync() async {
    if (_running) return const SyncReport();
    _running = true;
    await repository.setState(SyncState.syncing);
    try {
      final own = await db.currentDeviceId();
      final cursor = await repository.cursor();
      final sel = select(await transport.listChangeFiles(), cursor, own);

      // baixa e valida tudo antes de aplicar qualquer coisa
      final parsed = <ChangeFile>[];
      for (final f in sel.files) {
        parsed.add(ChangeFile.decode(await transport.downloadChangeFile(f.id), maxSchemaVersion: db.schemaVersion));
      }
      final peers = <String, int>{};
      for (final f in parsed) {
        if (f.seq > (peers[f.deviceId] ?? 0)) peers[f.deviceId] = f.seq;
      }
      var report = await repository.apply(parsed, peers);

      final dirty = await repository.collectDirty();
      var pushed = 0;
      if (dirty.isNotEmpty) {
        final seq = (await repository.cursor()).ownSeq + 1;
        final file = ChangeFile(
          deviceId: own,
          seq: seq,
          schemaVersion: db.schemaVersion,
          createdAt: clock(),
          changes: [for (final d in dirty) RecordChange(d.table, d.row)],
        );
        await transport.uploadChangeFile(own, seq, file.encode());
        await repository.markPushed(dirty, seq);
        pushed = dirty.length;
      }
      report = report.copyWith(pushed: pushed, waiting: sel.waiting);
      await repository.markSynced();
      return report;
    } catch (_) {
      await repository.setState(SyncState.error);
      rethrow;
    } finally {
      _running = false;
    }
  }
}
