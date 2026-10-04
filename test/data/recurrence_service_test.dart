import 'dart:io';

import 'package:drift/native.dart';
import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/core/dates.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/recurrence.dart';
import 'package:finance_hub/domain/value_history.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late RecurrenceService svc;
  late TransactionRepository tx;
  late BillRepository bills;
  late RecurringRepository rules;

  setUp(() {
    db = memoryDb();
    tx = TransactionRepository(db);
    bills = BillRepository(db);
    rules = RecurringRepository(db);
    // Hoje = 10/10/2026; horizonte padrão de 12 meses → 31/10/2027.
    svc = RecurrenceService(rules: rules, transactions: tx, bills: bills, clock: () => DateTime(2026, 10, 10, 12));
  });
  tearDown(() => db.close());

  Future<String> netflix({DateTime? first, DateTime? end, Frequency f = Frequency.monthly, int interval = 1, int cents = 3990}) =>
      svc.createRecurring(
        name: 'Netflix',
        amountCents: cents,
        firstDue: first ?? DateTime(2026, 10, 15),
        categoryId: 'cat-assinaturas',
        expenseType: ExpenseType.fixed,
        frequency: f,
        interval: interval,
        end: end,
      );

  Future<List<String>> activeDates(String ruleId) async => (await bills.getOccurrences(ruleId)).map((b) => isoDate(b.dueDate)).toList();

  group('geração', () {
    test('cria a regra e gera ocorrências até o horizonte (out/2026 a out/2027 = 13)', () async {
      final id = await netflix();
      final dates = await activeDates(id);
      expect(dates.length, 13);
      expect(dates.first, '2026-10-15');
      expect(dates.last, '2027-10-15');
      final b = (await bills.getOccurrences(id)).first;
      expect((b.name, b.plannedCents, b.categoryId, b.isRecurring), ('Netflix', 3990, 'cat-assinaturas', true));
    });

    test('é idempotente: repetir não cria nem duplica nada', () async {
      final id = await netflix();
      expect(await svc.ensureThrough(DateTime(2027, 10, 31)), 0);
      expect(await svc.ensureThrough(DateTime(2027, 10, 31)), 0);
      expect((await activeDates(id)).length, 13);
    });

    test('chamadas concorrentes não duplicam (serializadas + índice único)', () async {
      final id = await netflix();
      await Future.wait([svc.ensureThrough(DateTime(2029, 12, 31)), svc.ensureThrough(DateTime(2029, 12, 31)), svc.ensureMonth('2029-12')]);
      final dates = await activeDates(id);
      expect(dates.toSet().length, dates.length);
      expect(dates.last, '2029-12-15');
    });

    test('mês futuro distante é gerado sob demanda', () async {
      final id = await netflix();
      expect(await bills.getMonth('2030-03'), isEmpty);
      await svc.ensureMonth('2030-03');
      expect((await bills.getMonth('2030-03')).single.recurringId, id);
    });

    test('dia 31: fevereiro cai no último dia e março volta ao 31', () async {
      final id = await netflix(first: DateTime(2026, 12, 31));
      final dates = await activeDates(id);
      expect(dates, containsAll(['2026-12-31', '2027-01-31', '2027-02-28', '2027-03-31', '2027-04-30']));
    });

    test('data final limita a geração', () async {
      final id = await netflix(end: DateTime(2026, 12, 20));
      expect(await activeDates(id), ['2026-10-15', '2026-11-15', '2026-12-15']);
      await svc.ensureMonth('2030-01');
      expect((await activeDates(id)).length, 3);
    });

    test('semanal e personalizado (a cada N dias)', () async {
      final w = await netflix(first: DateTime(2026, 10, 1), f: Frequency.weekly, end: DateTime(2026, 10, 31));
      expect((await activeDates(w)), ['2026-10-01', '2026-10-08', '2026-10-15', '2026-10-22', '2026-10-29']);
      final c = await netflix(first: DateTime(2026, 10, 1), f: Frequency.custom, interval: 15, end: DateTime(2026, 11, 30));
      expect((await activeDates(c)), ['2026-10-01', '2026-10-16', '2026-10-31', '2026-11-15', '2026-11-30']);
    });

    test('início no passado gera o passado também (histórico)', () async {
      final id = await netflix(first: DateTime(2026, 1, 10));
      final dates = await activeDates(id);
      expect(dates.first, '2026-01-10');
      expect(dates, contains('2026-09-10'));
    });

    test('validações da regra', () {
      expect(() => rules.create(name: ' ', baseAmountCents: 1, categoryId: 'cat-outros', expenseType: ExpenseType.fixed, frequency: Frequency.monthly, start: DateTime(2026, 1, 1)),
          throwsA(isA<ValidationError>()));
      expect(() => netflix(cents: 0), throwsA(isA<ValidationError>()));
      expect(() => netflix(interval: 0), throwsA(isA<ValidationError>()));
      expect(() => netflix(end: DateTime(2026, 1, 1)), throwsA(isA<ValidationError>()));
    });

    test('índice único impede duplicata mesmo por inserção direta', () async {
      final id = await netflix();
      expect(
        () => tx.create(name: 'x', plannedAmountCents: 1, dueDate: DateTime(2026, 10, 15), categoryId: 'cat-outros', recurringId: id, occurrenceDate: DateTime(2026, 10, 15)),
        throwsA(isA<Object>()),
      );
    });
  });

  group('edição', () {
    test('somente esta: só ela muda e fica marcada como editada', () async {
      final id = await netflix();
      final all = await bills.getOccurrences(id);
      await svc.editOccurrence(all[2].id, EditScope.thisOnly, plannedCents: 5000);
      final after = await bills.getOccurrences(id);
      expect(after.map((b) => b.plannedCents).toSet(), {3990, 5000});
      expect(after.where((b) => b.plannedCents == 5000).length, 1);
      expect((await rules.getRule(id))!.baseAmountCents, 3990);
      await svc.ensureThrough(DateTime(2028, 12, 31));
      expect((await bills.getOccurrences(id)).last.plannedCents, 3990); // novas seguem a regra antiga
    });

    test('esta e as próximas: atualiza a regra e as futuras livres; preserva passadas, editadas e pagas', () async {
      final id = await netflix(first: DateTime(2026, 8, 15));
      final all = await bills.getOccurrences(id); // ago, set, out, nov, dez, ...
      final oct = all.firstWhere((b) => isoDate(b.dueDate) == '2026-10-15');
      final nov = all.firstWhere((b) => isoDate(b.dueDate) == '2026-11-15');
      final dec = all.firstWhere((b) => isoDate(b.dueDate) == '2026-12-15');
      final jan = all.firstWhere((b) => isoDate(b.dueDate) == '2027-01-15');
      await svc.editOccurrence(nov.id, EditScope.thisOnly, plannedCents: 4500); // editada à mão
      await tx.addPayment(transactionId: dec.id, amountCents: 100); // com pagamento

      final updated = await svc.editOccurrence(oct.id, EditScope.thisAndFollowing, plannedCents: 5990);
      final byDate = {for (final b in await bills.getOccurrences(id)) isoDate(b.dueDate): b};
      expect(byDate['2026-08-15']!.plannedCents, 3990); // passado intacto
      expect(byDate['2026-09-15']!.plannedCents, 3990);
      expect(byDate['2026-10-15']!.plannedCents, 5990); // a própria
      expect(byDate['2026-11-15']!.plannedCents, 4500); // editada à mão, preservada
      expect(byDate['2026-12-15']!.plannedCents, 3990); // com pagamento, preservada
      expect(byDate['2027-01-15']!.plannedCents, 5990);
      expect(jan.plannedCents, 3990);
      expect(updated, byDate.values.where((b) => b.dueDate.isAfter(DateTime(2026, 10, 15)) && b.plannedCents == 5990).length);
      expect((await rules.getRule(id))!.baseAmountCents, 5990);

      await svc.ensureThrough(DateTime(2028, 12, 31)); // novas ocorrências usam o novo valor
      expect((await bills.getOccurrences(id)).last.plannedCents, 5990);
    });

    test('histórico de valores reflete a mudança (24,90 → 27,90) sem inferir motivo', () async {
      final id = await netflix(first: DateTime(2026, 7, 10), cents: 2490);
      final mar = (await bills.getOccurrences(id)).firstWhere((b) => isoDate(b.dueDate) == '2026-10-10');
      await svc.editOccurrence(mar.id, EditScope.thisAndFollowing, plannedCents: 2790);
      final h = buildValueHistory(await bills.getOccurrences(id));
      expect(h.changes.length, 1);
      expect(h.changes.single.date, DateTime(2026, 10, 10));
      expect((h.changes.single.fromCents, h.changes.single.toCents), (2490, 2790));
    });

    test('esta e as próximas não aceita mudar o vencimento e nada é gravado', () async {
      final id = await netflix();
      final first = (await bills.getOccurrences(id)).first;
      expect(
        () => svc.editOccurrence(first.id, EditScope.thisAndFollowing, plannedCents: 9999, dueDate: DateTime(2026, 10, 20)),
        throwsA(isA<ValidationError>()),
      );
      expect((await bills.getBill(first.id))!.plannedCents, 3990);
    });

    test('mudar o vencimento só desta ocorrência não altera a data da ocorrência na regra', () async {
      final id = await netflix();
      final first = (await bills.getOccurrences(id)).first;
      await svc.editOccurrence(first.id, EditScope.thisOnly, dueDate: DateTime(2026, 10, 20));
      final b = (await bills.getBill(first.id))!;
      expect(isoDate(b.dueDate), '2026-10-20');
      expect(isoDate(b.occurrenceDate!), '2026-10-15');
      await svc.ensureThrough(DateTime(2027, 12, 31));
      expect((await bills.getOccurrences(id)).where((x) => isoDate(x.occurrenceDate!) == '2026-10-15').length, 1); // não recria
    });

    test('valor inválido é recusado', () async {
      final id = await netflix();
      final first = (await bills.getOccurrences(id)).first;
      expect(() => svc.editOccurrence(first.id, EditScope.thisOnly, plannedCents: 0), throwsA(isA<ValidationError>()));
    });
  });

  group('exclusão', () {
    test('somente esta: some, as outras ficam e ela não é recriada', () async {
      final id = await netflix();
      final all = await bills.getOccurrences(id);
      final r = await svc.deleteOccurrence(all[3].id, DeleteScope.thisOnly);
      expect((r.deleted, r.keptWithPayments, r.keptPast), (1, 0, 0));
      var dates = await activeDates(id);
      expect(dates.length, 12);
      expect(dates, isNot(contains(isoDate(all[3].dueDate))));
      await svc.ensureThrough(DateTime(2030, 1, 31));
      dates = await activeDates(id);
      expect(dates, isNot(contains(isoDate(all[3].dueDate)))); // continua excluída
      expect(await bills.getBill(all[2].id), isNotNull);
      expect(await bills.getBill(all[4].id), isNotNull);
    });

    test('conta excluída no meio de uma recorrência preserva o resto e seus pagamentos', () async {
      final id = await netflix(first: DateTime(2026, 8, 15));
      final all = await bills.getOccurrences(id);
      await tx.addPayment(transactionId: all[1].id, amountCents: 3990);
      await svc.deleteOccurrence(all[2].id, DeleteScope.thisOnly);
      expect((await bills.getBill(all[1].id))!.paidCents, 3990);
      expect(await db.select(db.payments).get(), hasLength(1));
    });

    test('esta e as próximas: apaga as futuras livres, mantém passadas e pagas, e encerra a regra', () async {
      final id = await netflix(first: DateTime(2026, 8, 15));
      final all = await bills.getOccurrences(id); // ago, set, out(2), nov(3), dez(4)...
      await tx.addPayment(transactionId: all[4].id, amountCents: 1000); // dez com pagamento
      final r = await svc.deleteOccurrence(all[3].id, DeleteScope.thisAndFollowing); // a partir de nov
      expect(r.keptWithPayments, 1);
      expect(r.deleted, all.length - 3 - 1); // nov em diante, menos a paga
      final left = await activeDates(id);
      expect(left, containsAll(['2026-08-15', '2026-09-15', '2026-10-15', '2026-12-15']));
      expect(left, isNot(contains('2026-11-15')));
      expect(left, isNot(contains('2027-01-15')));
      expect((await rules.getRule(id))!.end, DateTime(2026, 11, 14));
      await svc.ensureThrough(DateTime(2030, 1, 31)); // não volta
      expect((await activeDates(id)).length, left.length);
    });

    test('esta e as próximas a partir da primeira ocorrência encerra a regra por completo', () async {
      final id = await netflix(first: DateTime(2026, 10, 15));
      final first = (await bills.getOccurrences(id)).first;
      await svc.deleteOccurrence(first.id, DeleteScope.thisAndFollowing);
      expect(await activeDates(id), isEmpty);
      expect(await rules.getRule(id), isNull);
      expect(await svc.ensureThrough(DateTime(2030, 1, 31)), 0);
    });

    test('toda a recorrência: mantém o passado e o que tem pagamento; nunca apaga histórico em silêncio', () async {
      final id = await netflix(first: DateTime(2026, 7, 15)); // jul, ago, set (passado) + out... (futuro)
      final all = await bills.getOccurrences(id);
      final past = all.where((b) => b.dueDate.isBefore(DateTime(2026, 10, 10))).toList();
      expect(past.length, 3);
      await tx.addPayment(transactionId: all[past.length + 1].id, amountCents: 500); // nov pago
      final selected = all[past.length]; // out
      final r = await svc.deleteOccurrence(selected.id, DeleteScope.all);
      expect(r.keptPast, 3);
      expect(r.keptWithPayments, 1);
      expect(r.deleted, all.length - 3 - 1);
      final left = await bills.getOccurrences(id);
      expect(left.length, 4); // 3 passadas + 1 paga
      expect(await rules.getRule(id), isNull); // regra encerrada
      expect(await rules.getRuleIncludingDeleted(id), isNotNull); // mas ainda consultável
      await svc.ensureThrough(DateTime(2030, 1, 31));
      expect((await bills.getOccurrences(id)).length, 4);
    });

    test('excluir conta não recorrente continua simples', () async {
      final b = await tx.create(name: 'Avulsa', plannedAmountCents: 100, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-outros');
      final r = await svc.deleteOccurrence(b, DeleteScope.all);
      expect(r.deleted, 1);
      expect(await bills.getBill(b), isNull);
    });

    test('excluir ocorrência inexistente lança NotFoundError', () {
      expect(() => svc.deleteOccurrence('nada', DeleteScope.all), throwsA(isA<NotFoundError>()));
    });
  });

  test('recorrência aparece nos totais do mês como contas normais', () async {
    await netflix();
    await svc.ensureMonth('2026-11');
    final nov = await bills.getMonth('2026-11');
    expect(nov.length, 1);
    expect(nov.single.plannedCents, 3990);
  });

  group('migração v1 → v2', () {
    test('reabrir um banco v1 cria o índice único e preserva os dados', () async {
      final dir = await Directory.systemTemp.createTemp('fh_mig');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');

      var d1 = AppDatabase(NativeDatabase(file));
      final t = TransactionRepository(d1);
      final a = await t.create(name: 'A', plannedAmountCents: 100, dueDate: DateTime(2026, 10, 1), categoryId: 'cat-outros');
      await d1.customStatement('DROP INDEX uq_transactions_occurrence');
      await d1.customStatement('CREATE INDEX idx_transactions_recurring ON transactions (recurring_id, occurrence_date)');
      // duas linhas com o mesmo (regra, data): inválido na v2
      final ts = DateTime.utc(2026, 1, 1).toIso8601String();
      await d1.customStatement(
          "INSERT INTO recurring_transactions (id, created_at, updated_at, version, device_id, name, base_amount_cents, category_id, expense_type, frequency, interval_count, due_day, start_date, favorite) "
          "VALUES ('r1', '$ts', '$ts', 1, '', 'R', 100, 'cat-outros', 'fixed', 'monthly', 1, 1, '2026-01-01', 0)");
      for (final id in ['d1', 'd2']) {
        await d1.customStatement(
            "INSERT INTO transactions (id, created_at, updated_at, version, device_id, name, planned_amount_cents, due_date, category_id, expense_type, favorite, note, recurring_id, occurrence_date, overridden) "
            "VALUES ('$id', '$ts', '$ts', 1, '', 'Dup', 100, '2026-10-01', 'cat-outros', 'fixed', 0, '', 'r1', '2026-10-01', 0)");
      }
      await d1.customStatement('PRAGMA user_version = 1');
      await d1.close();

      final d2 = AppDatabase(NativeDatabase(file));
      addTearDown(d2.close);
      await d2.customSelect('SELECT 1').get(); // dispara a migração
      final idx = await d2.customSelect("SELECT name FROM sqlite_master WHERE type='index' AND name LIKE '%occurrence%'").get();
      expect(idx.map((r) => r.read<String>('name')), contains('uq_transactions_occurrence'));
      expect((await d2.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version'), 2);

      final rows = await d2.select(d2.transactions).get();
      expect(rows.length, 3); // nada foi apagado
      expect(rows.where((r) => r.recurringId == 'r1').length, 1); // a duplicata perdeu o vínculo
      expect(rows.firstWhere((r) => r.id == a).name, 'A');
    });
  });
}
