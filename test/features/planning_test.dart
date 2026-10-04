import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

const wide = Size(1400, 1000);

Future<void> goToPlanning(Harness h) async {
  await h.tester.tap(find.byKey(const Key('nav-Planejamento')));
  await h.settle();
}

String balanceOf(WidgetTester t, String ym) =>
    t.widget<Text>(find.byKey(Key('projection-balance-$ym'))).data!;

String totalBalance(WidgetTester t) => t
    .widget<Text>(
      find.descendant(
        of: find.byKey(const Key('projection-total-balance')),
        matching: find.byType(Text),
      ),
    )
    .data!;

/// Padrões (8.000 + 500, invest. 2.000, meta 1.000), outubro com 3.800 pagos e 1.440 pendentes,
/// e a recorrência Netflix (39,90) mensal desde hoje.
Future<void> seedPlan(
  AppDatabase db, {
  bool recurring = true,
  bool withBills = true,
}) async {
  await PlanningRepository(db).updatePlanning(
    salaryCents: 800000,
    extraIncomeCents: 50000,
    savingsGoalCents: 100000,
    investmentCents: 200000,
  );
  final tx = TransactionRepository(db);
  if (withBills) {
    final a = await tx.create(
      name: 'Aluguel',
      plannedAmountCents: 380000,
      dueDate: DateTime(2026, 10, 5),
      categoryId: 'cat-moradia',
    );
    await tx.addPayment(
      transactionId: a,
      amountCents: 380000,
      paidAt: DateTime.utc(2026, 10, 2),
    );
    await tx.create(
      name: 'Cartão',
      plannedAmountCents: 144000,
      dueDate: DateTime(2026, 10, 25),
      categoryId: 'cat-outros',
    );
  }
  if (recurring) {
    await RecurrenceService(
      rules: RecurringRepository(db),
      transactions: tx,
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
  }
}

void main() {
  setUpAll(initHarness);

  group('valores padrão', () {
    appTest('mostra os padrões e permite editar', size: wide, seed: seedPlan, (
      t,
      h,
    ) async {
      await goToPlanning(h);
      expect(find.text('R\$ 8.000,00'), findsWidgets);
      await t.tap(find.text('Editar padrões'));
      await h.settle();
      await t.enterText(
        find.widgetWithText(TextFormField, 'Salário líquido padrão'),
        '9000',
      );
      await t.enterText(
        find.widgetWithText(TextFormField, 'Meta de economia padrão'),
        '1500',
      );
      await t.tap(find.text('Salvar'));
      await h.settle();
      final p = await h.run(() => PlanningRepository(h.db).getPlanning());
      expect(
        (
          p.defaultSalaryCents,
          p.defaultSavingsGoalCents,
          p.defaultExtraIncomeCents,
          p.defaultInvestmentCents,
        ),
        (900000, 150000, 50000, 200000),
      );
      expect(find.text('R\$ 9.000,00'), findsWidgets);
    });

    appTest('sem nada configurado: zeros, sem erros', size: wide, (t, h) async {
      await goToPlanning(h);
      expect(find.text('R\$ 0,00'), findsWidgets);
      expect(balanceOf(t, '2026-10'), 'R\$ 0,00');
      expect(totalBalance(t), 'R\$ 0,00');
    });
  });

  group('personalizar o mês', () {
    appTest(
      'só o mês escolhido muda; os demais seguem o padrão',
      size: wide,
      seed: (db) => seedPlan(db, recurring: false, withBills: false),
      (t, h) async {
        await goToPlanning(h);
        await t.tap(find.byKey(const Key('customize-switch')));
        await h.settle();
        await t.enterText(
          find.widgetWithText(TextFormField, 'Salário líquido'),
          '9200',
        );
        await t.enterText(
          find.widgetWithText(TextFormField, 'Renda extra'),
          '1000',
        );
        await t.enterText(
          find.widgetWithText(TextFormField, 'Investimento planejado'),
          '3000',
        );
        await tapVisible(t, h, find.text('Salvar este mês'));
        expect(find.text('Planejamento do mês salvo.'), findsOneWidget);

        final repo = PlanningRepository(h.db);
        final oct = (await h.run(() => repo.getMonthConfig('2026-10')))!;
        expect(
          (
            oct.salaryCents,
            oct.extraIncomeCents,
            oct.investmentCents,
            oct.savingsGoalCents,
          ),
          (920000, 100000, 300000, null),
        );
        expect(await h.run(() => repo.getMonthConfig('2026-11')), isNull);
        expect(
          (await h.run(() => repo.getPlanning())).defaultSalaryCents,
          800000,
        ); // padrão intacto

        // projeção: outubro usa 10.200 de renda e 3.000 de investimento; novembro continua com o padrão
        expect(balanceOf(t, '2026-10'), 'R\$ 7.200,00'); // 10.200 − 3.000
        expect(balanceOf(t, '2026-11'), 'R\$ 6.500,00'); // 8.500 − 2.000
        expect(find.text('Personalizado'), findsOneWidget);
      },
    );

    appTest(
      'valores em branco herdam o padrão (campo vazio = null)',
      size: wide,
      seed: (db) => seedPlan(db, recurring: false, withBills: false),
      (t, h) async {
        await goToPlanning(h);
        await t.tap(find.byKey(const Key('customize-switch')));
        await h.settle();
        await t.enterText(
          find.widgetWithText(TextFormField, 'Investimento planejado'),
          '0',
        ); // zero explícito
        await tapVisible(t, h, find.text('Salvar este mês'));
        final c = (await h.run(
          () => PlanningRepository(h.db).getMonthConfig('2026-10'),
        ))!;
        expect((c.salaryCents, c.investmentCents), (null, 0));
        expect(
          balanceOf(t, '2026-10'),
          'R\$ 8.500,00',
        ); // sem investimento neste mês
      },
    );

    appTest('salvar tudo em branco é recusado com explicação', size: wide, (
      t,
      h,
    ) async {
      await goToPlanning(h);
      await t.tap(find.byKey(const Key('customize-switch')));
      await h.settle();
      await tapVisible(t, h, find.text('Salvar este mês'));
      expect(find.textContaining('Preencha ao menos um valor'), findsOneWidget);
      expect(
        await h.run(() => PlanningRepository(h.db).getMonthConfig('2026-10')),
        isNull,
      );
    });

    appTest(
      'desligar o switch volta o mês aos padrões',
      size: wide,
      seed: (db) async {
        await seedPlan(db, recurring: false, withBills: false);
        await PlanningRepository(db)
            .setMonthConfig('2026-10', salaryCents: 920000);
      },
      (t, h) async {
        await goToPlanning(h);
        expect(
          t
              .widget<Switch>(
                find.descendant(
                  of: find.byKey(const Key('customize-switch')),
                  matching: find.byType(Switch),
                ),
              )
              .value,
          isTrue,
        );
        await t.tap(find.byKey(const Key('customize-switch')));
        await h.settle();
        expect(
          find.text('Este mês voltou a usar os valores padrão.'),
          findsOneWidget,
        );
        final c = (await h.run(
          () => PlanningRepository(h.db).getMonthConfig('2026-10'),
        ))!;
        expect(c.salaryCents, isNull);
        expect(balanceOf(t, '2026-10'), 'R\$ 6.500,00');
      },
    );

    appTest(
      'trocar de mês mostra o planejamento daquele mês',
      size: wide,
      seed: (db) async {
        await seedPlan(db, recurring: false, withBills: false);
        await PlanningRepository(db)
            .setMonthConfig('2026-11', salaryCents: 920000);
      },
      (t, h) async {
        await goToPlanning(h);
        expect(
          t
              .widget<Switch>(
                find.descendant(
                  of: find.byKey(const Key('customize-switch')),
                  matching: find.byType(Switch),
                ),
              )
              .value,
          isFalse,
        );
        await t.tap(find.byTooltip('Próximo mês'));
        await h.settle();
        expect(
          t
              .widget<Switch>(
                find.descendant(
                  of: find.byKey(const Key('customize-switch')),
                  matching: find.byType(Switch),
                ),
              )
              .value,
          isTrue,
        );
        expect(
          find.widgetWithText(TextFormField, 'Salário líquido'),
          findsOneWidget,
        );
      },
    );
  });

  group('projeções', () {
    appTest(
      '3 meses por padrão; 1, 6 e 12 trocam a quantidade de meses',
      size: wide,
      seed: (db) => seedPlan(db, recurring: false, withBills: false),
      (t, h) async {
        await goToPlanning(h);
        expect(find.byKey(const Key('projection-row-2026-10')), findsOneWidget);
        expect(find.byKey(const Key('projection-row-2026-12')), findsOneWidget);
        expect(find.byKey(const Key('projection-row-2027-01')), findsNothing);

        await t.tap(find.text('Mês atual'));
        await h.settle();
        expect(find.byKey(const Key('projection-row-2026-10')), findsOneWidget);
        expect(find.byKey(const Key('projection-row-2026-11')), findsNothing);

        await t.tap(find.text('6 meses'));
        await h.settle();
        expect(find.byKey(const Key('projection-row-2027-03')), findsOneWidget);
        expect(find.byKey(const Key('projection-row-2027-04')), findsNothing);

        await t.tap(find.text('12 meses'));
        await h.settle();
        expect(
          find.byKey(const Key('projection-row-2027-09')),
          findsOneWidget,
        ); // atravessa o ano
        expect(find.byKey(const Key('projection-row-2027-10')), findsNothing);
      },
    );

    appTest(
      'números: renda 8.500, recorrência de 39,90 e investimento de 2.000 por mês',
      size: wide,
      seed: seedPlan,
      (t, h) async {
        await goToPlanning(h);
        // outubro: 8.500 − (3.800 pagos + 1.440 + 39,90 pendentes) − 2.000
        expect(balanceOf(t, '2026-10'), 'R\$ 1.220,10');
        // novembro e dezembro: só a recorrência
        expect(balanceOf(t, '2026-11'), 'R\$ 6.460,10');
        expect(balanceOf(t, '2026-12'), 'R\$ 6.460,10');
        expect(totalBalance(t), 'R\$ 14.140,30');
      },
    );

    appTest(
      'real e projeção ficam separados: tabela, legenda e selos',
      size: wide,
      seed: seedPlan,
      (t, h) async {
        await goToPlanning(h);
        expect(find.text('DADO REAL'), findsOneWidget);
        expect(find.text('PROJEÇÃO'), findsOneWidget);
        expect(find.text('Dado real'), findsOneWidget);
        expect(find.text('Projeção'), findsWidgets);
        // outubro tem gasto pago (real); novembro e dezembro são só projeção
        final oct = find.byKey(const Key('projection-row-2026-10'));
        final nov = find.byKey(const Key('projection-row-2026-11'));
        expect(
          find.descendant(of: oct, matching: find.text('Real + projeção')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: nov, matching: find.text('Projeção')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: nov, matching: find.text('Real + projeção')),
          findsNothing,
        );
        // tabela do resumo: gastos reais (pagos) e projetados (pendentes) em colunas distintas
        final summary = find.byKey(const Key('projection-summary'));
        expect(
          find.descendant(of: summary, matching: find.text('R\$ 3.800,00')),
          findsOneWidget,
        ); // real
        // projeção de gastos em 3 meses: outubro 1.440 + 39,90 e Netflix em novembro e dezembro (39,90 + 39,90)
        expect(
          find.descendant(of: summary, matching: find.text('R\$ 1.559,70')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: summary, matching: find.text('R\$ 25.500,00')),
          findsOneWidget,
        ); // renda esperada: 8.500 × 3
        expect(
          find.descendant(of: summary, matching: find.text('R\$ 6.000,00')),
          findsOneWidget,
        ); // investimentos: 2.000 × 3
      },
    );

    appTest(
      'mês com saldo negativo aparece com sinal',
      size: wide,
      seed: (db) async {
        await seedPlan(db, recurring: false, withBills: false);
        await TransactionRepository(db).create(
          name: 'Reforma',
          plannedAmountCents: 1000000,
          dueDate: DateTime(2026, 11, 20),
          categoryId: 'cat-outros',
        );
      },
      (t, h) async {
        await goToPlanning(h);
        expect(
          balanceOf(t, '2026-11'),
          startsWith('-'),
        ); // 8.500 − 10.000 − 2.000 = −3.500
        expect(balanceOf(t, '2026-11'), contains('3.500,00'));
      },
    );

    appTest(
      'detalhe do mês: meta de economia acima/abaixo e atalho para editar o mês',
      size: wide,
      seed: seedPlan,
      (t, h) async {
        await goToPlanning(h);
        await t.tap(find.byKey(const Key('projection-row-2026-10')));
        await h.settle();
        expect(find.text('Outubro 2026'), findsWidgets);
        expect(
          t.widget<Text>(find.byKey(const Key('savings-gap-text'))).data,
          'Meta R\$ 1.000,00 · saldo projetado R\$ 1.220,10 · R\$ 220,10 acima da meta',
        );
        await t.tap(find.byTooltip('Fechar'));
        await h.settle();

        await t.tap(find.byKey(const Key('projection-row-2026-11')));
        await h.settle();
        expect(
          t.widget<Text>(find.byKey(const Key('savings-gap-text'))).data,
          'Meta R\$ 1.000,00 · saldo projetado R\$ 6.460,10 · R\$ 5.460,10 acima da meta',
        );
        await t.tap(find.byKey(const Key('edit-month-plan')));
        await h.settle();
        // o seletor do planejamento agora está em novembro
        expect(find.text('Novembro 2026'), findsWidgets);
        expect(find.byKey(const Key('customize-switch')), findsOneWidget);
      },
    );

    appTest(
      'saldo abaixo da meta de economia é informado sem recomendação',
      size: wide,
      seed: (db) async {
        await seedPlan(db, recurring: false, withBills: false);
        // novembro: 8.500 − 6.000 − 2.000 = 500, abaixo da meta de 1.000
        await TransactionRepository(db).create(
          name: 'Reforma',
          plannedAmountCents: 600000,
          dueDate: DateTime(2026, 11, 20),
          categoryId: 'cat-outros',
        );
      },
      (t, h) async {
        await goToPlanning(h);
        await t.tap(find.byKey(const Key('projection-row-2026-11')));
        await h.settle();
        expect(
          t.widget<Text>(find.byKey(const Key('savings-gap-text'))).data,
          'Meta R\$ 1.000,00 · saldo projetado R\$ 500,00 · R\$ 500,00 abaixo da meta',
        );
      },
    );

    appTest(
      'sem meta de economia o detalhe não mostra essa seção',
      size: wide,
      seed: (db) async {
        await PlanningRepository(db).updatePlanning(salaryCents: 800000);
      },
      (t, h) async {
        await goToPlanning(h);
        await t.tap(find.byKey(const Key('projection-row-2026-10')));
        await h.settle();
        expect(find.byKey(const Key('savings-gap-text')), findsNothing);
        expect(find.text('META DE ECONOMIA'), findsNothing);
      },
    );
  });

  appTest(
    'celular: padrões, mês e projeções empilhados, sem estourar layout',
    seed: seedPlan,
    (t, h) async {
      await goToPlanning(h);
      expect(find.text('Valores padrão'.toUpperCase()), findsOneWidget);
      await scrollTo(t, find.text('Projeções'));
      await scrollTo(t, find.byKey(const Key('projection-row-2026-12')));
      expect(find.byKey(const Key('projection-row-2026-12')), findsOneWidget);
    },
  );
}
