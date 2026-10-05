import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onde a escolha de tema fica guardada. Só o tema: nenhum dado financeiro passa por aqui.
abstract interface class ThemeStore {
  ThemeMode? load();
  Future<void> save(ThemeMode mode);
}

/// Em memória (testes e quando o armazenamento não está disponível): a escolha vale só nesta sessão.
class MemoryThemeStore implements ThemeStore {
  ThemeMode? _mode;
  @override
  ThemeMode? load() => _mode;
  @override
  Future<void> save(ThemeMode mode) async => _mode = mode;
}

/// Guarda no armazenamento do app (SharedPreferences no Android, localStorage na web).
class PreferencesThemeStore implements ThemeStore {
  PreferencesThemeStore._(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  static Future<ThemeStore> open() async {
    try {
      return PreferencesThemeStore._(await SharedPreferences.getInstance());
    } catch (_) {
      return MemoryThemeStore(); // sem armazenamento: o app continua, só não lembra o tema
    }
  }

  @override
  ThemeMode? load() => switch (_prefs.getString(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      };

  @override
  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}

final themeStoreProvider = Provider<ThemeStore>((ref) => MemoryThemeStore());

/// Modo de tema escolhido pelo usuário: Automático (segue o aparelho, o padrão), Claro ou Escuro. A escolha é lembrada.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(themeStoreProvider).load() ?? ThemeMode.system;

  void set(ThemeMode mode) {
    state = mode;
    ref.read(themeStoreProvider).save(mode).catchError((Object _) {}); // lembrar é um extra: falhar não atrapalha
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
