import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/components/app_navigation.dart';
import '../design_system/tokens/spacing.dart';
import '../features/analytics/presentation/analytics_page.dart';
import '../features/bills/presentation/bill_form_sheet.dart';
import '../features/bills/presentation/bills_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/planning/presentation/planning_page.dart';
import 'shell_index_provider.dart';
import 'theme_mode_provider.dart';

class AppDestination {
  const AppDestination(this.nav, this.page);
  final NavItemData nav;
  final Widget page;
}

const _destinations = <AppDestination>[
  AppDestination(NavItemData('Visão geral', Icons.grid_view_outlined, Icons.grid_view_rounded, shortLabel: 'Início'), DashboardPage()),
  AppDestination(NavItemData('Contas', Icons.receipt_long_outlined, Icons.receipt_long_rounded), BillsPage()),
  AppDestination(NavItemData('Calendário', Icons.calendar_month_outlined, Icons.calendar_month_rounded, shortLabel: 'Agenda'), CalendarPage()),
  AppDestination(NavItemData('Planejamento', Icons.flag_outlined, Icons.flag_rounded, shortLabel: 'Plano'), PlanningPage()),
  AppDestination(NavItemData('Análises', Icons.insights_outlined, Icons.insights_rounded), AnalyticsPage()),
];

enum ShellLayout { compact, medium, expanded }

ShellLayout layoutForWidth(double width) {
  if (width < Breakpoints.compact) return ShellLayout.compact;
  if (width < Breakpoints.expanded) return ShellLayout.medium;
  return ShellLayout.expanded;
}

/// Navegação adaptativa: barra inferior (celular), barra lateral compacta (tablet) e completa (desktop/web).
class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({super.key});

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  void _select(int i) => ref.read(shellIndexProvider.notifier).select(i);

  void _toggleTheme() => ref.read(themeModeProvider.notifier).toggle(context);

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(shellIndexProvider);
    final layout = layoutForWidth(MediaQuery.sizeOf(context).width);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final body = AnimatedSwitcher(
      duration: reduce ? Duration.zero : Motion.normal,
      switchInCurve: Motion.curve,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(anim), child: child),
      ),
      child: KeyedSubtree(key: ValueKey(index), child: _destinations[index].page),
    );
    final items = [for (final d in _destinations) d.nav];

    if (layout == ShellLayout.compact) {
      return Scaffold(
        extendBody: true, // o conteúdo rola por baixo do dock de vidro
        body: body, // cada página trata o recuo superior (barra de status) por conta própria
        bottomNavigationBar: AppDock(items: items, selectedIndex: index, onSelected: _select, onAdd: () => showBillForm(context)),
      );
    }

    return Scaffold(
      body: Row(children: [
        AppSidebar(
          items: items,
          selectedIndex: index,
          onSelected: _select,
          onAdd: () => showBillForm(context),
          onToggleTheme: _toggleTheme,
          extended: layout == ShellLayout.expanded,
        ),
        Expanded(
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280), child: body)),
        ),
      ]),
    );
  }
}
