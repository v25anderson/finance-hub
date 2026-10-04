import 'dart:typed_data';

import '../data/backup/backup_repository.dart';
import '../domain/backup/snapshot.dart';
import 'drive/drive_storage.dart';

/// Guarda uma cópia local antes de uma operação destrutiva (restauração).
abstract interface class SafetyCopyStore {
  Future<void> save(String name, Uint8List bytes);
}

/// O que há dentro de um backup remoto, sem expor valores.
class BackupPreview {
  const BackupPreview({required this.remote, required this.createdAt, required this.counts});
  final RemoteBackup remote;
  final DateTime createdAt;
  final Map<String, int> counts;
  int get total => counts.values.fold(0, (a, b) => a + b);
}

/// Backup manual dos dados para o Google Drive e restauração a partir dele.
class BackupService {
  BackupService({required this.repository, required this.storage, required this.safety, required this.clock});

  final BackupRepository repository;
  final DriveStorage storage;
  final SafetyCopyStore safety;
  final DateTime Function() clock;

  static String _stamp(DateTime d) {
    String t(int n, [int w = 2]) => n.toString().padLeft(w, '0');
    final u = d.toUtc();
    return '${t(u.year, 4)}${t(u.month)}${t(u.day)}_${t(u.hour)}${t(u.minute)}${t(u.second)}';
  }

  /// Nome único por segundo: um backup nunca sobrescreve outro.
  String backupName() => 'finance_hub_backup_${_stamp(clock())}.json';

  Future<RemoteBackup> backupNow() async {
    final snapshot = await repository.createSnapshot();
    return storage.uploadBackup(backupName(), snapshot.encode());
  }

  Future<List<RemoteBackup>> list() => storage.listBackups();

  Future<BackupPreview> preview(RemoteBackup backup) async {
    final s = _decode(await storage.downloadBackup(backup.id));
    return BackupPreview(remote: backup, createdAt: s.createdAt, counts: s.counts);
  }

  /// Valida o backup ANTES de mexer em qualquer coisa, guarda uma cópia dos dados atuais e só então restaura.
  Future<BackupPreview> restore(RemoteBackup backup) async {
    final snapshot = _decode(await storage.downloadBackup(backup.id));
    final current = await repository.createSnapshot();
    await safety.save('antes_de_restaurar_${_stamp(clock())}.json', current.encode());
    await repository.restore(snapshot);
    return BackupPreview(remote: backup, createdAt: snapshot.createdAt, counts: snapshot.counts);
  }

  Future<void> delete(RemoteBackup backup) => storage.deleteBackup(backup.id);

  BackupSnapshot _decode(Uint8List bytes) => BackupSnapshot.decode(bytes, maxSchemaVersion: repository.db.schemaVersion);
}
