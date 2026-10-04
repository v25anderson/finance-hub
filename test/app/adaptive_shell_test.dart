import 'package:finance_hub/app/adaptive_shell.dart';
import 'package:finance_hub/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _pump(WidgetTester t, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const ProviderScope(child: FinanceHubApp()));
  await t.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('layoutForWidth respeita os breakpoints', () {
    expect(layoutForWidth(390), ShellLayout.compact);
    expect(layoutForWidth(599), ShellLayout.compact);
    expect(layoutForWidth(600), ShellLayout.medium);
    expect(layoutForWidth(1099), ShellLayout.medium);
    expect(layoutForWidth(1100), ShellLayout.expanded);
  });

  testWidgets('celular usa bottom navigation com 5 destinos', (t) async {
    await _pump(t, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Calendário'), findsOneWidget);
  });

  testWidgets('desktop usa sidebar e navega entre telas', (t) async {
    await _pump(t, const Size(1400, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await t.tap(find.text('Análises'));
    await t.pumpAndSettle();
    expect(find.text('Disponível na Fase 8.'), findsOneWidget);
  });
}
