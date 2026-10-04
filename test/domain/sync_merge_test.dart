import 'package:finance_hub/domain/sync/change_file.dart';
import 'package:finance_hub/domain/sync/merge.dart';
import 'package:flutter_test/flutter_test.dart';

Fields rec({String name = 'Aluguel', int amount = 1000, String due = '2026-10-05', String note = '', int updatedAt = 1, int version = 1, String device = 'a'}) =>
    {'id': 'r1', 'name': name, 'amount': amount, 'dueDate': due, 'note': note, 'updatedAt': updatedAt, 'version': version, 'deviceId': device};

void main() {
  group('mergeRecord com base', () {
    final base = rec();

    test('ninguém mudou, ou só metadados mudaram: nada a fazer', () {
      expect(mergeRecord(base: base, local: rec(updatedAt: 9, device: 'b'), remote: rec(updatedAt: 5, version: 3)).kind, MergeKind.keepLocal);
    });

    test('só o remoto mudou: adota o remoto', () {
      expect(mergeRecord(base: base, local: base, remote: rec(amount: 2000)).kind, MergeKind.takeRemote);
    });

    test('só o local mudou: mantém o local', () {
      expect(mergeRecord(base: base, local: rec(amount: 3000), remote: base).kind, MergeKind.keepLocal);
    });

    test('campos diferentes: combina automaticamente, sem perder nenhum', () {
      final r = mergeRecord(base: base, local: rec(amount: 3000), remote: rec(note: 'pago em dinheiro', due: '2026-10-08'));
      expect(r.kind, MergeKind.merged);
      expect(r.fields['amount'], 3000);
      expect(r.fields['note'], 'pago em dinheiro');
      expect(r.fields['dueDate'], '2026-10-08');
      expect(r.fields['name'], 'Aluguel');
    });

    test('mesmo campo com valores diferentes: conflito, listando só o campo em disputa', () {
      final r = mergeRecord(base: base, local: rec(amount: 3000, note: 'x'), remote: rec(amount: 4000, note: 'y'));
      expect(r.kind, MergeKind.conflict);
      expect(r.conflictFields, ['amount', 'note']);
    });

    test('mesmo campo alterado para o mesmo valor não é conflito', () {
      expect(mergeRecord(base: base, local: rec(amount: 3000), remote: rec(amount: 3000, updatedAt: 7)).kind, MergeKind.keepLocal);
    });

    test('um mudou o campo A de forma conflitante e outro campo B só no remoto: conflito em A apenas', () {
      final r = mergeRecord(base: base, local: rec(amount: 3000), remote: rec(amount: 4000, note: 'n'));
      expect(r.kind, MergeKind.conflict);
      expect(r.conflictFields, ['amount']);
    });

    test('exclusão (deletedAt) é um campo como os outros', () {
      final b = {...base, 'deletedAt': null};
      expect(mergeRecord(base: b, local: b, remote: {...b, 'deletedAt': 99}).kind, MergeKind.takeRemote);
      expect(mergeRecord(base: b, local: {...b, 'deletedAt': 50}, remote: {...b, 'deletedAt': 99}).kind, MergeKind.conflict);
      // excluído aqui, editado lá em outro campo: combina (a exclusão não é descartada)
      final m = mergeRecord(base: b, local: {...b, 'deletedAt': 50}, remote: {...b, 'amount': 7});
      expect(m.kind, MergeKind.merged);
      expect(m.fields['deletedAt'], 50);
      expect(m.fields['amount'], 7);
    });
  });

  group('mergeRecord sem base (nunca sincronizado)', () {
    test('registro local inexistente: adota o remoto', () {
      expect(mergeRecord(local: null, remote: rec()).kind, MergeKind.takeRemote);
    });
    test('dados idênticos: nada a fazer', () {
      expect(mergeRecord(local: rec(updatedAt: 2), remote: rec()).kind, MergeKind.keepLocal);
    });
    test('local nunca editado (seed): adota o remoto', () {
      expect(mergeRecord(local: rec(amount: 0), remote: rec(amount: 9), localNeverEdited: true).kind, MergeKind.takeRemote);
    });
    test('local editado e diferente: conflito, nada é descartado', () {
      final r = mergeRecord(local: rec(amount: 1), remote: rec(amount: 9));
      expect(r.kind, MergeKind.conflict);
      expect(r.conflictFields, ['amount']);
    });
  });

  test('comparação de valores é estrutural e distingue null, 0 e vazio', () {
    expect(sameData({'a': null}, {'a': 0}), isFalse);
    expect(sameData({'a': ''}, {'a': null}), isFalse);
    expect(sameData({'a': 1, 'version': 1}, {'a': 1, 'version': 9}), isTrue);
    expect(differingFields({'a': 1, 'b': 2}, {'a': 1, 'b': 3, 'c': 4}), ['b', 'c']);
  });

  group('arquivo de mudanças', () {
    final file = ChangeFile(
      deviceId: 'dev-a',
      seq: 3,
      schemaVersion: 3,
      createdAt: DateTime.utc(2026, 10, 10, 12),
      changes: [RecordChange('transactions', rec())],
    );

    test('ida e volta', () {
      final back = ChangeFile.decode(file.encode(), maxSchemaVersion: 3);
      expect(back.deviceId, 'dev-a');
      expect(back.seq, 3);
      expect(back.changes.single.table, 'transactions');
      expect(back.changes.single.id, 'r1');
      expect(back.changes.single.row['name'], 'Aluguel');
    });

    test('recusa lixo, tabela desconhecida e versão mais nova', () {
      expect(() => ChangeFile.decode([1, 2], maxSchemaVersion: 3), throwsA(isA<SyncFormatError>()));
      expect(() => ChangeFile.decode(file.encode(), maxSchemaVersion: 2), throwsA(isA<SyncFormatError>()));
      final bad = ChangeFile(deviceId: 'a', seq: 1, schemaVersion: 3, createdAt: DateTime.utc(2026), changes: [RecordChange('sync_base', rec())]);
      expect(() => ChangeFile.decode(bad.encode(), maxSchemaVersion: 3), throwsA(isA<SyncFormatError>()));
    });

    test('cursor: ida e volta e tolerância a conteúdo ruim', () {
      const c = SyncCursor(ownSeq: 4, peers: {'x': 2});
      expect(SyncCursor.decode(c.encode()).peers, {'x': 2});
      expect(SyncCursor.decode(c.encode()).ownSeq, 4);
      expect(SyncCursor.decode('lixo').ownSeq, 0);
      expect(SyncCursor.decode(null).peers, isEmpty);
    });
  });
}
