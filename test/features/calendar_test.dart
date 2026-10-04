import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

const wide = Size(1400, 1000);

Future<String> add(AppDatabase db, String name, int cents, DateTime due, {int paid = 0, bool canceled = false}) async {
  final repo = TransactionRepository(db);
  final id = await repo.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: 'cat-assinaturas', expenseType: ExpenseType.fixed);
  if (paid > 0) await repo.addPayment(transactionId: id, amountCents: paid, paidAt: DateTime.utc(2026, 10, 2));
  if (canceled) await repo.cancel(id);
  return id;
}

/// Hoje = 10/10/2026 (sábado).
Future<void> seedMonth(AppDatabase db) async {
  await add(db, 'YouTube Premium', 2490, DateTime(2026, 10, 10)); // hoje → em breve
  await add(db, 'Internet', 12000, DateTime(2026, 10, 12)); // em breve
  await add(db, 'Aluguel', 180000, DateTime(2026, 10, 28)); // futuro
  await add(db, 'Energia', 21000, DateTime(2026, 10, 3), paid: 21000); // paga
  await add(db, 'Velha', 5000, DateTime(2026, 10, 5)); // vencida
  await add(db, 'Parcial', 10000, DateTime(2026, 10, 20), paid: 3000); // futuro (parcial)
}

Future<void> goToCalendar(Harness h) async {
  await h.tester.tap(find.byKey(const Key('nav-Calendário')));
  await h.settle();
}

Finder dot(int day, int index, String tone) => find.byKey(ValueKey('cal-dot-$day-$index-$tone'));
Finder dots(int day) => find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('cal-dot-$day-'));

/// Tom do chip da conta [name] (procura a chave `cal-event-<tom>-...` no ancestral do texto).
String? eventTone(WidgetTester t, String name) {
  for (final tone in ['paid', 'overdue', 'soon', 'future']) {
    final f = find.ancestor(
      of: find.text(name),
      matching: find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('cal-event-$tone-')),
    );
    if (t.any(f)) return tone;
  }
  return null;
}

void main() {
  setUpAll(initHarness);

  group('telas largas: contas dentro do dia', () {
    appTest('cada conta aparece no seu dia, com nome e valor', size: wide, seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      Finder inCell(int day, String text) => find.descendant(of: find.byKey(ValueKey('cal-cell-$day')), matching: find.text(text));
      expect(inCell(10, 'YouTube Premium'), findsOneWidget);
      expect(inCell(10, 'R\$ 24,90'), findsOneWidget);
      expect(inCell(12, 'Internet'), findsOneWidget);
      expect(inCell(12, 'R\$ 120,00'), findsOneWidget);
      expect(inCell(28, 'Aluguel'), findsOneWidget);
      expect(inCell(11, 'Internet'), findsNothing);
    });

    appTest('cores por estado: amarelo, verde, vermelho e neutro', size: wide, seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      expect(eventTone(t, 'YouTube Premium'), 'soon');
      expect(eventTone(t, 'Internet'), 'soon');
      expect(eventTone(t, 'Energia'), 'paid');
      expect(eventTone(t, 'Velha'), 'overdue');
      expect(eventTone(t, 'Aluguel'), 'future');
      expect(eventTone(t, 'Parcial'), 'future');
    });

    appTest('a legenda explica as quatro cores', size: wide, (t, h) async {
      await goToCalendar(h);
      for (final l in ['Pago', 'Vencida', 'Vence em até 7 dias', 'Futuro']) {
        expect(find.text(l), findsOneWidget);
      }
    });

    appTest('tocar na conta abre o detalhe', size: wide, seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      await t.tap(find.text('Internet'));
      await h.settle();
      expect(find.text('Marcar como pago'), findsOneWidget);
      expect(find.text('R\$ 120,00'), findsWidgets);
    });

    appTest('mais de 3 contas no dia: "+N mais" abre a lista completa do dia', size: wide, seed: (db) async {
      for (var i = 1; i <= 5; i++) {
        await add(db, 'Conta $i', 1000 * i, DateTime(2026, 10, 20));
      }
    }, (t, h) async {
      await goToCalendar(h);
      final cell = find.byKey(const ValueKey('cal-cell-20'));
      expect(find.descendant(of: cell, matching: find.textContaining('Conta ')), findsNWidgets(3));
      expect(find.text('+2 mais'), findsOneWidget);
      await t.tap(find.text('+2 mais'));
      await h.settle();
      expect(find.text('Terça-feira, 20 de outubro'), findsOneWidget);
      expect(find.text('5 contas · R\$ 150,00'), findsOneWidget);
      for (var i = 1; i <= 5; i++) {
        expect(find.text('Conta $i'), findsWidgets);
      }
    });

    appTest('contas canceladas não aparecem', size: wide, seed: (db) async {
      await add(db, 'Cancelada', 1000, DateTime(2026, 10, 15), canceled: true);
      await add(db, 'Normal', 1000, DateTime(2026, 10, 16));
    }, (t, h) async {
      await goToCalendar(h);
      expect(find.text('Cancelada'), findsNothing);
      expect(find.text('Normal'), findsOneWidget);
    });

    appTest('navegar de mês troca a grade; mês sem contas fica vazio', size: wide, seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      expect(find.text('Outubro 2026'), findsOneWidget);
      await t.tap(find.byTooltip('Próximo mês'));
      await h.settle();
      expect(find.text('Novembro 2026'), findsOneWidget);
      expect(find.text('Internet'), findsNothing);
      expect(find.byKey(const ValueKey('cal-cell-30')), findsOneWidget);
      expect(find.byKey(const ValueKey('cal-cell-31')), findsNothing); // novembro tem 30 dias
      await t.tap(find.byTooltip('Mês anterior'));
      await h.settle();
      expect(find.text('Internet'), findsOneWidget);
    });

    appTest('recorrência mensal aparece no dia certo dos meses seguintes', size: wide, seed: (db) async {
      await RecurrenceService(
        rules: RecurringRepository(db),
        transactions: TransactionRepository(db),
        bills: BillRepository(db),
        clock: () => fixedNow,
      ).createRecurring(
        name: 'Netflix',
        amountCents: 3990,
        firstDue: DateTime(2026, 10, 10),
        categoryId: 'cat-assinaturas',
        expenseType: ExpenseType.fixed,
        frequency: Frequency.monthly,
      );
    }, (t, h) async {
      await goToCalendar(h);
      for (var i = 0; i < 3; i++) {
        await t.tap(find.byTooltip('Próximo mês'));
        await h.settle();
      }
      expect(find.text('Janeiro 2027'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('cal-cell-10')), matching: find.text('Netflix')), findsOneWidget);
      expect(eventTone(t, 'Netflix'), 'future');
    });
  });

  group('celular: pontos e lista do dia', () {
    appTest('pontos coloridos nos dias e agenda de hoje selecionada por padrão', seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      expect(dot(10, 0, 'soon'), findsOneWidget);
      expect(dot(3, 0, 'paid'), findsOneWidget);
      expect(dot(5, 0, 'overdue'), findsOneWidget);
      expect(dot(28, 0, 'future'), findsOneWidget);
      expect(t.widget<Text>(find.byKey(const Key('agenda-title'))).data, 'Sábado, 10 de outubro');
      expect(find.text('YouTube Premium'), findsOneWidget);
      expect(find.text('1 conta · R\$ 24,90'), findsOneWidget);
    });

    appTest('tocar em um dia mostra as contas dele; dia vazio avisa', seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      await t.tap(find.byKey(const ValueKey('cal-day-12')));
      await h.settle();
      expect(t.widget<Text>(find.byKey(const Key('agenda-title'))).data, 'Segunda-feira, 12 de outubro');
      expect(find.text('Internet'), findsOneWidget);
      expect(find.text('YouTube Premium'), findsNothing);
      await t.tap(find.byKey(const ValueKey('cal-day-13')));
      await h.settle();
      expect(find.text('Nenhum vencimento neste dia.'), findsOneWidget);
    });

    appTest('tocar na conta da lista abre o detalhe', seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      await t.tap(find.text('YouTube Premium'));
      await h.settle();
      expect(find.text('Marcar como pago'), findsOneWidget);
    });

    appTest('mais de 3 contas no dia: 3 pontos e um "+"', seed: (db) async {
      for (var i = 1; i <= 4; i++) {
        await add(db, 'Conta $i', 1000, DateTime(2026, 10, 20));
      }
    }, (t, h) async {
      await goToCalendar(h);
      final cell = find.byKey(const ValueKey('cal-day-20'));
      expect(dots(20), findsNWidgets(3)); // no máximo 3 pontos por dia
      expect(dot(20, 2, 'future'), findsOneWidget);
      expect(find.descendant(of: cell, matching: find.text('+')), findsOneWidget);
      await t.tap(cell);
      await h.settle();
      expect(find.text('4 contas · R\$ 40,00'), findsOneWidget);
    });

    appTest('mês sem hoje seleciona o primeiro dia com contas; mês vazio, o dia 1', seed: (db) async {
      await add(db, 'Natal', 5000, DateTime(2026, 12, 24));
    }, (t, h) async {
      await goToCalendar(h);
      await t.tap(find.byTooltip('Próximo mês'));
      await h.settle(); // novembro, vazio
      expect(t.widget<Text>(find.byKey(const Key('agenda-title'))).data, 'Domingo, 1 de novembro');
      expect(find.text('Nenhum vencimento neste dia.'), findsOneWidget);
      await t.tap(find.byTooltip('Próximo mês'));
      await h.settle(); // dezembro
      expect(t.widget<Text>(find.byKey(const Key('agenda-title'))).data, 'Quinta-feira, 24 de dezembro');
      expect(find.text('Natal'), findsOneWidget);
    });

    appTest('o dia escolhido é lembrado ao voltar ao mesmo mês', seed: seedMonth, (t, h) async {
      await goToCalendar(h);
      await t.tap(find.byKey(const ValueKey('cal-day-12')));
      await h.settle();
      await t.tap(find.byTooltip('Próximo mês'));
      await h.settle();
      await t.tap(find.byTooltip('Mês anterior'));
      await h.settle();
      expect(t.widget<Text>(find.byKey(const Key('agenda-title'))).data, 'Segunda-feira, 12 de outubro');
      expect(find.text('Internet'), findsOneWidget);
    });
  });
}
