import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

const wide = Size(1400, 1000);

/// Cada escrita em seu próprio `h.run`: duas escritas dentro de um único `runAsync`, com streams do
/// Drift ativas na zona de relógio falso, travam o teste (ver Harness.run).
Future<String> bill(Harness h, String name, int cents, DateTime due, {int paid = 0, String cat = 'cat-moradia'}) async {
  final repo = TransactionRepository(h.db);
  final id = await h.run(() => repo.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: cat, expenseType: ExpenseType.fixed));
  if (paid > 0) {
    await h.run(() => repo.addPayment(transactionId: id, amountCents: paid, paidAt: DateTime.utc(2026, 10, 2)));
  }
  return id;
}

Future<void> setDefaults(Harness h, {int salary = 800000, int extra = 50000, int invest = 200000}) =>
    h.run(() => PlanningRepository(h.db).updatePlanning(salaryCents: salary, extraIncomeCents: extra, investmentCents: invest));

/// Texto de um widget com chave: a própria `Text` ou a `Text` dentro de um `MoneyText`.
String textOf(WidgetTester t, String key) {
  final keyed = find.byKey(Key(key));
  final text = t.any(find.descendant(of: keyed, matching: find.byType(Text))) ? find.descendant(of: keyed, matching: find.byType(Text)) : keyed;
  return t.widget<Text>(text).data!;
}

void main() {
  setUpAll(initHarness);

  appTest('KPI do enunciado: 5.240 gastos, 3.800 pago, 1.440 pendente, 72,5% quitado', size: wide, (t, h) async {
    await bill(h, 'Aluguel', 380000, DateTime(2026, 10, 5), paid: 380000);
    await bill(h, 'Cartão', 144000, DateTime(2026, 10, 25));
    await h.settle();
    expect(find.text('GASTOS DO MÊS'), findsOneWidget);
    expect(find.text('R\$ 5.240,00'), findsOneWidget);
    expect(find.text('R\$ 3.800,00'), findsWidgets);
    expect(find.text('R\$ 1.440,00'), findsWidgets);
    expect(find.text('72,5% quitado'), findsOneWidget);
    expect(find.text('27,5% restante'), findsOneWidget);
  });

  appTest('comparação: +8,3% vs setembro, com variação por categoria', size: wide, (t, h) async {
    await bill(h, 'Aluguel', 400000, DateTime(2026, 10, 5), cat: 'cat-moradia');
    await bill(h, 'Mercado', 124000, DateTime(2026, 10, 6), cat: 'cat-alimentacao');
    await bill(h, 'Aluguel set', 380000, DateTime(2026, 9, 5), cat: 'cat-moradia');
    await bill(h, 'Mercado set', 103800, DateTime(2026, 9, 6), cat: 'cat-alimentacao');
    await h.settle();
    expect(find.text('+8,3%'), findsOneWidget);
    expect(find.text('vs setembro'), findsOneWidget);
    expect(find.textContaining('+R\$ 402,00'), findsWidgets);
    expect(find.text('MAIORES VARIAÇÕES POR CATEGORIA'), findsOneWidget);
    expect(find.text('+R\$ 200,00'), findsOneWidget); // moradia
    expect(find.text('+R\$ 202,00'), findsOneWidget); // alimentação
  });

  appTest('comparação sem gastos no mês anterior não inventa percentual', size: wide, (t, h) async {
    await bill(h, 'Aluguel', 100000, DateTime(2026, 10, 5));
    await h.settle();
    expect(find.textContaining('Sem gastos em setembro'), findsOneWidget);
    expect(find.text('+R\$ 1.000,00'), findsWidgets); // variação total e da categoria
  });

  appTest('quanto sobra: três saldos distintos e projetado', size: wide, (t, h) async {
    await setDefaults(h);
    await bill(h, 'Aluguel', 380000, DateTime(2026, 10, 5), paid: 380000);
    await bill(h, 'Cartão', 144000, DateTime(2026, 10, 25));
    await h.settle();
    expect(textOf(t, 'balance-projected'), 'R\$ 1.260,00'); // 8.500 − 3.800 − 1.440 − 2.000
    expect(find.text('Saldo atual'), findsOneWidget);
    expect(find.text('Se todas as pendentes forem pagas'), findsOneWidget);
    expect(find.text('Saldo após investimentos planejados'), findsOneWidget);
    expect(find.text('R\$ 4.700,00'), findsOneWidget); // atual: 8.500 − 3.800
    expect(find.text('R\$ 3.260,00'), findsOneWidget); // após contas
  });

  appTest('saldo negativo aparece com sinal e em destaque de perigo', size: wide, (t, h) async {
    await bill(h, 'Cartão', 50000, DateTime(2026, 10, 25));
    await h.settle();
    expect(textOf(t, 'balance-projected'), contains('500,00'));
    final w = t.widget<Text>(find.byKey(const Key('balance-projected')));
    expect(w.style!.color, isNot(equals(Colors.black)));
    expect(find.text('R\$ 0,00'), findsWidgets); // renda zero é válida
  });

  appTest('renda: padrão 8.000 + 500 = 8.500 e adicionar renda extra', size: wide, (t, h) async {
    await setDefaults(h);
    await h.settle();
    expect(textOf(t, 'income-total'), 'R\$ 8.500,00');
    await tapVisible(t, h, find.text('Adicionar renda'));
    await t.enterText(find.widgetWithText(TextFormField, 'Valor'), '150');
    await t.tap(find.text('Adicionar').last);
    await h.settle();
    expect(textOf(t, 'income-total'), 'R\$ 8.650,00');
  });

  appTest('definir valores padrão pelo diálogo', size: wide, (t, h) async {
    await tapVisible(t, h, find.text('Valores padrão'));
    await t.enterText(find.widgetWithText(TextFormField, 'Salário líquido padrão'), '8000');
    await t.enterText(find.widgetWithText(TextFormField, 'Renda extra padrão'), '500');
    await t.enterText(find.widgetWithText(TextFormField, 'Investimento planejado padrão'), '2000');
    await t.tap(find.text('Salvar'));
    await h.settle();
    expect(textOf(t, 'income-total'), 'R\$ 8.500,00');
    expect(find.text('0%'), findsNothing);
  });

  appTest('mês personalizado usa os valores do mês e mostra o selo', size: wide, (t, h) async {
    await setDefaults(h);
    await h.run(() => PlanningRepository(h.db).setMonthConfig('2026-10', salaryCents: 920000, investmentCents: 300000));
    await h.settle();
    expect(textOf(t, 'income-total'), 'R\$ 9.700,00'); // 9.200 + 500 herdado
    expect(find.text('Mês personalizado'), findsOneWidget);
    await t.tap(find.byTooltip('Próximo mês'));
    await h.settle();
    expect(textOf(t, 'income-total'), 'R\$ 8.500,00'); // novembro volta ao padrão
    expect(find.text('Mês personalizado'), findsNothing);
  });

  appTest('investimentos: meta 2.000, registra 1.500 → 75% e diferença de 500', size: wide, (t, h) async {
    await setDefaults(h);
    await h.settle();
    expect(textOf(t, 'investment-percent'), '0% da meta');
    await tapVisible(t, h, find.text('Registrar investimento'));
    expect(find.widgetWithText(TextFormField, 'Valor'), findsOneWidget);
    await t.enterText(find.widgetWithText(TextFormField, 'Valor'), '1500');
    await t.tap(find.text('Registrar').last);
    await h.settle();
    expect(textOf(t, 'investment-percent'), '75% da meta');
    expect(find.text('Diferença: faltam R\$ 500,00'), findsOneWidget);
  });

  appTest('marcar meta como realizada completa o restante e remove o botão', size: wide, (t, h) async {
    await setDefaults(h);
    await h.settle();
    await tapVisible(t, h, find.text('Marcar meta como realizada'));
    expect(textOf(t, 'investment-percent'), '100% da meta');
    expect(find.text('Meta atingida'), findsOneWidget);
    expect(find.text('Marcar meta como realizada'), findsNothing);
  });

  appTest('alertas: vencida, amanhã, esta semana e próximos 30 dias', size: wide, (t, h) async {
    await bill(h, 'Velha', 1000, DateTime(2026, 10, 3));
    await bill(h, 'Amanhã', 1000, DateTime(2026, 10, 11));
    await bill(h, 'Semana 1', 1000, DateTime(2026, 10, 14));
    await bill(h, 'Semana 2', 1000, DateTime(2026, 10, 16));
    await bill(h, 'Mês', 1000, DateTime(2026, 10, 30));
    await h.settle();
    expect(find.text('1 conta está vencida'), findsOneWidget);
    expect(find.text('Vence amanhã'), findsOneWidget);
    expect(find.text('2 contas vencem esta semana'), findsOneWidget);
    expect(find.text('1 conta vence nos próximos 30 dias'), findsOneWidget);
  });

  appTest('sem pendências mostra mensagem tranquila', size: wide, (t, h) async {
    await h.settle();
    expect(find.textContaining('Nenhuma conta vencida ou vencendo'), findsOneWidget);
  });

  appTest('alerta leva à tela de Contas', size: wide, (t, h) async {
    await bill(h, 'Velha', 1000, DateTime(2026, 10, 3));
    await h.settle();
    await t.tap(find.text('1 conta está vencida'));
    await h.settle();
    expect(find.text('Contas'), findsWidgets);
    expect(tabCount(t, 'overdue'), '1'); // estamos na tela de Contas
  });

  appTest('KPI clicável abre o detalhe com estados e distribuição por categoria', size: wide, (t, h) async {
    await bill(h, 'Aluguel', 600000, DateTime(2026, 10, 3), paid: 600000, cat: 'cat-moradia');
    await bill(h, 'Velha', 100000, DateTime(2026, 10, 4), cat: 'cat-lazer');
    await bill(h, 'Parcial', 200000, DateTime(2026, 10, 25), paid: 50000, cat: 'cat-moradia');
    await h.settle();
    await t.tap(find.text('GASTOS DO MÊS'));
    await h.settle();
    expect(find.text('Gastos de Outubro 2026'), findsOneWidget);
    expect(find.text('Pagas (1)'), findsOneWidget);
    expect(find.text('Pendentes (1)'), findsOneWidget);
    expect(find.text('Vencidas (1)'), findsOneWidget);
    expect(find.text('Parcialmente pagas (1)'), findsOneWidget);
    expect(find.text('Futuras (0)'), findsOneWidget);
    expect(find.text('Parcial'), findsNWidgets(2)); // grupo inicial = Pendentes (+ o pôster em "Próximas contas")
    await t.tap(find.byKey(const Key('group-paid')));
    await h.settle();
    expect(find.text('Aluguel'), findsOneWidget);
    await scrollTo(t, find.text('DISTRIBUIÇÃO POR CATEGORIA'));
    expect(find.text('R\$ 8.000,00 · 88,9%'), findsOneWidget); // moradia: 6.000 + 2.000 de 9.000
    expect(find.text('R\$ 1.000,00 · 11,1%'), findsOneWidget);
  });

  appTest('mês futuro sem contas: KPI vazio e comparação com o mês anterior', size: wide, (t, h) async {
    await bill(h, 'Cartão', 100000, DateTime(2026, 10, 25));
    await h.settle();
    await t.tap(find.byTooltip('Próximo mês'));
    await h.settle();
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.text('Nenhuma conta neste mês.'), findsOneWidget);
    expect(find.text('−100%'), findsOneWidget);
    expect(find.text('vs outubro'), findsOneWidget);
  });

  appTest('mês sem nenhum dado: sem erros nem divisões por zero', size: wide, (t, h) async {
    await h.settle();
    expect(find.text('R\$ 0,00'), findsWidgets);
    expect(find.textContaining('Nenhum gasto neste mês nem em setembro'), findsOneWidget);
    expect(find.textContaining('Sem meta de investimento'), findsOneWidget);
  });

  appTest('celular: destaque no topo, alertas logo abaixo e tudo cabe sem estourar layout', (t, h) async {
    await bill(h, 'Velha', 1000, DateTime(2026, 10, 3));
    await h.settle();
    final kpiY = t.getTopLeft(find.text('GASTOS DO MÊS')).dy;
    final alertY = t.getTopLeft(find.text('1 conta está vencida')).dy;
    final balanceY = t.getTopLeft(find.text('QUANTO SOBRA')).dy;
    expect(kpiY, lessThan(alertY));
    expect(alertY, lessThan(balanceY));
    await scrollTo(t, find.text('INVESTIMENTOS'));
    expect(find.text('INVESTIMENTOS'), findsOneWidget);
  });

  appTest('desktop: destaque em largura total e duas colunas abaixo', size: wide, (t, h) async {
    await h.settle();
    final kpi = t.getTopLeft(find.text('GASTOS DO MÊS'));
    final comparison = t.getTopLeft(find.text('COMPARAÇÃO COM O MÊS ANTERIOR'));
    final balance = t.getTopLeft(find.text('QUANTO SOBRA'));
    expect(comparison.dy, greaterThan(kpi.dy)); // destaque primeiro
    expect(balance.dx, greaterThan(comparison.dx + 300)); // duas colunas
    expect((balance.dy - comparison.dy).abs(), lessThan(60)); // começam na mesma altura
  });
}
