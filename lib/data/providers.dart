import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/bill_service.dart';
import '../domain/bill.dart';
import 'db/app_database.dart';
import 'db/connection.dart';
import 'repositories/bill_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/planning_repository.dart';
import 'repositories/transaction_repository.dart';

/// Relógio do app (sobrescrevível em testes).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// "Hoje" como data pura.
final todayProvider = Provider<DateTime>((ref) => dateOnly(ref.watch(clockProvider)()));

/// Banco único do app. Em testes, sobrescreva com um banco em memória.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openAppConnection());
  ref.onDispose(db.close);
  return db;
});

final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref.watch(databaseProvider)));
final transactionRepositoryProvider = Provider((ref) => TransactionRepository(ref.watch(databaseProvider)));
final planningRepositoryProvider = Provider((ref) => PlanningRepository(ref.watch(databaseProvider)));
final billRepositoryProvider = Provider((ref) => BillRepository(ref.watch(databaseProvider)));

final billServiceProvider = Provider((ref) => BillService(
      bills: ref.watch(billRepositoryProvider),
      transactions: ref.watch(transactionRepositoryProvider),
      clock: ref.watch(clockProvider),
    ));

final categoriesProvider = StreamProvider((ref) => ref.watch(categoryRepositoryProvider).watchAll());

/// Contas do mês `yyyy-MM`.
final billsForMonthProvider =
    StreamProvider.family<List<Bill>, String>((ref, ym) => ref.watch(billRepositoryProvider).watchMonth(ym));

/// Uma conta (reativa), para a tela de detalhe.
final billProvider = StreamProvider.family<Bill?, String>((ref, id) => ref.watch(billRepositoryProvider).watchBill(id));
