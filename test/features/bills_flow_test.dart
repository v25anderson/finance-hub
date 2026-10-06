import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/value_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

Future<String> seed(Harness h, String name, int cents, DateTime due, {bool fav = false}) => h.run(() =>
    TransactionRepository(h.db).create(
      name: name,
      plannedAmountCents: cents,
      dueDate: due,
      categoryId: 'cat-assinaturas',
      expenseType: ExpenseType.fixed,
      favorite: fav,
    ));

void main() {
  setUpAll(initHarness);

  appTest('mês sem contas mostra estado vazio', (t, h) async {
    await goToBills(h);
    expect(find.text('Sem contas neste mês.'), findsOneWidget);
    expect(find.text('Outubro 2026'), findsOneWidget);
  });

  appTest('cadastro rápido: FAB → preencher → salvar → aparece em Pendentes', (t, h) async {
    await goToBills(h);
    await t.tap(find.byTooltip('Adicionar'));
    await h.settle();
    expect(find.text('Nova conta'), findsOneWidget);

    await t.enterText(field('Nome'), 'YouTube Premium');
    await t.enterText(field('Valor'), '24,90');
    await tapSave(t);
    await h.settle();

    expect(find.text('YouTube Premium'), findsOneWidget);
    expect(find.text('R\$ 24,90'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
    expect(tabCount(t, 'pending'), '1');
  });

  appTest('validação: nome vazio e valor zero não salvam', (t, h) async {
    await goToBills(h);
    await t.tap(find.byTooltip('Adicionar'));
    await h.settle();
    await t.enterText(field('Valor'), '0');
    await tapSave(t);
    await h.settle();
    expect(find.text('Informe o nome'), findsOneWidget);
    expect(find.text('Informe um valor maior que zero'), findsOneWidget);
    expect(find.text('Nova conta'), findsOneWidget); // continua aberto
  });

  appTest('pagamento parcial: 2.000 → paga 800 → 1.200 restantes, 40%, parcialmente paga', (t, h) async {
    await seed(h, 'Cartão', 200000, DateTime(2026, 10, 25));
    await goToBills(h);
    await t.tap(find.text('Cartão'));
    await h.settle();

    await t.tap(find.text('Pagamento parcial'));
    await h.settle();
    await t.enterText(field('Valor'), '800');
    await t.tap(find.text('Registrar'));
    await h.settle();

    expect(find.text('Parcialmente paga'), findsWidgets);
    expect(find.text('40% pago'), findsOneWidget);
    expect(find.text('R\$ 800,00'), findsWidgets); // pago + histórico
    expect(find.text('R\$ 1.200,00'), findsOneWidget); // restante
    expect(find.text('Marcar como pago'), findsOneWidget);
  });

  appTest('segundo pagamento parcial soma e o histórico lista os dois', (t, h) async {
    final id = await seed(h, 'Cartão', 100000, DateTime(2026, 10, 25));
    await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 10000));
    await goToBills(h);
    await t.tap(find.text('Cartão'));
    await h.settle();
    await t.tap(find.text('Pagamento parcial'));
    await h.settle();
    await t.enterText(field('Valor'), '250');
    await t.tap(find.text('Registrar'));
    await h.settle();
    expect(find.text('35% pago'), findsOneWidget);
    await scrollTo(t, find.text('HISTÓRICO DE PAGAMENTOS'));
    await scrollTo(t, find.byTooltip('Excluir pagamento').last);
    expect(find.byTooltip('Excluir pagamento'), findsNWidgets(2));
  });

  appTest('marcar como pago quita o restante e a conta vai para Pagas', (t, h) async {
    final id = await seed(h, 'Internet', 12000, DateTime(2026, 10, 12));
    await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 2000));
    await goToBills(h);
    await t.tap(find.text('Internet'));
    await h.settle();

    await t.tap(find.text('Marcar como pago'));
    await h.settle();
    expect(find.text('Confirmar pagamento'), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.textContaining('restam R\$ 100,00')), findsOneWidget);
    await t.tap(find.text('Confirmar pagamento'));
    await h.settle();

    expect(find.text('100% pago'), findsOneWidget);
    final pay = t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Marcar como pago'));
    expect(pay.onPressed, isNull); // nada mais a pagar
    await scrollTo(t, find.text('HISTÓRICO DE PAGAMENTOS'));
    await scrollTo(t, find.byTooltip('Excluir pagamento').last);
    expect(find.byTooltip('Excluir pagamento'), findsNWidgets(2)); // histórico anterior preservado
    await scrollToTop(t);

    await t.tap(find.byTooltip('Fechar'));
    await h.settle();
    expect(tabCount(t, 'pending'), '0');
    expect(tabCount(t, 'paid'), '1');
  });

  appTest('pagamento maior que o restante avisa excedente e é aceito', (t, h) async {
    await seed(h, 'Luz', 10000, DateTime(2026, 10, 20));
    await goToBills(h);
    await t.tap(find.text('Luz'));
    await h.settle();
    await t.tap(find.text('Pagamento parcial'));
    await h.settle();
    await t.enterText(field('Valor'), '150');
    await t.pump();
    expect(find.textContaining('Excede o restante em R\$ 50,00'), findsOneWidget);
    await t.tap(find.text('Registrar'));
    await h.settle();
    expect(find.text('EXCEDENTE'), findsOneWidget);
    expect(find.text('100% pago'), findsOneWidget);
  });

  appTest('conta vencida e parcialmente paga aparece em Vencidas com os dois indicadores', (t, h) async {
    final id = await seed(h, 'Aluguel', 100000, DateTime(2026, 10, 5));
    await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 40000));
    await goToBills(h);
    expect(tabCount(t, 'pending'), '0');
    expect(tabCount(t, 'overdue'), '1');
    await t.tap(find.byKey(const Key('tab-overdue')));
    await h.settle();
    expect(find.text('Vencida'), findsOneWidget);
    expect(find.textContaining('Restam'), findsOneWidget);
  });

  appTest('favoritar e filtrar por Favoritos', (t, h) async {
    await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await seed(h, 'Academia', 9990, DateTime(2026, 10, 16), fav: true);
    await goToBills(h);
    expect(find.text('Netflix'), findsOneWidget);
    await t.tap(find.byTooltip('Filtrar favoritos'));
    await h.settle();
    expect(find.text('Netflix'), findsNothing);
    expect(find.text('Academia'), findsOneWidget);
  });

  appTest('editar conta atualiza a lista', (t, h) async {
    await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Editar'));
    await t.enterText(field('Valor'), '44,90');
    await tapSave(t);
    await h.settle();
    expect(find.text('R\$ 44,90'), findsWidgets);
  });

  appTest('duplicar cria nova conta só ao salvar', (t, h) async {
    await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Duplicar'));
    expect(find.text('Duplicar conta'), findsOneWidget);
    await tapSave(t);
    await h.settle();
    expect(find.text('Netflix (cópia)'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });

  appTest('excluir pede confirmação, preserva histórico e permite desfazer', (t, h) async {
    final id = await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await h.run(() => TransactionRepository(h.db).addPayment(transactionId: id, amountCents: 100));
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Excluir'));
    expect(find.text('Excluir conta?'), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await h.settle();
    expect(find.text('Netflix'), findsNothing);
    expect(await h.run(() => h.db.select(h.db.payments).get()), hasLength(1)); // histórico preservado

    await t.tap(find.text('Desfazer'));
    await h.settle();
    expect(find.text('Netflix'), findsOneWidget);
  });

  appTest('seletor de período: próximo mês fica vazio e voltar mostra as contas', (t, h) async {
    await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await goToBills(h);
    await t.tap(find.byTooltip('Próximo mês'));
    await h.settle();
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);
    await t.tap(find.byTooltip('Mês anterior'));
    await h.settle();
    expect(find.text('Netflix'), findsOneWidget);
  });

  appTest('seleção manual de mês e ano', (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Outubro 2026'));
    await h.settle();
    await t.tap(find.byTooltip('Próximo ano'));
    await t.pump();
    await t.tap(find.text('Mar'));
    await h.settle();
    expect(find.text('Março 2027'), findsOneWidget);
  });

  appTest('desktop: conta abre em painel lateral', size: const Size(1400, 900), (t, h) async {
    await seed(h, 'Netflix', 3990, DateTime(2026, 10, 15));
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await scrollTo(t, find.text('HISTÓRICO DE PAGAMENTOS'));
    expect(find.text('HISTÓRICO DE PAGAMENTOS'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    final panel = t.getRect(find.ancestor(of: find.text('HISTÓRICO DE PAGAMENTOS'), matching: find.byType(SizedBox)).first);
    expect(panel.right, greaterThan(1300)); // encostado à direita
  });

  group('faixa de valor (gasto variável)', () {
    Future<void> reveal(WidgetTester t, Finder f) =>
        t.scrollUntilVisible(f, 200, scrollable: find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first);

    Future<void> openForm(WidgetTester t, Harness h) async {
      await goToBills(h);
      await t.tap(find.byTooltip('Adicionar'));
      await h.settle();
    }

    Future<void> turnOnRange(WidgetTester t, Harness h, {required String min, required String max}) async {
      await reveal(t, find.byKey(const Key('range-switch')));
      await t.tap(find.byKey(const Key('range-switch')));
      await h.settle();
      await reveal(t, find.byKey(const Key('range-max')));
      await t.enterText(find.byKey(const Key('range-min')), min);
      await t.enterText(find.byKey(const Key('range-max')), max);
    }

    appTest('energia entre 200 e 300, valor esperado em branco: usa o meio e mostra a faixa', (t, h) async {
      await openForm(t, h);
      await t.enterText(field('Nome'), 'Energia');
      await turnOnRange(t, h, min: '200', max: '300');
      await tapSave(t);
      await h.settle();

      expect(find.text('Energia'), findsOneWidget);
      expect(find.text('R\$ 250,00'), findsOneWidget); // o meio da faixa
      expect(find.textContaining('Faixa R\$ 200,00 a R\$ 300,00'), findsOneWidget); // no item da lista
      expect(tabCount(t, 'pending'), '1');

      // detalhe: faixa e, depois de pagar, onde o total pago cai (só descreve)
      await t.tap(find.text('Energia'));
      await h.settle();
      expect(find.text('Faixa informada: R\$ 200,00 a R\$ 300,00'), findsOneWidget);
      expect(find.byKey(const Key('bill-range-position')), findsNothing); // ainda sem pagamento
      await t.tap(find.text('Marcar como pago'));
      await h.settle();
      await t.tap(find.text('Confirmar pagamento'));
      await h.settle();
      expect(find.text('O total pago está dentro da faixa informada.'), findsOneWidget);
    });

    appTest('valor esperado digitado precisa estar dentro da faixa', (t, h) async {
      await openForm(t, h);
      await t.enterText(field('Nome'), 'Energia');
      await t.enterText(field('Valor'), '350'); // antes de ligar a faixa (o campo vira "Valor esperado")
      await turnOnRange(t, h, min: '200', max: '300');
      await tapSave(t);
      await h.settle();
      // o erro está no campo "Valor esperado", lá em cima: volta ao topo do formulário para vê-lo
      await t.drag(find.descendant(of: find.byType(Form), matching: find.byType(Scrollable)).first, const Offset(0, 2000));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('Fora da faixa informada'), findsOneWidget);
      expect(find.text('Nova conta'), findsOneWidget); // não salvou
      expect(await h.run(() => h.db.select(h.db.transactions).get()), isEmpty);
    });

    appTest('máximo menor que o mínimo e campos vazios não salvam', (t, h) async {
      await openForm(t, h);
      await t.enterText(field('Nome'), 'Energia');
      await turnOnRange(t, h, min: '300', max: '200');
      await tapSave(t);
      await h.settle();
      expect(find.text('Menor que o mínimo'), findsOneWidget);
      await t.enterText(find.byKey(const Key('range-min')), '');
      await tapSave(t);
      await h.settle();
      expect(find.text('Informe o mínimo'), findsOneWidget);
      expect(await h.run(() => h.db.select(h.db.transactions).get()), isEmpty);
    });

    appTest('a opção de faixa só aparece para gasto variável', (t, h) async {
      await openForm(t, h);
      expect(find.byKey(const Key('range-switch')), findsOneWidget); // "Variável" é o tipo padrão
      await t.tap(find.text('Fixo'));
      await h.settle();
      expect(find.byKey(const Key('range-switch')), findsNothing);
    });

    appTest('editar uma conta com faixa preenche os campos e permite remover a faixa', (t, h) async {
      final id = await h.run(() => TransactionRepository(h.db).create(
          name: 'Água',
          plannedAmountCents: 8000,
          dueDate: DateTime(2026, 10, 18),
          categoryId: 'cat-moradia',
          expenseType: ExpenseType.variable,
          range: const ValueRange(6000, 9000)));
      await goToBills(h);
      await t.tap(find.text('Água'));
      await h.settle();
      await tapVisible(t, h, find.text('Editar'));
      await reveal(t, find.byKey(const Key('range-min')));
      expect(t.widget<TextFormField>(find.byKey(const Key('range-min'))).controller!.text, '60,00');
      expect(t.widget<TextFormField>(find.byKey(const Key('range-max'))).controller!.text, '90,00');
      await reveal(t, find.byKey(const Key('range-switch')));
      await t.tap(find.byKey(const Key('range-switch'))); // desliga
      await h.settle();
      await tapSave(t);
      await h.settle();
      final row = (await h.run(() => TransactionRepository(h.db).getById(id)))!;
      expect(row.plannedMinCents, isNull);
      expect(row.plannedMaxCents, isNull);
      expect(row.plannedAmountCents, 8000);
    });
  });
}
