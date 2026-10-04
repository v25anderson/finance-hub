import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

/// Toque com feedback próprio (leve redução de escala), no lugar da onda do Material.
/// Respeita "reduzir animações" do sistema.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97, this.semanticLabel, this.behavior = HitTestBehavior.opaque});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Widget child = AnimatedScale(
      scale: _down && !reduce ? widget.scale : 1,
      duration: reduce ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      child: widget.child,
    );
    if (widget.onTap == null) return child;
    child = GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: child,
    );
    return Semantics(button: true, label: widget.semanticLabel, container: widget.semanticLabel != null, child: MouseRegion(cursor: SystemMouseCursors.click, child: child));
  }
}
