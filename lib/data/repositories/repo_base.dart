import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Utilitários comuns: ids, carimbos de tempo, versão e dispositivo.
abstract class RepoBase {
  RepoBase(this.db);
  final AppDatabase db;

  static const _uuid = Uuid();
  String newId() => _uuid.v4();
  DateTime now() => db.now();
}

/// Lança quando um registro esperado não existe (ou foi excluído).
class NotFoundError implements Exception {
  NotFoundError(this.entity, this.id);
  final String entity;
  final String id;
  @override
  String toString() => 'NotFoundError($entity)'; // sem expor dados do usuário
}

/// Lança quando uma regra de negócio é violada.
class ValidationError implements Exception {
  ValidationError(this.message);
  final String message;
  @override
  String toString() => 'ValidationError: $message';
}
