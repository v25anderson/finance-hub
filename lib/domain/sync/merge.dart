import 'dart:convert';

typedef Fields = Map<String, Object?>;

/// Campos de controle (criação, atualização, versão, aparelho): não são dados do usuário e nunca geram conflito nem contam como alteração.
const syncMetadataKeys = {'version', 'deviceId', 'updatedAt', 'createdAt'};

Fields dataFields(Fields row) => {for (final e in row.entries) if (!syncMetadataKeys.contains(e.key)) e.key: e.value};

bool _same(Object? a, Object? b) => jsonEncode(a) == jsonEncode(b);

/// Dois registros têm os mesmos dados (ignora versão, aparelho e carimbo de atualização).
bool sameData(Fields a, Fields b) {
  final x = dataFields(a), y = dataFields(b);
  return x.length == y.length && x.keys.every((k) => y.containsKey(k) && _same(x[k], y[k]));
}

/// Campos de dados que diferem entre dois registros.
List<String> differingFields(Fields a, Fields b) {
  final x = dataFields(a), y = dataFields(b);
  return ({...x.keys, ...y.keys}.where((k) => !_same(x[k], y[k])).toList()..sort());
}

enum MergeKind {
  /// Nada a fazer: o remoto não traz novidade ou o local já tem tudo.
  keepLocal,

  /// O local não foi alterado: adota o remoto.
  takeRemote,

  /// Os dois mudaram campos diferentes: combinação automática.
  merged,

  /// Os dois mudaram o mesmo campo para valores diferentes: precisa de decisão do usuário.
  conflict,
}

class MergeResult {
  const MergeResult(this.kind, {this.fields = const {}, this.conflictFields = const []});
  final MergeKind kind;

  /// Registro resultante (só em [MergeKind.merged]).
  final Fields fields;

  /// Campos em conflito (só em [MergeKind.conflict]).
  final List<String> conflictFields;
}

/// Merge de três vias, campo a campo.
/// [base] = último estado sincronizado (null se nunca foi); [local] = registro neste aparelho (null se não existe);
/// [remote] = registro vindo de outro aparelho. [localNeverEdited] = o registro local nunca foi editado desde que foi criado
/// (ex.: categorias e singletons criados pelo seed), usado quando não há [base].
/// Nada é descartado: sem acordo claro, o resultado é conflito.
MergeResult mergeRecord({Fields? base, Fields? local, required Fields remote, bool localNeverEdited = false}) {
  if (local == null) return const MergeResult(MergeKind.takeRemote);
  if (base == null) {
    if (sameData(local, remote)) return const MergeResult(MergeKind.keepLocal);
    if (localNeverEdited) return const MergeResult(MergeKind.takeRemote);
    return MergeResult(MergeKind.conflict, conflictFields: differingFields(local, remote));
  }
  if (sameData(local, base)) {
    return sameData(remote, base) ? const MergeResult(MergeKind.keepLocal) : const MergeResult(MergeKind.takeRemote);
  }
  if (sameData(remote, base)) return const MergeResult(MergeKind.keepLocal);
  if (sameData(local, remote)) return const MergeResult(MergeKind.keepLocal);

  final b = dataFields(base), l = dataFields(local), r = dataFields(remote);
  final merged = <String, Object?>{...local};
  final conflicts = <String>[];
  for (final k in {...b.keys, ...l.keys, ...r.keys}) {
    final localChanged = !_same(l[k], b[k]);
    final remoteChanged = !_same(r[k], b[k]);
    if (localChanged && remoteChanged && !_same(l[k], r[k])) {
      conflicts.add(k);
    } else if (remoteChanged && !localChanged) {
      merged[k] = r[k];
    }
  }
  if (conflicts.isNotEmpty) return MergeResult(MergeKind.conflict, conflictFields: conflicts..sort());
  return MergeResult(MergeKind.merged, fields: merged);
}
