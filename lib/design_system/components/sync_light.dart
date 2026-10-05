import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum SyncLightState {
  /// Drive não configurado ou desconectado.
  off,

  /// Conectado, ainda sem sincronizar.
  idle,

  /// Sincronizando (pulsa).
  busy,

  /// Em dia.
  ok,

  /// Falhou ou há conflito a resolver.
  problem,
}

/// "Luz" de sincronização: um ponto com brilho, na cor do estado (cinza, roxo, âmbar pulsando, verde, vermelho).
/// Só pulsa quando o usuário não pediu para reduzir movimento.
class SyncLight extends StatefulWidget {
  const SyncLight({super.key, required this.state, this.size = 10});
  final SyncLightState state;
  final double size;

  static Color colorOf(AppColors c, SyncLightState s) => switch (s) {
        SyncLightState.off => c.neutral,
        SyncLightState.idle => c.accent,
        SyncLightState.busy => c.warning,
        SyncLightState.ok => c.success,
        SyncLightState.problem => c.danger,
      };

  @override
  State<SyncLight> createState() => _SyncLightState();
}

class _SyncLightState extends State<SyncLight> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SyncLight old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.state == SyncLightState.busy && !reduce) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = SyncLight.colorOf(context.colors, widget.state);
    final glow = widget.state != SyncLightState.off;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: glow ? [BoxShadow(color: color.withValues(alpha: 0.55 + _pulse.value * 0.3), blurRadius: 6 + _pulse.value * 8, spreadRadius: _pulse.value * 2)] : null,
        ),
      ),
    );
  }
}

/// Pílula com a luz e um texto curto ("Sincronizado", "Sincronizando…").
class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.state, required this.label});
  final SyncLightState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = SyncLight.colorOf(c, state);
    return Semantics(
      label: 'Sincronização: $label',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(Radii.pill), border: Border.all(color: color.withValues(alpha: 0.35))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SyncLight(state: state, size: 9),
          const SizedBox(width: 8),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(color).copyWith(fontSize: 13, fontWeight: FontWeight.w700, height: 1.1))),
        ]),
      ),
    );
  }
}
