import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/recurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

RecurrenceService serviceFor(AppDatabase db) => RecurrenceService(
      rules: RecurringRepository(db),
      transactions: TransactionRepository(db),
      bills: BillRepository(db),
      clock: () => fixedNow,
    );

/// Netflix mensal a partir de hoje (10/10/2026), R$ 39,90.
Future<void> seedNetflix(AppDatabase db) async {
  await serviceFor(db).createRecurring(
    name: 'Netflix',
    amountCents: 3990,
    firstDue: DateTime(2026, 10, 10),
    categoryId: 'cat-assinaturas',
    expenseType: ExpenseType.fixed,
    frequency: Frequency.monthly,
  );
}

Future<void> nextMonth(WidgetTester t, Harness h) async {
  await t.tap(find.byTooltip('Próximo mês'));
  await h.settle();
}

Finder inDialog(String text) => find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

void main() {
  setUpAll(initHarness);

  appTest('criar conta recorrente mensal gera ocorrências nos meses seguintes', (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Adicionar'));
    await h.settle();
    await t.enterText(field('Nome'), 'Netflix');
    await t.enterText(field('Valor'), '39,90');
    await t.tap(find.byKey(const Key('recurrence-dropdown')));
    await h.settle();
    await t.tap(find.text('Mensal').last);
    await h.settle();
    expect(find.textContaining('Primeiro vencimento: 10/10/2026'), findsOneWidget);
    await tapVisible(t, h, find.text('Salvar'));

    expect(find.text('Netflix'), findsOneWidget); // outubro
    await nextMonth(t, h);
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await nextMonth(t, h);
    }
    expect(find.text('Abril 2027'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget); // indicador de recorrência
  });

  appTest('intervalo personalizado exige valor válido', (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Adicionar'));
    await h.settle();
    await t.enterText(field('Nome'), 'Vacina');
    await t.enterText(field('Valor'), '50');
    await t.tap(find.byKey(const Key('recurrence-dropdown')));
    await h.settle();
    await t.tap(find.text('Personalizado (a cada N dias)').last);
    await h.settle();
    await t.enterText(field('A cada (dias)'), '0');
    await tapVisible(t, h, find.text('Salvar'));
    expect(find.text('Use de 1 a 999'), findsOneWidget);
    expect(find.text('Nova conta'), findsOneWidget); // continua aberto
  });

  appTest('detalhe mostra a frequência e o histórico de valores com gráfico', seed: seedNetflix, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    expect(find.text('Mensal'), findsOneWidget);
    await scrollTo(t, find.text('HISTÓRICO DE VALORES'));
    await scrollTo(t, find.byKey(const Key('value-history-chart')));
    expect(find.byKey(const Key('value-history-chart')), findsOneWidget);
    expect(find.byKey(const Key('value-history-unchanged')), findsOneWidget);
    expect(find.textContaining('tracejada'), findsOneWidget); // ocorrências futuras
  });

  appTest('editar esta e as próximas muda o valor adiante e o histórico mostra a mudança', seed: seedNetflix, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Editar'));
    await t.enterText(field('Valor'), '44,90');
    await tapVisible(t, h, find.text('Salvar'));
    expect(find.text('Aplicar a quais ocorrências?'), findsOneWidget);
    await t.tap(find.text('Esta e as próximas'));
    await t.pump();
    await t.tap(inDialog('Salvar'));
    await h.settle();

    await scrollToTop(t); // o detalhe foi rolado até o botão Editar
    await t.tap(find.byTooltip('Fechar'));
    await h.settle();
    await nextMonth(t, h);
    expect(find.text('R\$ 44,90'), findsOneWidget); // novembro já com o novo valor
  });

  appTest('editar somente esta não altera as próximas', seed: seedNetflix, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Editar'));
    await t.enterText(field('Valor'), '50');
    await tapVisible(t, h, find.text('Salvar'));
    await t.tap(inDialog('Salvar')); // padrão: somente esta
    await h.settle();
    await scrollToTop(t);
    await t.tap(find.byTooltip('Fechar'));
    await h.settle();
    expect(find.text('R\$ 50,00'), findsOneWidget);
    await nextMonth(t, h);
    expect(find.text('R\$ 39,90'), findsOneWidget);
  });

  appTest('histórico mostra a mudança de 39,90 para 44,90 sem explicação', seed: (db) async {
    await seedNetflix(db);
    final svc = serviceFor(db);
    final bills = BillRepository(db);
    final nov = (await bills.getOccurrences((await RecurringRepository(db).getActiveRules()).single.id)).firstWhere((b) => b.dueDate.month == 11);
    await svc.editOccurrence(nov.id, EditScope.thisAndFollowing, plannedCents: 4490);
  }, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await scrollTo(t, find.text('HISTÓRICO DE VALORES'));
    await scrollTo(t, find.textContaining('para R\$ 44,90'));
    expect(find.text('nov/26: R\$ 39,90 para R\$ 44,90 (+R\$ 5,00)'), findsOneWidget);
  });

  appTest('excluir recorrência pergunta o alcance e "somente esta" mantém as outras', seed: seedNetflix, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Excluir'));
    expect(find.text('Excluir recorrência'), findsOneWidget);
    expect(find.text('Excluir apenas esta ocorrência'), findsOneWidget);
    expect(find.text('Excluir esta e as próximas'), findsOneWidget);
    expect(find.text('Excluir toda a recorrência'), findsOneWidget);
    await t.tap(inDialog('Excluir'));
    await h.settle();
    expect(find.text('1 ocorrência excluída'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing); // outubro vazio
    await nextMonth(t, h);
    expect(find.text('Netflix'), findsOneWidget); // novembro permanece
  });

  appTest('excluir esta e as próximas encerra a recorrência', seed: seedNetflix, (t, h) async {
    await goToBills(h);
    await nextMonth(t, h); // novembro
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Excluir'));
    await t.tap(find.text('Excluir esta e as próximas'));
    await t.pump();
    await t.tap(inDialog('Excluir'));
    await h.settle();
    expect(find.textContaining('ocorrências excluídas'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);
    await nextMonth(t, h);
    expect(find.text('Netflix'), findsNothing); // dezembro também
    await t.tap(find.byTooltip('Mês anterior'));
    await t.tap(find.byTooltip('Mês anterior'));
    await h.settle();
    expect(find.text('Netflix'), findsOneWidget); // outubro (passado da regra) permanece
  });

  appTest('excluir toda a recorrência informa o que foi mantido', seed: (db) async {
    await seedNetflix(db);
    // uma ocorrência futura com pagamento deve permanecer
    final bills = BillRepository(db);
    final rid = (await RecurringRepository(db).getActiveRules()).single.id;
    final dec = (await bills.getOccurrences(rid)).firstWhere((b) => b.dueDate.month == 12 && b.dueDate.year == 2026);
    await TransactionRepository(db).addPayment(transactionId: dec.id, amountCents: 1000);
  }, (t, h) async {
    await goToBills(h);
    await t.tap(find.text('Netflix'));
    await h.settle();
    await tapVisible(t, h, find.text('Excluir'));
    await t.tap(find.text('Excluir toda a recorrência'));
    await t.pump();
    await t.tap(inDialog('Excluir'));
    await h.settle();
    expect(find.textContaining('1 com pagamento mantidas'), findsOneWidget);
    await nextMonth(t, h);
    await nextMonth(t, h); // dezembro
    expect(find.text('Netflix'), findsOneWidget); // a com pagamento ficou
  });

  appTest('Dashboard conta as ocorrências recorrentes nos gastos do mês', seed: seedNetflix, size: const Size(1400, 1000), (t, h) async {
    expect(find.text('R\$ 39,90'), findsWidgets);
    expect(find.text('GASTOS DO MÊS'), findsOneWidget);
  });
}
