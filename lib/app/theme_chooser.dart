import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/components/adaptive_sheet.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/tokens/spacing.dart';
import '../design_system/tokens/typography.dart';
import 'theme_mode_provider.dart';

/// Ícone que representa o modo de tema atual.
IconData themeModeIcon(ThemeMode m) => switch (m) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };

String themeModeLabel(ThemeMode m) => switch (m) {
      ThemeMode.system => 'Automático',
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
    };

Future<void> showThemeChooser(BuildContext context) => showAdaptiveSheet<void>(context, builder: (_) => const ThemeChooser());

/// Escolha da aparência: Automático (segue o tema do aparelho), Claro ou Escuro. A escolha é lembrada.
class ThemeChooser extends ConsumerWidget {
  const ThemeChooser({super.key});

  static const _descriptions = {
    ThemeMode.system: 'Acompanha o tema do aparelho e muda sozinho.',
    ThemeMode.light: 'Fundo claro o tempo todo.',
    ThemeMode.dark: 'Fundo escuro o tempo todo.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final current = ref.watch(themeModeProvider);
    return Material(
      color: Colors.transparent,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.lg),
        children: [
          Text('Aparência', style: AppText.title(c.textPrimary)),
          const SizedBox(height: Space.md),
          for (final m in [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
            ListTile(
              key: Key('theme-option-${m.name}'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(themeModeIcon(m), color: m == current ? c.accent : c.textSecondary),
              title: Text(themeModeLabel(m)),
              subtitle: Text(_descriptions[m]!),
              trailing: m == current ? Icon(Icons.check_circle_rounded, color: c.accent) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).set(m);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
