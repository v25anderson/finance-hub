import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';
import 'db/connection.dart';
import 'repositories/category_repository.dart';
import 'repositories/planning_repository.dart';
import 'repositories/transaction_repository.dart';

/// Banco único do app. Em testes, sobrescreva com um banco em memória.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openAppConnection());
  ref.onDispose(db.close);
  return db;
});

final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref.watch(databaseProvider)));
final transactionRepositoryProvider = Provider((ref) => TransactionRepository(ref.watch(databaseProvider)));
final planningRepositoryProvider = Provider((ref) => PlanningRepository(ref.watch(databaseProvider)));
