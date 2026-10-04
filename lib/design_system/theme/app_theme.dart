import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Material 3 usado só como infraestrutura; a identidade vem dos tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: b).copyWith(
      primary: c.accent,
      surface: c.surface,
      error: c.danger,
      onSurface: c.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: AppText.display(c.textPrimary),
        titleLarge: AppText.title(c.textPrimary),
        bodyLarge: AppText.body(c.textPrimary),
        bodyMedium: AppText.body(c.textSecondary),
        labelSmall: AppText.label(c.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: Elevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: c.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.accent.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(AppText.label(c.textSecondary)),
      ),
    );
  }
}
