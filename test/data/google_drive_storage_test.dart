import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:typed_data';

import 'package:finance_hub/application/drive/drive_storage.dart';
import 'package:finance_hub/data/drive/drive_rest.dart';
import 'package:finance_hub/data/drive/google_drive_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<Map<String, String>> _h() async => {'Authorization': 'Bearer tok'};

http.Response _json(Object body, [int code = 200]) => http.Response(jsonEncode(body), code, headers: {'content-type': 'application/json; charset=utf-8'});

GoogleDriveStorage storage(Future<http.Response> Function(http.Request r) handler, [List<http.Request>? log]) => GoogleDriveStorage(
      rest: DriveRest(
        client: MockClient((r) {
          log?.add(r);
          return handler(r);
        }),
        headers: _h,
      ),
    );

void main() {
  const file = {'id': 'f1', 'name': 'finance_hub_backup_20261010_120000.json', 'modifiedTime': '2026-10-10T12:00:00.000Z', 'size': '1234'};

  test('usa a pasta existente, lista só backups do app, mais recentes primeiro, e manda o token', () async {
    final log = <http.Request>[];
    final s = storage((r) async {
      if (r.url.queryParameters['q']!.contains('google-apps.folder')) return _json({'files': [{'id': 'folder1'}]});
      return _json({'files': [file]});
    }, log);
    final list = await s.listBackups();
    expect(list.single.id, 'f1');
    expect(list.single.sizeBytes, 1234);
    expect(list.single.modifiedAt, DateTime.utc(2026, 10, 10, 12));
    final q = log.last.url.queryParameters;
    expect(q['q'], contains("'folder1' in parents"));
    expect(q['q'], contains('trashed = false'));
    expect(q['orderBy'], 'modifiedTime desc');
    expect(log.every((r) => r.headers['Authorization'] == 'Bearer tok'), isTrue);
  });

  test('cria a pasta quando não existe e a reutiliza nas chamadas seguintes', () async {
    final log = <http.Request>[];
    final s = storage((r) async {
      if (r.method == 'POST') return _json({'id': 'new-folder'});
      if (r.url.queryParameters['q']!.contains('google-apps.folder')) return _json({'files': []});
      return _json({'files': []});
    }, log);
    await s.listBackups();
    await s.listBackups();
    final posts = log.where((r) => r.method == 'POST').toList();
    expect(posts.length, 1);
    expect(jsonDecode(posts.single.body), {'name': 'Finance Hub', 'mimeType': 'application/vnd.google-apps.folder'});
    expect(log.where((r) => r.url.queryParameters['q']?.contains('google-apps.folder') ?? false).length, 1); // pasta buscada uma vez
  });

  test('segue a paginação', () async {
    var page = 0;
    final s = storage((r) async {
      final q = r.url.queryParameters;
      if (q['q']!.contains('google-apps.folder')) return _json({'files': [{'id': 'folder1'}]});
      page++;
      if (q['pageToken'] == null) return _json({'files': [file], 'nextPageToken': 'p2'});
      expect(q['pageToken'], 'p2');
      return _json({'files': [{...file, 'id': 'f2'}]});
    });
    expect((await s.listBackups()).map((b) => b.id), ['f1', 'f2']);
    expect(page, 2);
  });

  test('upload multipart com pasta, nome e conteúdo', () async {
    http.Request? upload;
    final s = storage((r) async {
      if (r.url.host == 'www.googleapis.com' && r.url.path.startsWith('/upload')) {
        upload = r;
        return _json(file);
      }
      return _json({'files': [{'id': 'folder1'}]});
    });
    final result = await s.uploadBackup('finance_hub_backup_20261010_120000.json', Uint8List.fromList(utf8.encode('{"ok":"ação"}')));
    expect(result.id, 'f1');
    expect(upload!.url.queryParameters['uploadType'], 'multipart');
    expect(upload!.headers['Content-Type'], startsWith('multipart/related; boundary='));
    final body = utf8.decode(upload!.bodyBytes);
    expect(body, contains('"parents":["folder1"]'));
    expect(body, contains('"name":"finance_hub_backup_20261010_120000.json"'));
    expect(body, contains('{"ok":"ação"}'));
  });

  test('download e exclusão', () async {
    final log = <http.Request>[];
    final s = storage((r) async {
      if (r.method == 'DELETE') return http.Response('', 204);
      return http.Response.bytes([1, 2, 3], 200);
    }, log);
    expect(await s.downloadBackup('abc'), [1, 2, 3]);
    expect(log.last.url.path, '/drive/v3/files/abc');
    expect(log.last.url.queryParameters['alt'], 'media');
    await s.deleteBackup('abc');
    expect(log.last.method, 'DELETE');
  });

  group('erros', () {
    Future<DriveFailure> failure(Future<http.Response> Function(http.Request) h) async {
      try {
        await storage(h).downloadBackup('x');
      } on DriveException catch (e) {
        return e.kind;
      }
      fail('deveria falhar');
    }

    test('mapeia status e rede, sem vazar o corpo da resposta', () async {
      expect(await failure((_) async => http.Response('segredo', 401)), DriveFailure.unauthorized);
      expect(await failure((_) async => http.Response('segredo', 404)), DriveFailure.notFound);
      expect(await failure((_) async => http.Response('{"reason":"storageQuotaExceeded"}', 403)), DriveFailure.quota);
      expect(await failure((_) async => http.Response('x', 403)), DriveFailure.unauthorized);
      expect(await failure((_) async => http.Response('x', 429)), DriveFailure.unavailable);
      expect(await failure((_) async => http.Response('x', 503)), DriveFailure.unavailable);
      expect(await failure((_) async => http.Response('x', 400)), DriveFailure.unknown);
      expect(await failure((_) async => throw const SocketException('sem rede')), DriveFailure.network);
      expect(await failure((_) async => throw http.ClientException('sem rede')), DriveFailure.network);
      try {
        await storage((_) async => http.Response('segredo', 401)).downloadBackup('x');
      } on DriveException catch (e) {
        expect('${e.message} ${e.toString()}', isNot(contains('segredo')));
      }
    });
  });
}
