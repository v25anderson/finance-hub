import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:finance_hub/application/export_service.dart';
import 'package:finance_hub/application/file_saver.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/export_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/export/csv.dart';
import 'package:finance_hub/domain/export/export_data.dart';
import 'package:finance_hub/domain/export/exporter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/csv_parser.dart';
import 'test_db.dart';

class FakeSaver implements FileSaver {
  FakeSaver({this.result = true});
  final bool result;
  String? name;
  Uint8List? bytes;
  @override
  Future<bool> save({required String fileName, required Uint8List bytes, required String mime}) async {
    name = fileName;
    this.bytes = bytes;
    return result;
  }
}

void main() {
  late AppDatabase db;
  late TransactionRepository tx;
  late PlanningRepository plan;
  late FakeSaver saver;
  late ExportService service;
  final now = DateTime(2026, 10, 10, 12);

  setUp(() async {
    db = memoryDb(clock: () => now.toUtc());
    tx = TransactionRepository(db);
    plan = PlanningRepository(db);
    saver = FakeSaver();
    service = ExportService(repository: ExportRepository(db), saver: saver, clock: () => now);
    final a = await tx.create(name: 'Aluguel', plannedAmountCents: 180000, dueDate: DateTime(2026, 10, 1), categoryId: 'cat-moradia', expenseType: ExpenseType.fixed);
    await tx.addPayment(transactionId: a, amountCents: 100000, paidAt: DateTime.utc(2026, 10, 1, 9));
    await tx.addPayment(transactionId: a, amountCents: 80000, paidAt: DateTime.utc(2026, 10, 2, 9));
    final gone = await tx.create(name: 'Excluída', plannedAmountCents: 5000, dueDate: DateTime(2026, 10, 9), categoryId: 'cat-outros', expenseType: ExpenseType.oneOff);
    await tx.softDelete(gone);
    await plan.updatePlanning(salaryCents: 800000);
    await plan.setMonthConfig('2026-11', salaryCents: 920000);
    await plan.addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 10000, description: 'freela');
    await plan.addInvestment(yearMonth: '2026-10', plannedCents: 200000, realizedCents: 150000);
  });
  tearDown(() => db.close());

  List<List<String>> csvOf(ExportFile f) => parseCsv(utf8.decode(f.bytes));

  test('repositório lê dados reais, com pago somado e sem excluídos por padrão', () async {
    final d = await ExportRepository(db).load(exportedAt: now, includeDeleted: false);
    expect(d.bills.map((b) => b.name), ['Aluguel']);
    expect(d.bills.single.paidCents, 180000);
    expect(d.bills.single.categoryName, 'Moradia');
    expect(d.payments.length, 2);
    expect(d.payments.first.billName, 'Aluguel');
    expect(d.categories.length, 11);
    expect(d.categories.first.colorHex, matches(RegExp(r'^#[0-9A-F]{6}$')));
    expect(d.planning.map((p) => p.scope), ['padrao', '2026-11']);
  });

  test('includeDeleted traz a conta excluída com excluido_em', () async {
    final d = await ExportRepository(db).load(exportedAt: now, includeDeleted: true);
    expect(d.bills.map((b) => b.name).toSet(), {'Aluguel', 'Excluída'});
    expect(d.bills.firstWhere((b) => b.name == 'Excluída').deletedAt, isNotNull);
  });

  test('um conjunto vira CSV único com a data no nome', () async {
    final f = await service.build(const ExportOptions(datasets: {ExportDataset.bills}));
    expect(f.name, 'contas_2026-10-10.csv');
    expect(f.mime, 'text/csv');
    final r = csvOf(f);
    expect(r.length, 2);
    expect(r[1][1], 'Aluguel');
    expect(r[1][11], 'paga');
  });

  test('vários conjuntos viram ZIP com CSVs e LEIA-ME', () async {
    final f = await service.build(const ExportOptions(datasets: {ExportDataset.bills, ExportDataset.payments, ExportDataset.planning}, delimiter: CsvDelimiter.semicolon));
    expect(f.name, 'finance_hub_2026-10-10.zip');
    expect(f.mime, 'application/zip');
    final zip = ZipDecoder().decodeBytes(f.bytes);
    expect(zip.files.map((x) => x.name), ['contas.csv', 'pagamentos.csv', 'planejamento.csv', 'LEIA-ME.txt']);
    final pays = parseCsv(utf8.decode(zip.findFile('pagamentos.csv')!.content as List<int>), delimiter: ';');
    expect(pays.length, 3);
    expect(pays[1][3], '1000,00');
    expect(utf8.decode(zip.findFile('LEIA-ME.txt')!.content as List<int>), contains('ponto e vírgula'));
  });

  test('nenhum conjunto ou formato indisponível → ValidationError', () async {
    expect(() => service.build(const ExportOptions(datasets: {})), throwsA(isA<ValidationError>()));
    expect(() => service.build(const ExportOptions(datasets: {ExportDataset.bills}, format: ExportFormat.pdf)), throwsA(isA<ValidationError>()));
  });

  test('export entrega ao saver; cancelamento é informado', () async {
    expect(await service.export(const ExportOptions(datasets: {ExportDataset.bills})), ExportOutcome.saved);
    expect(saver.name, 'contas_2026-10-10.csv');
    expect(saver.bytes, isNotEmpty);
    final cancelled = ExportService(repository: ExportRepository(db), saver: FakeSaver(result: false), clock: () => now);
    expect(await cancelled.export(const ExportOptions(datasets: {ExportDataset.bills})), ExportOutcome.cancelled);
  });

  test('exportar não altera os dados', () async {
    final before = await db.select(db.transactions).get();
    await service.export(ExportOptions(datasets: ExportDataset.values.toSet(), includeDeleted: true));
    final after = await db.select(db.transactions).get();
    expect(after.length, before.length);
    expect(after.map((t) => t.updatedAt), before.map((t) => t.updatedAt));
  });
}
