import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/sync/sync_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_transport.dart';
import 'sync_test.dart' show Device;

/// Conteúdo comparável (sem carimbos de controle) de contas e pagamentos de um aparelho.
Future<Map<String, String>> content(Device d) async {
  final out = <String, String>{};
  for (final t in await d.db.select(d.db.transactions).get()) {
    out['tx/${t.id}'] = '${t.name}|${t.plannedAmountCents}|${t.note}|${t.deletedAt == null}|${t.canceledAt == null}|${t.dueDate}';
  }
  for (final p in await d.db.select(d.db.payments).get()) {
    out['pay/${p.id}'] = '${p.transactionId}|${p.amountCents}|${p.deletedAt == null}';
  }
  return out;
}

/// Totais de eventos observados, para provar que o teste aleatório exercita merge e conflito de verdade.
var seenMerged = 0, seenConflicts = 0, seenApplied = 0;

Future<void> syncAll(List<Device> ds, Random rnd) async {
  final order = [...ds]..shuffle(rnd);
  for (final d in order) {
    final r = await d.sync.sync();
    seenMerged += r.merged;
    seenConflicts += r.newConflicts;
    seenApplied += r.applied;
  }
}

/// Política determinística para o teste: quem tem o menor `deviceId` mantém o seu; os outros adotam o dele.
Future<int> resolveAll(List<Device> ds) async {
  final ids = {for (final d in ds) d: await d.db.currentDeviceId()};
  final smallest = ids.values.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
  var n = 0;
  for (final d in ds) {
    for (final c in await d.repo.watchOpenConflicts().first) {
      await d.repo.resolve(c.id, ids[d] == smallest ? ConflictChoice.keepLocal : ConflictChoice.useRemote);
      n++;
    }
  }
  return n;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final seed in [1, 7, 42]) {
    test('3 aparelhos, operações aleatórias (semente $seed): todos convergem ao mesmo conteúdo', () async {
      final rnd = Random(seed);
      final cloud = MemoryTransport();
      final ds = [Device('A', cloud), Device('B', cloud), Device('C', cloud)];
      addTearDown(() async {
        for (final d in ds) {
          await d.db.close();
        }
      });
      final bills = <String>[];

      Future<void> randomOp(Device d) async {
        final known = (await d.allBills()).where((b) => b.deletedAt == null).toList();
        switch (known.isEmpty ? 0 : rnd.nextInt(6)) {
          case 0:
            bills.add(await d.bill('Conta ${rnd.nextInt(1000)}', cents: 100 + rnd.nextInt(5000)));
          case 1:
            await d.tx.update(known[rnd.nextInt(known.length)].id, plannedAmountCents: 100 + rnd.nextInt(9000));
          case 2:
            await d.tx.update(known[rnd.nextInt(known.length)].id, note: 'n${rnd.nextInt(50)}');
          case 3:
            await d.tx.update(known[rnd.nextInt(known.length)].id, name: 'Nome ${rnd.nextInt(80)}');
          case 4:
            await d.tx.addPayment(transactionId: known[rnd.nextInt(known.length)].id, amountCents: 1 + rnd.nextInt(500));
          case 5:
            final id = known[rnd.nextInt(known.length)].id;
            if (rnd.nextBool()) {
              await d.tx.softDelete(id);
            } else {
              await d.tx.update(id, favorite: rnd.nextBool());
            }
        }
      }

      for (var round = 0; round < 12; round++) {
        for (final d in ds) {
          for (var i = 0; i < 1 + rnd.nextInt(3); i++) {
            if (rnd.nextInt(3) != 0) await randomOp(d); // nem todo aparelho edita em toda rodada
          }
        }
        await syncAll(ds, rnd);
      }

      // assenta: sincroniza e resolve conflitos até não restar nenhum
      var guard = 0;
      while (true) {
        await syncAll(ds, rnd);
        await syncAll(ds, rnd);
        final resolved = await resolveAll(ds);
        if (resolved == 0) break;
        expect(++guard, lessThan(12), reason: 'os conflitos não podem se reproduzir para sempre');
      }
      await syncAll(ds, rnd);
      await syncAll(ds, rnd);

      final a = await content(ds[0]);
      expect(a, isNotEmpty);
      expect(await content(ds[1]), a, reason: 'B difere de A');
      expect(await content(ds[2]), a, reason: 'C difere de A');
      for (final d in ds) {
        expect(await d.repo.watchOpenConflicts().first, isEmpty);
        expect((await d.repo.collectDirty()), isEmpty, reason: '${d.name} ainda tem algo a enviar');
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  }

  test('o teste aleatório exercita de verdade aplicação, merge e conflito', () {
    // roda depois das 3 sementes (a ordem dos testes no arquivo é a de declaração)
    // ignore: avoid_print
    print('STRESS aplicados=$seenApplied combinados=$seenMerged conflitos=$seenConflicts');
    expect(seenApplied, greaterThan(50));
    expect(seenMerged, greaterThan(0));
    expect(seenConflicts, greaterThan(0));
  });

  test('desempenho: 3.000 contas e 3.000 pagamentos sincronizam em tempo razoável e chegam completos', () async {
    final cloud = MemoryTransport();
    final a = Device('A', cloud), b = Device('B', cloud);
    addTearDown(() async {
      await a.db.close();
      await b.db.close();
    });
    final sw = Stopwatch()..start();
    await a.db.batch((batch) {
      final t = DateTime.utc(2026, 10, 10);
      for (var i = 0; i < 3000; i++) {
        batch.insert(
          a.db.transactions,
          TransactionsCompanion.insert(
            id: 'tx$i',
            createdAt: t,
            updatedAt: t,
            name: 'Conta $i',
            plannedAmountCents: 1000 + i,
            dueDate: '2026-10-${(1 + i % 28).toString().padLeft(2, '0')}',
            categoryId: 'cat-outros',
            expenseType: ExpenseType.fixed,
          ),
        );
        batch.insert(a.db.payments, PaymentsCompanion.insert(id: 'p$i', createdAt: t, updatedAt: t, transactionId: 'tx$i', amountCents: 500, paidAt: t));
      }
    });
    final seeded = sw.elapsedMilliseconds;
    sw.reset();
    final push = await a.sync.sync();
    final pushMs = sw.elapsedMilliseconds;
    sw.reset();
    final pull = await b.sync.sync();
    final pullMs = sw.elapsedMilliseconds;
    // ignore: avoid_print
    print('PERF seed=${seeded}ms envio(${push.pushed} registros)=${pushMs}ms recebimento(${pull.applied})=${pullMs}ms');
    expect(push.pushed, greaterThanOrEqualTo(6000));
    expect((await b.allBills()).length, 3000);
    expect((await b.allPayments()).length, 3000);
    expect(pushMs, lessThan(60000));
    expect(pullMs, lessThan(60000));
    // segunda rodada sem mudanças é barata e não envia nada
    sw.reset();
    final again = await a.sync.sync();
    expect(again.pushed, 0);
    expect(sw.elapsedMilliseconds, lessThan(30000));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
