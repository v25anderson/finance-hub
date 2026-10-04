import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../application/drive/drive_storage.dart';

const driveFolderName = 'Finance Hub';
const backupNamePrefix = 'finance_hub_backup_';

/// Drive v3 via REST. Escopo `drive.file`: só enxerga a pasta e os arquivos criados pelo app.
class GoogleDriveStorage implements DriveStorage {
  GoogleDriveStorage({required this.client, required this.headers});

  final http.Client client;
  final Future<Map<String, String>> Function() headers;
  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';
  static const _fileFields = 'id,name,modifiedTime,size';

  String? _folderId;

  Future<http.Response> _send(Future<http.Response> Function(Map<String, String> h) call) async {
    try {
      final r = await call(await headers());
      if (r.statusCode >= 200 && r.statusCode < 300) return r;
      throw _failure(r);
    } on DriveException {
      rethrow;
    } on SocketException {
      throw DriveException(DriveFailure.network);
    } on http.ClientException {
      throw DriveException(DriveFailure.network);
    }
  }

  DriveException _failure(http.Response r) {
    final code = r.statusCode;
    if (code == 401) return DriveException(DriveFailure.unauthorized, code);
    if (code == 404) return DriveException(DriveFailure.notFound, code);
    if (code == 403 && r.body.contains('storageQuotaExceeded')) return DriveException(DriveFailure.quota, code);
    if (code == 403) return DriveException(DriveFailure.unauthorized, code);
    if (code == 429 || code >= 500) return DriveException(DriveFailure.unavailable, code);
    return DriveException(DriveFailure.unknown, code);
  }

  Map<String, dynamic> _json(http.Response r) => jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;

  Future<String> _folder() async {
    final cached = _folderId;
    if (cached != null) return cached;
    final q = "name = '$driveFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final found = await _send((h) => client.get(Uri.parse(_api).replace(queryParameters: {'q': q, 'fields': 'files(id)', 'pageSize': '1'}), headers: h));
    final files = (_json(found)['files'] as List?) ?? const [];
    if (files.isNotEmpty) return _folderId = (files.first as Map)['id'] as String;
    final created = await _send((h) => client.post(
          Uri.parse(_api).replace(queryParameters: {'fields': 'id'}),
          headers: {...h, 'Content-Type': 'application/json'},
          body: jsonEncode({'name': driveFolderName, 'mimeType': 'application/vnd.google-apps.folder'}),
        ));
    return _folderId = _json(created)['id'] as String;
  }

  RemoteBackup _backup(Map<String, dynamic> f) => RemoteBackup(
        id: f['id'] as String,
        name: f['name'] as String,
        modifiedAt: DateTime.parse(f['modifiedTime'] as String),
        sizeBytes: int.tryParse('${f['size']}') ?? 0,
      );

  @override
  Future<List<RemoteBackup>> listBackups() async {
    final folder = await _folder();
    final out = <RemoteBackup>[];
    String? page;
    do {
      final q = "'$folder' in parents and trashed = false and name contains '$backupNamePrefix'";
      final r = await _send((h) => client.get(
            Uri.parse(_api).replace(queryParameters: {
              'q': q,
              'orderBy': 'modifiedTime desc',
              'pageSize': '100',
              'fields': 'nextPageToken,files($_fileFields)',
              'pageToken': ?page,
            }),
            headers: h,
          ));
      final j = _json(r);
      out.addAll([for (final f in (j['files'] as List? ?? const [])) _backup(f as Map<String, dynamic>)]);
      page = j['nextPageToken'] as String?;
    } while (page != null);
    return out;
  }

  @override
  Future<RemoteBackup> uploadBackup(String name, Uint8List bytes) async {
    final folder = await _folder();
    const boundary = 'finance-hub-boundary-7d1f3a';
    final meta = jsonEncode({'name': name, 'parents': [folder], 'mimeType': 'application/json'});
    final body = BytesBuilder()
      ..add(utf8.encode('--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n$meta\r\n'))
      ..add(utf8.encode('--$boundary\r\nContent-Type: application/json\r\n\r\n'))
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--'));
    final r = await _send((h) => client.post(
          Uri.parse(_upload).replace(queryParameters: {'uploadType': 'multipart', 'fields': _fileFields}),
          headers: {...h, 'Content-Type': 'multipart/related; boundary=$boundary'},
          body: body.toBytes(),
        ));
    return _backup(_json(r));
  }

  @override
  Future<Uint8List> downloadBackup(String id) async {
    final r = await _send((h) => client.get(Uri.parse('$_api/$id').replace(queryParameters: {'alt': 'media'}), headers: h));
    return r.bodyBytes;
  }

  @override
  Future<void> deleteBackup(String id) async {
    await _send((h) async => http.Response.fromStream(await client.send(http.Request('DELETE', Uri.parse('$_api/$id'))..headers.addAll(h))));
  }
}
