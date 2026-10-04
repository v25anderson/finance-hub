import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Celular: bottom sheet em tela quase cheia. Desktop/tablet: painel lateral à direita.
Future<T?> showAdaptiveSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  final wide = MediaQuery.sizeOf(context).width >= Breakpoints.compact;
  final colors = context.colors;
  if (!wide) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      builder: (c) => FractionallySizedBox(heightFactor: 0.94, child: builder(c)),
    );
  }
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (c, _, _) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: colors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(Radii.xl))),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 480, height: double.infinity, child: SafeArea(child: builder(c))),
      ),
    ),
    transitionBuilder: (c, anim, _, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
