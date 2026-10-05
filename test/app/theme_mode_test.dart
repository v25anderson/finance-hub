import 'package:finance_hub/app/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('padrão é Automático (segue o aparelho) e a escolha é guardada e lembrada na próxima abertura', () async {
    SharedPreferences.setMockInitialValues({});
    final store1 = await PreferencesThemeStore.open();
    final c1 = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(store1)]);
    addTearDown(c1.dispose);
    expect(c1.read(themeModeProvider), ThemeMode.system);
    c1.read(themeModeProvider.notifier).set(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);

    // "reabre o app": novo contêiner, mesmo armazenamento
    final store2 = await PreferencesThemeStore.open();
    final c2 = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(store2)]);
    addTearDown(c2.dispose);
    expect(c2.read(themeModeProvider), ThemeMode.light);
  });

  test('valor guardado inválido ou ausente cai no padrão Automático', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'azul'});
    final store = await PreferencesThemeStore.open();
    expect(store.load(), isNull);
    final c = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.system);
  });

  test('falha ao gravar não derruba o app e o tema muda mesmo assim', () async {
    final c = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(_Failing())]);
    addTearDown(c.dispose);
    c.read(themeModeProvider.notifier).set(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(themeModeProvider), ThemeMode.light);
  });

  test('as três opções (Automático, Claro, Escuro) são lembradas', () async {
    for (final mode in ThemeMode.values) {
      SharedPreferences.setMockInitialValues({});
      final store1 = await PreferencesThemeStore.open();
      final c1 = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(store1)]);
      c1.read(themeModeProvider.notifier).set(mode);
      await Future<void>.delayed(Duration.zero);
      c1.dispose();
      final c2 = ProviderContainer(overrides: [themeStoreProvider.overrideWithValue(await PreferencesThemeStore.open())]);
      addTearDown(c2.dispose);
      expect(c2.read(themeModeProvider), mode);
    }
  });
}

class _Failing implements ThemeStore {
  @override
  ThemeMode? load() => null;
  @override
  Future<void> save(ThemeMode mode) => Future.error(StateError('sem armazenamento'));
}
