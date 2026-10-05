import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/sync/change_file.dart';
import '../../domain/sync/merge.dart';
import '../db/app_database.dart';
import '../repositories/repo_base.dart';

enum ConflictChoice { keepLocal, useRemote }

class SyncReport {
  const SyncReport({this.filesRead = 0, this.applied = 0, this.merged = 0, this.newConflicts = 0, this.skipped = 0, this.pushed = 0, this.waiting = 0});
  final int filesRead, applied, merged, newConflicts, skipped, pushed;

  /// Arquivos de outro aparelho que ainda não puderam ser lidos por haver um buraco na sequência.
  final int waiting;

  SyncReport copyWith({int? pushed, int? waiting, int? filesRead}) => SyncReport(
        filesRead: filesRead ?? this.filesRead,
        applied: applied,
        merged: merged,
        newConflicts: newConflicts,
        skipped: skipped,
        pushed: pushed ?? this.pushed,
        waiting: waiting ?? this.waiting,
      );
}

class DirtyRecord {
  const DirtyRecord(this.table, this.row);
  final String table;
  final Fields row;
}

class _Entity {
  _Entity(this.name, this.all, this.upsert);
  final String name;
  final Future<List<Fields>> Function() all;
  final Future<void> Function(Fields) upsert;
}

String _key(String table, String id) => '$table/$id';

/// Acesso ao banco para a sincronização: o que mudou aqui, aplicar o que veio de fora e conflitos.
class SyncRepository extends RepoBase {
  SyncRepository(super.db) {
    _entities = {
      for (final e in [
        _entity('categories', db.categories, CategoryRow.fromJson, (r) => r.toCompanion(false)),
        _entity('recurring_transactions', db.recurringTransactions, RecurringRow.fromJson, (r) => r.toCompanion(false)),
        _entity('transactions', db.transactions, TransactionRow.fromJson, (r) => r.toCompanion(false)),
        _entity('payments', db.payments, PaymentRow.fromJson, (r) => r.toCompanion(false)),
        _entity('incomes', db.incomes, IncomeRow.fromJson, (r) => r.toCompanion(false)),
        _entity('investments', db.investments, InvestmentRow.fromJson, (r) => r.toCompanion(false)),
        _entity('plannings', db.plannings, PlanningRow.fromJson, (r) => r.toCompanion(false)),
        _entity('planning_defaults_versions', db.planningDefaultsVersions, DefaultsVersionRow.fromJson, (r) => r.toCompanion(false)),
        _entity('month_configurations', db.monthConfigurations, MonthConfigRow.fromJson, (r) => r.toCompanion(false)),
      ])
        e.name: e,
    };
  }

  late final Map<String, _Entity> _entities;

  _Entity _entity<T extends Table, D extends DataClass>(
    String name,
    TableInfo<T, D> table,
    D Function(Map<String, dynamic>) from,
    UpdateCompanion<D> Function(D) companion,
  ) =>
      _Entity(
        name,
        () async => [for (final r in await db.select(table).get()) Map<String, Object?>.from(r.toJson())],
        (m) async {
          // Atualiza escrevendo também os campos nulos (insertOnConflictUpdate os ignoraria: "restaurar" nunca chegaria).
          final row = companion(from(m));
          final id = m['id'] as String;
          final updated = await (db.update(table)..where((_) => table.$primaryKey.first.equals(id))).write(row);
          if (updated == 0) await db.into(table).insert(row);
        },
      );

  // ---------- estado ----------

  Future<SyncMetaRow> _meta() => (db.select(db.syncMetadata)..where((m) => m.id.equals(syncMetaId))).getSingle();

  Future<SyncCursor> cursor() async => SyncCursor.decode((await _meta()).remoteCursor);

  Future<SyncMetaRow> meta() => _meta();

  Stream<SyncMetaRow> watchMeta() => (db.select(db.syncMetadata)..where((m) => m.id.equals(syncMetaId))).watchSingle();

  Future<void> setState(SyncState state) =>
      (db.update(db.syncMetadata)..where((m) => m.id.equals(syncMetaId))).write(SyncMetadataCompanion(state: Value(state), updatedAt: Value(now())));

  Future<void> markSynced() => (db.update(db.syncMetadata)..where((m) => m.id.equals(syncMetaId)))
      .write(SyncMetadataCompanion(state: const Value(SyncState.synced), lastSyncAt: Value(now()), updatedAt: Value(now())));

  Future<Map<String, Fields>> _bases() async => {
        for (final b in await db.select(db.syncBase).get()) _key(b.entity, b.recordId): Map<String, Object?>.from(jsonDecode(b.json) as Map),
      };

  Future<void> _setBase(String table, String id, Fields row) => db
      .into(db.syncBase)
      .insertOnConflictUpdate(SyncBaseCompanion.insert(entity: table, recordId: id, json: jsonEncode(row)));

  Future<Map<String, SyncConflictRow>> _openConflicts() async => {
        for (final c in await (db.select(db.syncConflicts)..where((c) => c.resolvedAt.isNull())).get()) _key(c.entity, c.recordId): c,
      };

  // ---------- saída: o que mudou aqui ----------

  /// Registros novos ou alterados desde a última sincronização. Registros em conflito aberto não saem:
  /// enviar a versão local seria escolher um lado em silêncio.
  Future<List<DirtyRecord>> collectDirty() async {
    final bases = await _bases();
    final conflicts = await _openConflicts();
    final out = <DirtyRecord>[];
    for (final table in syncTables) {
      for (final row in await _entities[table]!.all()) {
        final k = _key(table, row['id'] as String);
        if (conflicts.containsKey(k)) continue;
        final base = bases[k];
        if (base == null || !sameData(row, base)) out.add(DirtyRecord(table, row));
      }
    }
    return out;
  }

  /// Depois de enviar: o enviado passa a ser a base. Edições feitas durante o envio continuam pendentes.
  Future<void> markPushed(List<DirtyRecord> sent, int seq) => db.transaction(() async {
        for (final d in sent) {
          await _setBase(d.table, d.row['id'] as String, d.row);
        }
        final c = await cursor();
        await (db.update(db.syncMetadata)..where((m) => m.id.equals(syncMetaId)))
            .write(SyncMetadataCompanion(remoteCursor: Value(c.copyWith(ownSeq: seq).encode())));
      });

  // ---------- entrada: o que veio de fora ----------

  /// Aplica arquivos de outros aparelhos numa única transação (tudo ou nada) e avança o cursor.
  Future<SyncReport> apply(List<ChangeFile> files, Map<String, int> newPeerCursors) => db.transaction(() async {
        var applied = 0, merged = 0, newConflicts = 0, skipped = 0;
        final bases = await _bases();
        final conflicts = await _openConflicts();
        final device = await db.currentDeviceId();

        for (final table in syncTables) {
          final entity = _entities[table]!;
          final local = {for (final r in await entity.all()) r['id'] as String: r};
          for (final file in files) {
            for (final change in file.changes.where((c) => c.table == table)) {
              final id = change.id;
              final k = _key(table, id);
              final remote = change.row;
              final open = conflicts[k];
              if (open != null) {
                await (db.update(db.syncConflicts)..where((c) => c.id.equals(open.id)))
                    .write(SyncConflictsCompanion(remoteJson: Value(jsonEncode(remote)), updatedAt: Value(now())));
                continue;
              }
              final mine = local[id];
              final neverEdited = mine != null && mine['createdAt'] == mine['updatedAt'];
              final result = mergeRecord(base: bases[k], local: mine, remote: remote, localNeverEdited: neverEdited);
              switch (result.kind) {
                case MergeKind.keepLocal:
                  if (mine != null && sameData(mine, remote)) {
                    await _setBase(table, id, remote);
                    bases[k] = remote;
                  }
                case MergeKind.takeRemote:
                  try {
                    await entity.upsert(remote);
                    local[id] = remote;
                    await _setBase(table, id, remote);
                    bases[k] = remote;
                    applied++;
                  } catch (_) {
                    skipped++; // ex.: ocorrência duplicada de recorrência; o registro local é mantido
                  }
                case MergeKind.merged:
                  final row = {
                    ...result.fields,
                    'updatedAt': now().millisecondsSinceEpoch,
                    'version': ((mine!['version'] as int?) ?? 0) > ((remote['version'] as int?) ?? 0) ? (mine['version'] as int) + 1 : ((remote['version'] as int?) ?? 0) + 1,
                    'deviceId': device,
                  };
                  await entity.upsert(row);
                  local[id] = row;
                  await _setBase(table, id, remote); // o local difere da base: será enviado na sequência
                  bases[k] = remote;
                  merged++;
                case MergeKind.conflict:
                  final t = now();
                  final cid = newId();
                  await db.into(db.syncConflicts).insert(SyncConflictsCompanion.insert(
                        id: cid,
                        createdAt: t,
                        updatedAt: t,
                        entity: table,
                        recordId: id,
                        localJson: jsonEncode(mine),
                        remoteJson: jsonEncode(remote),
                      ));
                  conflicts[k] = await (db.select(db.syncConflicts)..where((c) => c.id.equals(cid))).getSingle();
                  newConflicts++;
              }
            }
          }
        }
        final c = await cursor();
        await (db.update(db.syncMetadata)..where((m) => m.id.equals(syncMetaId)))
            .write(SyncMetadataCompanion(remoteCursor: Value(c.copyWith(peers: {...c.peers, ...newPeerCursors}).encode())));
        return SyncReport(filesRead: files.length, applied: applied, merged: merged, newConflicts: newConflicts, skipped: skipped);
      });

  // ---------- conflitos ----------

  Stream<List<SyncConflictRow>> watchOpenConflicts() =>
      (db.select(db.syncConflicts)..where((c) => c.resolvedAt.isNull())..orderBy([(c) => OrderingTerm.asc(c.createdAt)])).watch();

  Future<void> resolve(String conflictId, ConflictChoice choice) => db.transaction(() async {
        final c = await (db.select(db.syncConflicts)..where((x) => x.id.equals(conflictId))).getSingleOrNull();
        if (c == null || c.resolvedAt != null) return;
        final remote = Map<String, Object?>.from(jsonDecode(c.remoteJson) as Map);
        if (choice == ConflictChoice.useRemote) await _entities[c.entity]!.upsert(remote);
        // Em ambos os casos a base passa a ser o remoto: "manter o meu" fica pendente e será enviado; "usar o outro" fica limpo.
        await _setBase(c.entity, c.recordId, remote);
        await (db.update(db.syncConflicts)..where((x) => x.id.equals(conflictId)))
            .write(SyncConflictsCompanion(resolvedAt: Value(now()), updatedAt: Value(now())));
      });

  /// Recomeça a sincronização deste aparelho (usado após restaurar um backup).
  Future<void> resetSyncState() async {
    await db.delete(db.syncBase).go();
    await db.delete(db.syncConflicts).go();
    await (db.update(db.syncMetadata)..where((m) => m.id.equals(syncMetaId)))
        .write(const SyncMetadataCompanion(remoteCursor: Value(null), lastSyncAt: Value(null)));
  }
}
