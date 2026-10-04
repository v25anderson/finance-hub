import 'package:flutter/material.dart';

/// Estados semânticos: a cor sempre carrega significado.
enum Tone { success, warning, danger, neutral, info }

/// Paleta semântica, registrada como ThemeExtension (Light/Dark).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentSoft,
    required this.heroStart,
    required this.heroEnd,
    required this.heroGlow,
    required this.seriesA,
    required this.seriesB,
    required this.seriesC,
    required this.success,
    required this.warning,
    required this.danger,
    required this.neutral,
    required this.info,
  });

  final Color background, surface, surfaceAlt, border;
  final Color textPrimary, textSecondary, accent;

  /// Fundo suave da cor de destaque (itens selecionados, ícones em círculo).
  final Color accentSoft;

  /// Degradê do cabeçalho de destaque (números grandes sobre cor de marca).
  final Color heroStart, heroEnd;

  /// Brilho claro da mesma família (halo do cabeçalho, cápsula ativa, "+").
  final Color heroGlow;

  /// Cores de séries de gráfico (ordem fixa, validadas para daltonismo nos dois temas).
  /// Para uma série única, os gráficos usam [accent].
  final Color seriesA, seriesB, seriesC;
  final Color success, warning, danger, neutral, info;

  /// Texto e ícones sobre o degradê de destaque.
  static const onHero = Color(0xFFFFFFFF);

  static const light = AppColors(
    background: Color(0xFFF4F2F9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEEBF5),
    border: Color(0xFFE4E0EE),
    textPrimary: Color(0xFF14111F),
    textSecondary: Color(0xFF6B6580),
    accent: Color(0xFF7A2BF0),
    accentSoft: Color(0xFFEFE5FF),
    heroStart: Color(0xFF8B34F5),
    heroEnd: Color(0xFF3A1096),
    heroGlow: Color(0xFFC58BFF),
    seriesA: Color(0xFF2A78D6),
    seriesB: Color(0xFFEB6834),
    seriesC: Color(0xFF1BAF7A),
    success: Color(0xFF0E9F55),
    warning: Color(0xFFC9780A),
    danger: Color(0xFFDC3C45),
    neutral: Color(0xFF6B6580),
    info: Color(0xFF2F6FEB),
  );

  static const dark = AppColors(
    background: Color(0xFF09090D),
    surface: Color(0xFF14141A),
    surfaceAlt: Color(0xFF1E1E27),
    border: Color(0xFF282833),
    textPrimary: Color(0xFFF6F5FA),
    textSecondary: Color(0xFF9B97AB),
    accent: Color(0xFFA877FF),
    accentSoft: Color(0xFF2A1C47),
    heroStart: Color(0xFF6A27D8),
    heroEnd: Color(0xFF1B0847),
    heroGlow: Color(0xFFB17BFF),
    seriesA: Color(0xFF3987E5),
    seriesB: Color(0xFFD95926),
    seriesC: Color(0xFF199E70),
    success: Color(0xFF3DD68C),
    warning: Color(0xFFF5B544),
    danger: Color(0xFFFF6B72),
    neutral: Color(0xFF9B97AB),
    info: Color(0xFF6AA2FF),
  );

  Color tone(Tone t) => switch (t) {
        Tone.success => success,
        Tone.warning => warning,
        Tone.danger => danger,
        Tone.neutral => neutral,
        Tone.info => info,
      };

  @override
  AppColors copyWith({Color? background}) => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => this;
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
