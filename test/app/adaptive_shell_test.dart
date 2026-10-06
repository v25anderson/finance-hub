import 'package:finance_hub/app/adaptive_shell.dart';
import 'package:finance_hub/design_system/components/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/test_harness.dart';

void main() {
  setUpAll(initHarness);

  test('layoutForWidth respeita os breakpoints', () {
    expect(layoutForWidth(390), ShellLayout.compact);
    expect(layoutForWidth(599), ShellLayout.compact);
    expect(layoutForWidth(600), ShellLayout.medium);
    expect(layoutForWidth(1099), ShellLayout.medium);
    expect(layoutForWidth(1100), ShellLayout.expanded);
  });

  appTest('celular usa o dock flutuante com 5 destinos', (t, h) async {
    expect(find.byType(AppDock), findsOneWidget);
    expect(find.byType(AppSidebar), findsNothing);
    expect(find.byKey(const Key('nav-Calendário')), findsOneWidget);
  });

  appTest('desktop usa sidebar e navega entre telas', size: const Size(1400, 900), (t, h) async {
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byType(AppDock), findsNothing);
    await t.tap(find.byKey(const Key('nav-Análises')));
    await h.settle();
    expect(find.text('Descreve seus dados; não é recomendação.'), findsOneWidget);
  });
}
