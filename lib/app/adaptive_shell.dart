import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens/colors.dart';
import '../design_system/tokens/spacing.dart';
import '../design_system/tokens/typography.dart';
import '../features/analytics/presentation/analytics_page.dart';
import '../features/bills/presentation/bills_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/planning/presentation/planning_page.dart';
import 'theme_mode_provider.dart';

class AppDestination {
  const AppDestination(this.label, this.icon, this.selectedIcon, this.page);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const _destinations = <AppDestination>[
  AppDestination('Visão geral', Icons.grid_view_outlined, Icons.grid_view_rounded, DashboardPage()),
  AppDestination('Contas', Icons.receipt_long_outlined, Icons.receipt_long, BillsPage()),
  AppDestination('Calendário', Icons.calendar_month_outlined, Icons.calendar_month, CalendarPage()),
  AppDestination('Planejamento', Icons.flag_outlined, Icons.flag, PlanningPage()),
  AppDestination('Análises', Icons.insights_outlined, Icons.insights, AnalyticsPage()),
];

enum ShellLayout { compact, medium, expanded }

ShellLayout layoutForWidth(double width) {
  if (width < Breakpoints.compact) return ShellLayout.compact;
  if (width < Breakpoints.expanded) return ShellLayout.medium;
  return ShellLayout.expanded;
}

/// Navegação adaptativa: bottom nav (celular), rail (tablet), sidebar (desktop/web).
class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({super.key});

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  void _toggleTheme() {
    final mode = ref.read(themeModeProvider);
    final dark = mode == ThemeMode.dark || (mode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    ref.read(themeModeProvider.notifier).set(dark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    final layout = layoutForWidth(MediaQuery.sizeOf(context).width);
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: KeyedSubtree(key: ValueKey(_index), child: _destinations[_index].page),
    );
    final fab = FloatingActionButton.extended(
      onPressed: () {}, // Fase 3: cadastro de conta
      icon: const Icon(Icons.add),
      label: const Text('Adicionar'),
    );

    if (layout == ShellLayout.compact) {
      return Scaffold(
        body: SafeArea(child: body),
        floatingActionButton: fab,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
          ],
        ),
      );
    }

    final c = context.colors;
    final expanded = layout == ShellLayout.expanded;
    return Scaffold(
      floatingActionButton: fab,
      body: SafeArea(
        child: Row(children: [
          NavigationRail(
            extended: expanded,
            minExtendedWidth: 232,
            backgroundColor: c.surface,
            selectedIndex: _index,
            onDestinationSelected: _select,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.lg),
              child: expanded
                  ? Text('Finance Hub', style: AppText.title(c.textPrimary))
                  : Icon(Icons.account_balance_wallet_outlined, color: c.accent),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(Space.md),
                  child: IconButton(
                    tooltip: 'Alternar tema',
                    onPressed: _toggleTheme,
                    icon: const Icon(Icons.brightness_6_outlined),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: Text(d.label)),
            ],
          ),
          VerticalDivider(width: 1, color: c.border),
          Expanded(
            child: Center(
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280), child: body),
            ),
          ),
        ]),
      ),
    );
  }
}
