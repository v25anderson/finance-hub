import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'pressable.dart';

class NavItemData {
  const NavItemData(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

bool _reduce(BuildContext c) => MediaQuery.maybeDisableAnimationsOf(c) ?? false;

/// Barra inferior própria (celular): ícone e rótulo, item ativo na cor de destaque com um marcador no topo.
class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.items, required this.selectedIndex, required this.onSelected});
  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = _reduce(context);
    return Container(
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.8)))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(children: [
            for (final (i, item) in items.indexed)
              Expanded(
                child: Pressable(
                  onTap: () => onSelected(i),
                  scale: 0.92,
                  semanticLabel: item.label,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AnimatedContainer(
                      duration: reduce ? Duration.zero : Motion.normal,
                      curve: Motion.curve,
                      width: i == selectedIndex ? 22 : 0,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 7),
                      decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(Radii.pill)),
                    ),
                    Icon(i == selectedIndex ? item.selectedIcon : item.icon, size: 24, color: i == selectedIndex ? c.accent : c.textSecondary),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(i == selectedIndex ? c.accent : c.textSecondary).copyWith(fontSize: 11, height: 1.1, fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Botão "+" circular (celular).
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: 'Adicionar',
      child: Pressable(
        onTap: onPressed,
        scale: 0.92,
        semanticLabel: 'Adicionar',
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroStart, c.heroEnd]),
            boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

/// Barra lateral própria (tablet e desktop). [extended] mostra rótulos ao lado dos ícones.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
    required this.onToggleTheme,
    required this.extended,
  });
  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  final VoidCallback onToggleTheme;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: extended ? 252 : 92,
      decoration: BoxDecoration(color: c.surface, border: Border(right: BorderSide(color: c.border.withValues(alpha: 0.8)))),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: extended ? Space.md : Space.sm, vertical: Space.lg),
          child: Column(crossAxisAlignment: extended ? CrossAxisAlignment.stretch : CrossAxisAlignment.center, children: [
            _Brand(extended: extended),
            const SizedBox(height: Space.lg),
            _AddAction(extended: extended, onTap: onAdd),
            const SizedBox(height: Space.lg),
            for (final (i, item) in items.indexed) _SidebarItem(item: item, selected: i == selectedIndex, extended: extended, onTap: () => onSelected(i)),
            const Spacer(),
            Tooltip(
              message: 'Alternar tema',
              child: Pressable(
                onTap: onToggleTheme,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                    Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: c.textSecondary, size: 22),
                    if (extended) ...[
                      const SizedBox(width: 12),
                      Expanded(child: Text('Alternar tema', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontWeight: FontWeight.w600, fontSize: 14))),
                    ],
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});
  final bool extended;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroStart, c.heroEnd])),
      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
    );
    if (!extended) return logo;
    return Row(children: [
      logo,
      const SizedBox(width: 12),
      Expanded(child: Text('Finance Hub', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.headline(c.textPrimary))),
    ]);
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction({required this.extended, required this.onTap});
  final bool extended;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    if (!extended) return AddButton(onPressed: onTap);
    return Tooltip(
      message: 'Adicionar',
      child: FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.add_rounded), label: const Text('Nova conta')),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, required this.selected, required this.extended, required this.onTap});
  final NavItemData item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.accent : c.textSecondary;
    final reduce = _reduce(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Pressable(
        onTap: onTap,
        scale: 0.98,
        semanticLabel: item.label,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : Motion.normal,
          curve: Motion.curve,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: extended ? 12 : 10),
          decoration: BoxDecoration(color: selected ? c.accentSoft : Colors.transparent, borderRadius: BorderRadius.circular(Radii.md)),
          child: extended
              ? Row(children: [
                  Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(color).copyWith(fontSize: 14.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w600))),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(selected ? item.selectedIcon : item.icon, color: color, size: 22),
                  const SizedBox(height: 3),
                  Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(color).copyWith(fontSize: 10.5, height: 1.1, fontWeight: FontWeight.w600)),
                ]),
        ),
      ),
    );
  }
}
