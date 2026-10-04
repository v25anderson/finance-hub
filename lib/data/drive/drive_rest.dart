import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../application/drive/drive_storage.dart';

class DriveFileMeta {
  const DriveFileMeta({required this.id, required this.name, required this.modifiedAt, required this.sizeBytes});
  final String id, name;
  final DateTime modifiedAt;
  final int sizeBytes;
}

/// Chamadas básicas ao Drive v3 (escopo `drive.file`: só enxerga o que o app criou). Falhas viram [DriveException].
class DriveRest {
  DriveRest({required this.client, required this.headers});

  final http.Client client;
  final Future<Map<String, String>> Function() headers;

  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';
  static const _fileFields = 'id,name,modifiedTime,size';
  static const folderMime = 'application/vnd.google-apps.folder';

  final _folders = <String, String>{};

  Future<http.Response> send(Future<http.Response> Function(Map<String, String> h) call) async {
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

  Map<String, dynamic> json(http.Response r) => jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;

  /// Pasta [name] (dentro de [parentId], se houver): usa a existente ou cria. O id fica em memória.
  Future<String> folder(String name, {String? parentId}) async {
    final key = '${parentId ?? ''}/$name';
    final cached = _folders[key];
    if (cached != null) return cached;
    final q = "name = '$name' and mimeType = '$folderMime' and trashed = false${parentId == null ? '' : " and '$parentId' in parents"}";
    final found = await send((h) => client.get(Uri.parse(_api).replace(queryParameters: {'q': q, 'fields': 'files(id)', 'pageSize': '1'}), headers: h));
    final files = (json(found)['files'] as List?) ?? const [];
    if (files.isNotEmpty) return _folders[key] = (files.first as Map)['id'] as String;
    final created = await send((h) => client.post(
          Uri.parse(_api).replace(queryParameters: {'fields': 'id'}),
          headers: {...h, 'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'mimeType': folderMime, if (parentId != null) 'parents': [parentId]}),
        ));
    return _folders[key] = json(created)['id'] as String;
  }

  DriveFileMeta _meta(Map<String, dynamic> f) => DriveFileMeta(
        id: f['id'] as String,
        name: f['name'] as String,
        modifiedAt: DateTime.parse(f['modifiedTime'] as String),
        sizeBytes: int.tryParse('${f['size']}') ?? 0,
      );

  /// Arquivos da pasta cujo nome contém [namePart], mais recentes primeiro (com paginação).
  Future<List<DriveFileMeta>> list(String folderId, String namePart) async {
    final out = <DriveFileMeta>[];
    String? page;
    do {
      final q = "'$folderId' in parents and trashed = false and name contains '$namePart'";
      final r = await send((h) => client.get(
            Uri.parse(_api).replace(queryParameters: {
              'q': q,
              'orderBy': 'modifiedTime desc',
              'pageSize': '100',
              'fields': 'nextPageToken,files($_fileFields)',
              'pageToken': ?page,
            }),
            headers: h,
          ));
      final j = json(r);
      out.addAll([for (final f in (j['files'] as List? ?? const [])) _meta(f as Map<String, dynamic>)]);
      page = j['nextPageToken'] as String?;
    } while (page != null);
    return out;
  }

  Future<DriveFileMeta> upload(String folderId, String name, Uint8List bytes) async {
    const boundary = 'finance-hub-boundary-7d1f3a';
    final meta = jsonEncode({'name': name, 'parents': [folderId], 'mimeType': 'application/json'});
    final body = BytesBuilder()
      ..add(utf8.encode('--$boundary\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n$meta\r\n'))
      ..add(utf8.encode('--$boundary\r\nContent-Type: application/json\r\n\r\n'))
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--'));
    final r = await send((h) => client.post(
          Uri.parse(_upload).replace(queryParameters: {'uploadType': 'multipart', 'fields': _fileFields}),
          headers: {...h, 'Content-Type': 'multipart/related; boundary=$boundary'},
          body: body.toBytes(),
        ));
    return _meta(json(r));
  }

  Future<Uint8List> download(String id) async {
    final r = await send((h) => client.get(Uri.parse('$_api/$id').replace(queryParameters: {'alt': 'media'}), headers: h));
    return r.bodyBytes;
  }

  Future<void> delete(String id) async {
    await send((h) async => http.Response.fromStream(await client.send(http.Request('DELETE', Uri.parse('$_api/$id'))..headers.addAll(h))));
  }
}
