import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de tema escolhido pelo usuário. O padrão é escuro (a identidade "cinema" do app); persistência virá depois.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;
  void set(ThemeMode mode) => state = mode;

  /// Alterna entre claro e escuro conforme o que está sendo exibido agora.
  void toggle(BuildContext context) {
    final dark = state == ThemeMode.dark || (state == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    state = dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
