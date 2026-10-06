import 'package:finance_hub/application/bill_service.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/defaults_helpers.dart';
import 'test_harness.dart';

const wide = Size(1400, 1100);

Future<String> mk(Harness h, String name, int cents, DateTime due, {int paid = 0}) async {
  final repo = TransactionRepository(h.db);
  final id = await h.run(() => repo.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: 'cat-moradia', expenseType: ExpenseType.fixed));
  if (paid > 0) await h.run(() => repo.addPayment(transactionId: id, amountCents: paid, paidAt: DateTime.utc(2026, 10, 2)));
  return id;
}

Finder inRail(String text) => find.descendant(of: find.byKey(const Key('upcoming-rail')), matching: find.text(text));

Future<void> nextMonth(WidgetTester t, Harness h) async {
  await scrollToTop(t); // o seletor de mês fica no topo da página
  await t.tap(find.byTooltip('Próximo mês').first);
  await h.settle();
}

Future<void> prevMonth(WidgetTester t, Harness h) async {
  await scrollToTop(t);
  await t.tap(find.byTooltip('Mês anterior').first);
  await h.settle();
}

void main() {
  setUpAll(initHarness);

  group('o que aparece segue o mês selecionado', () {
    appTest('carrossel: só as contas ainda a pagar do mês exibido, e acompanha a troca de mês', size: wide, (t, h) async {
      await mk(h, 'Aluguel', 100000, DateTime(2026, 10, 5), paid: 100000); // paga: fora
      await mk(h, 'Luz', 20000, DateTime(2026, 10, 20));
      await mk(h, 'Internet', 12000, DateTime(2026, 10, 22));
      await mk(h, 'Seguro', 50000, DateTime(2026, 11, 3));
      await mk(h, 'Cartão', 90000, DateTime(2026, 9, 15)); // vencida, mas de setembro
      await h.settle();

      expect(find.text('A pagar em Outubro'), findsOneWidget);
      expect(inRail('Luz'), findsOneWidget);
      expect(inRail('Internet'), findsOneWidget);
      for (final other in ['Aluguel', 'Seguro', 'Cartão']) {
        expect(inRail(other), findsNothing, reason: '$other não é a pagar em outubro');
      }

      await nextMonth(t, h);
      expect(find.text('A pagar em Novembro'), findsOneWidget);
      expect(inRail('Seguro'), findsOneWidget);
      expect(inRail('Luz'), findsNothing);

      await prevMonth(t, h);
      await prevMonth(t, h);
      expect(find.text('A pagar em Setembro'), findsOneWidget);
      expect(inRail('Cartão'), findsOneWidget); // em setembro, a vencida de setembro
      expect(inRail('Seguro'), findsNothing);
    });

    appTest('mês sem nada a pagar não mostra o carrossel', size: wide, (t, h) async {
      await mk(h, 'Luz', 20000, DateTime(2026, 10, 20));
      await h.settle();
      expect(find.byKey(const Key('upcoming-rail')), findsOneWidget);
      await nextMonth(t, h);
      expect(find.byKey(const Key('upcoming-rail')), findsNothing);
    });

    appTest('alertas de vencimento só contam as contas do mês exibido', size: wide, (t, h) async {
      await mk(h, 'Velha de setembro', 10000, DateTime(2026, 9, 5)); // vencida, de outro mês
      await mk(h, 'Atrasada', 10000, DateTime(2026, 10, 5)); // vencida, de outubro
      await h.settle();
      expect(find.text('1 conta está vencida'), findsOneWidget); // só a de outubro
      await nextMonth(t, h);
      expect(find.text('1 conta está vencida'), findsNothing); // novembro não herda as de outubro
      expect(find.text('Nada vencendo nos próximos 30 dias.'), findsOneWidget);
      await prevMonth(t, h);
      await prevMonth(t, h);
      expect(find.text('1 conta está vencida'), findsOneWidget); // setembro mostra a dele
    });
  });

  group('desmarcar como pago e desfazer lançamentos', () {
    appTest('conta paga: "Desmarcar como pago" volta a conta para pendente e dá para desfazer', (t, h) async {
      await mk(h, 'Internet', 12000, DateTime(2026, 10, 12), paid: 12000);
      await goToBills(h);
      await t.tap(find.text('Todas'));
      await h.settle();
      await t.tap(find.text('Internet'));
      await h.settle();
      expect(find.text('Paga'), findsWidgets);

      await t.tap(find.byKey(const Key('unpay-button')));
      await h.settle();
      expect(find.text('Desmarcar como pago?'), findsOneWidget);
      await t.tap(find.byKey(const Key('unpay-confirm')));
      await h.settle();
      // a folha fechou e a conta está pendente na lista
      expect(find.byKey(const Key('unpay-button')), findsNothing);
      expect(find.text('Pendente'), findsWidgets);
      final billId = (await h.run(() => h.db.select(h.db.transactions).get())).single.id;
      expect((await h.run(() => TransactionRepository(h.db).paymentCount(billId))), 0);
      // o pagamento não foi apagado de verdade: continua no banco, só marcado como excluído
      expect((await h.run(() => h.db.select(h.db.payments).get())).single.deletedAt, isNotNull);

      expect(find.text('Pagamentos removidos'), findsOneWidget);
      await t.tap(find.text('Desfazer')); // da barra de aviso, já com a folha fechada
      await h.settle();
      expect((await h.run(() => h.db.select(h.db.payments).get())).single.deletedAt, isNull);
      expect(find.text('Pendente'), findsNothing); // a conta voltou a estar paga (aba Todas mostra "Paga")
      expect(find.text('Paga'), findsWidgets);
    });

    appTest('pagamento parcial: o botão é "Desfazer pagamentos" e cancelar não muda nada', (t, h) async {
      final id = await mk(h, 'Cartão', 100000, DateTime(2026, 10, 25));
      await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 30000));
      await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 20000));
      await goToBills(h);
      await t.tap(find.text('Cartão'));
      await h.settle();
      expect(find.text('Desfazer pagamentos'), findsOneWidget);
      await t.tap(find.byKey(const Key('unpay-button')));
      await h.settle();
      expect(find.textContaining('2 pagamentos (R\$ 500,00 no total)'), findsOneWidget);
      await t.tap(find.text('Cancelar'));
      await h.settle();
      expect((await h.run(() => h.db.select(h.db.payments).get())).every((p) => p.deletedAt == null), isTrue);
      await t.tap(find.byKey(const Key('unpay-button')));
      await h.settle();
      await t.tap(find.byKey(const Key('unpay-confirm')));
      await h.settle();
      expect((await h.run(() => h.db.select(h.db.payments).get())).every((p) => p.deletedAt != null), isTrue);
    });

    appTest('excluir um pagamento do histórico pede confirmação e recalcula a conta', (t, h) async {
      final id = await mk(h, 'Água', 8000, DateTime(2026, 10, 15), paid: 8000);
      await goToBills(h);
      await t.tap(find.text('Todas'));
      await h.settle();
      await t.tap(find.text('Água'));
      await h.settle();
      await tapVisible(t, h, find.byTooltip('Excluir pagamento'));
      await t.tap(find.widgetWithText(FilledButton, 'Excluir')); // o da confirmação
      await h.settle();
      expect((await h.run(() => TransactionRepository(h.db).paymentCount(id))), 0);
      expect((await h.run(() => h.db.select(h.db.payments).get())).single.deletedAt, isNotNull); // só marcado, não apagado
    });

    appTest('renda: lançamentos do mês aparecem e podem ser desfeitos', size: wide, (t, h) async {
      await h.run(() => PlanningRepository(h.db).defaultsFrom('2026-01', salary: 800000));
      await h.run(() => PlanningRepository(h.db).addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 30000, description: 'Freela'));
      await h.settle();
      await scrollTo(t, find.text('Freela'));
      expect(find.text('LANÇAMENTOS DO MÊS'), findsWidgets);
      expect(find.text('Freela'), findsOneWidget);
      expect(textOfKey(t, 'income-total'), 'R\$ 8.300,00');

      await tapVisible(t, h, find.byTooltip('Desfazer lançamento').first);
      expect(find.text('Freela'), findsNothing);
      expect(textOfKey(t, 'income-total'), 'R\$ 8.000,00');
      expect((await h.run(() => h.db.select(h.db.incomes).get())).single.deletedAt, isNotNull); // só marcado, não apagado

      await t.tap(find.text('Desfazer')); // da barra de aviso
      await h.settle();
      expect(find.text('Freela'), findsOneWidget);
      expect(textOfKey(t, 'income-total'), 'R\$ 8.300,00');
    });

    appTest('investimento: "Marcar meta como realizada" oferece desfazer na hora, e o lançamento pode ser removido depois', size: wide, (t, h) async {
      await h.run(() => PlanningRepository(h.db).defaultsFrom('2026-01', investment: 200000));
      await h.settle();
      await tapVisible(t, h, find.text('Marcar meta como realizada'));
      expect(find.text('Meta marcada como realizada'), findsOneWidget);
      expect((await h.run(() => h.db.select(h.db.investments).get())).single.realizedCents, 200000);
      expect(find.text('100% da meta'), findsOneWidget);

      await t.tap(find.text('Desfazer')); // sem querer: volta ao que era
      await h.settle();
      expect((await h.run(() => h.db.select(h.db.investments).get())).single.deletedAt, isNotNull);
      expect(find.text('0% da meta'), findsOneWidget);

      // registra de novo e remove pelo botão do lançamento
      await tapVisible(t, h, find.text('Marcar meta como realizada'));
      await tapVisible(t, h, find.byTooltip('Desfazer lançamento').last);
      expect(find.text('0% da meta'), findsOneWidget);
    });
  });

  group('padrões com vigência na interface', () {
    appTest('mudar o padrão em outubro vale de outubro em diante; setembro continua como estava', size: wide, (t, h) async {
      await h.run(() => PlanningRepository(h.db).defaultsFrom('2026-01', salary: 800000));
      await h.settle();
      expect(textOfKey(t, 'income-total'), 'R\$ 8.000,00');

      await tapVisible(t, h, find.text('Valores padrão'));
      expect(find.byKey(const Key('defaults-from-note')), findsOneWidget);
      expect(t.widget<Text>(find.byKey(const Key('defaults-from-note'))).data, contains('a partir de Outubro 2026'));
      expect(t.widget<Text>(find.byKey(const Key('defaults-from-note'))).data, contains('anteriores não mudam'));
      await t.enterText(find.widgetWithText(TextFormField, 'Salário líquido padrão'), '9000');
      await tapSave(t);
      await h.settle();
      expect(textOfKey(t, 'income-total'), 'R\$ 9.000,00'); // outubro

      await prevMonth(t, h);
      expect(textOfKey(t, 'income-total'), 'R\$ 8.000,00'); // setembro NÃO mudou
      await nextMonth(t, h);
      await nextMonth(t, h);
      expect(textOfKey(t, 'income-total'), 'R\$ 9.000,00'); // novembro herda o novo
    });

    appTest('mês anterior a qualquer padrão não tem renda inventada', size: wide, (t, h) async {
      await h.run(() => PlanningRepository(h.db).defaultsFrom('2026-10', salary: 800000));
      await h.settle();
      expect(textOfKey(t, 'income-total'), 'R\$ 8.000,00');
      await prevMonth(t, h);
      expect(textOfKey(t, 'income-total'), 'R\$ 0,00'); // setembro: o padrão só começou em outubro
    });
  });

  group('aparência: Automático, Claro e Escuro', () {
    appTest('o padrão é Automático; escolher Claro/Escuro/Automático muda o tema do app', (t, h) async {
      ThemeMode mode() => t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
      expect(mode(), ThemeMode.system);

      Future<void> choose(String key) async {
        await t.tap(find.byKey(const Key('theme-toggle')));
        await h.settle();
        expect(find.text('Aparência'), findsOneWidget);
        expect(find.text('Automático'), findsOneWidget);
        await t.tap(find.byKey(Key(key)));
        await h.settle();
      }

      await choose('theme-option-light');
      expect(mode(), ThemeMode.light);
      await choose('theme-option-dark');
      expect(mode(), ThemeMode.dark);
      await choose('theme-option-system');
      expect(mode(), ThemeMode.system);
    });
  });

  group('serviço', () {
    appTest('removeAllPayments/restorePayments: reversível e sem apagar nada de verdade', (t, h) async {
      final id = await mk(h, 'X', 10000, DateTime(2026, 10, 12), paid: 4000);
      final svc = BillService(bills: BillRepository(h.db), transactions: TransactionRepository(h.db), clock: () => fixedNow);
      final ids = await h.run(() => svc.removeAllPayments(id));
      expect(ids.length, 1);
      expect((await h.run(() => BillRepository(h.db).getBill(id)))!.paidCents, 0);
      await h.run(() => svc.restorePayments(ids));
      expect((await h.run(() => BillRepository(h.db).getBill(id)))!.paidCents, 4000);
    });
  });
}

/// Texto de um widget com chave (a `Text` direta ou dentro de um `MoneyText`).
String textOfKey(WidgetTester t, String key) {
  final keyed = find.byKey(Key(key));
  final text = t.any(find.descendant(of: keyed, matching: find.byType(Text))) ? find.descendant(of: keyed, matching: find.byType(Text)) : keyed;
  return t.widget<Text>(text).data!;
}
