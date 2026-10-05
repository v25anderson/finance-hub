import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'pressable.dart';

class NavItemData {
  const NavItemData(this.label, this.icon, this.selectedIcon, {String? shortLabel}) : shortLabel = shortLabel ?? label;
  final String label;

  /// Rótulo curto da cápsula ativa do dock.
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
}

bool _reduce(BuildContext c) => MediaQuery.maybeDisableAnimationsOf(c) ?? false;

/// Dock flutuante de vidro (celular): só o item ativo mostra o rótulo, dentro de uma cápsula luminosa.
/// O conteúdo rola por baixo do vidro.
class AppDock extends StatelessWidget {
  const AppDock({super.key, required this.items, required this.selectedIndex, required this.onSelected, required this.onAdd});
  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final light = Theme.of(context).brightness == Brightness.light;
    final reduce = _reduce(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.md, 0, Space.md, bottom > 0 ? bottom : Space.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.pill),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: light ? 0.14 : 0.55), blurRadius: 32, offset: const Offset(0, 14))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: c.surface.withValues(alpha: light ? 0.80 : 0.72),
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(color: Colors.white.withValues(alpha: light ? 0.8 : 0.10)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (final (i, item) in items.indexed) _DockItem(item: item, selected: i == selectedIndex, reduce: reduce, onTap: () => onSelected(i)),
                  const SizedBox(width: 6),
                  AddButton(onPressed: onAdd, size: 50),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({required this.item, required this.selected, required this.reduce, required this.onTap});
  final NavItemData item;
  final bool selected;
  final bool reduce;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      key: Key('nav-${item.label}'),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      scale: 0.9,
      semanticLabel: item.label,
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : Motion.normal,
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.pill),
          gradient: selected ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroGlow, c.heroStart]) : null,
          boxShadow: selected ? [BoxShadow(color: c.heroStart.withValues(alpha: 0.55), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(selected ? item.selectedIcon : item.icon, size: 24, color: selected ? Colors.white : c.textSecondary),
          // largura do rótulo anima de 0 a 1 (sem AnimatedSize, que não convive com o FittedBox do dock)
          ClipRect(
            child: AnimatedAlign(
              duration: reduce ? Duration.zero : Motion.normal,
              curve: Motion.curve,
              alignment: Alignment.centerLeft,
              widthFactor: selected ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(item.shortLabel, maxLines: 1, softWrap: false, style: AppText.body(Colors.white).copyWith(fontSize: 14, height: 1.1, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Botão "+" circular, com brilho (celular).
class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onPressed, this.size = 60});
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: 'Adicionar',
      child: Pressable(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        scale: 0.9,
        semanticLabel: 'Adicionar',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroGlow, c.heroStart, c.heroEnd]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            boxShadow: [BoxShadow(color: c.heroStart.withValues(alpha: 0.6), blurRadius: size * 0.4, offset: Offset(0, size * 0.16))],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: size * 0.54),
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
              message: 'Aparência',
              child: Pressable(
                onTap: onToggleTheme,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                    Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: c.textSecondary, size: 22),
                    if (extended) ...[
                      const SizedBox(width: 12),
                      Expanded(child: Text('Aparência', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontWeight: FontWeight.w600, fontSize: 14))),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroGlow, c.heroEnd]), boxShadow: [BoxShadow(color: c.heroStart.withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(0, 5))]),
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
        key: Key('nav-${item.label}'),
        onTap: onTap,
        scale: 0.98,
        semanticLabel: item.label,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : Motion.normal,
          curve: Motion.curve,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: extended ? 12 : 10),
          decoration: BoxDecoration(
            color: selected ? c.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: selected ? c.accent.withValues(alpha: 0.35) : Colors.transparent),
          ),
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
