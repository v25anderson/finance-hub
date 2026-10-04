import 'dart:typed_data';

import '../../application/drive/drive_storage.dart';
import 'drive_rest.dart';

const driveFolderName = 'Finance Hub';
const backupNamePrefix = 'finance_hub_backup_';

/// Backups no Drive v3: arquivos JSON na pasta "Finance Hub".
class GoogleDriveStorage implements DriveStorage {
  GoogleDriveStorage({required this.rest});
  final DriveRest rest;

  RemoteBackup _backup(DriveFileMeta f) => RemoteBackup(id: f.id, name: f.name, modifiedAt: f.modifiedAt, sizeBytes: f.sizeBytes);

  @override
  Future<List<RemoteBackup>> listBackups() async => [for (final f in await rest.list(await rest.folder(driveFolderName), backupNamePrefix)) _backup(f)];

  @override
  Future<RemoteBackup> uploadBackup(String name, Uint8List bytes) async => _backup(await rest.upload(await rest.folder(driveFolderName), name, bytes));

  @override
  Future<Uint8List> downloadBackup(String id) => rest.download(id);

  @override
  Future<void> deleteBackup(String id) => rest.delete(id);
}
