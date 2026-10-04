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
    required this.success,
    required this.warning,
    required this.danger,
    required this.neutral,
    required this.info,
  });

  final Color background, surface, surfaceAlt, border;
  final Color textPrimary, textSecondary, accent;
  final Color success, warning, danger, neutral, info;

  static const light = AppColors(
    background: Color(0xFFF6F5F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEFEDF3),
    border: Color(0xFFE2DFE9),
    textPrimary: Color(0xFF16141C),
    textSecondary: Color(0xFF6B6778),
    accent: Color(0xFF6A2FD0),
    success: Color(0xFF138A52),
    warning: Color(0xFFB7791F),
    danger: Color(0xFFC53030),
    neutral: Color(0xFF6B6778),
    info: Color(0xFF2B6CB0),
  );

  static const dark = AppColors(
    background: Color(0xFF0E0D12),
    surface: Color(0xFF17151D),
    surfaceAlt: Color(0xFF211E29),
    border: Color(0xFF2E2A39),
    textPrimary: Color(0xFFF4F2F8),
    textSecondary: Color(0xFFA09BB0),
    accent: Color(0xFFA37BFF),
    success: Color(0xFF3DCB87),
    warning: Color(0xFFF2B84B),
    danger: Color(0xFFFF6B6B),
    neutral: Color(0xFFA09BB0),
    info: Color(0xFF63B3ED),
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
