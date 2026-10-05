import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final themeStore = await PreferencesThemeStore.open();
  runApp(ProviderScope(overrides: [themeStoreProvider.overrideWithValue(themeStore)], child: const FinanceHubApp()));
}
