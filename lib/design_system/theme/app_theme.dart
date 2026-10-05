import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Material 3 só como infraestrutura (acessibilidade, foco, diálogos): toda a aparência vem daqui.
/// Sem ondas de toque, sem tons de superfície, botões em pílula e campos preenchidos.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: b).copyWith(
      primary: c.accent,
      onPrimary: b == Brightness.light ? Colors.white : const Color(0xFF14002E),
      surface: c.surface,
      onSurface: c.textPrimary,
      error: c.danger,
      surfaceTint: Colors.transparent,
      surfaceContainerHighest: c.surfaceAlt,
      outline: c.border,
      outlineVariant: c.border,
    );
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.pill));
    final fieldRadius = BorderRadius.circular(Radii.md);
    OutlineInputBorder field(Color color, [double w = 0]) => OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: w == 0 ? BorderSide.none : BorderSide(color: color, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppText.family,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.surface,
      extensions: [c],
      dividerColor: c.border,
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: c.accent.withValues(alpha: 0.05),
      focusColor: c.accent.withValues(alpha: 0.10),
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: TextTheme(
        displayLarge: AppText.display(c.textPrimary),
        headlineMedium: AppText.title(c.textPrimary),
        titleLarge: AppText.headline(c.textPrimary),
        titleMedium: AppText.number(c.textPrimary),
        bodyLarge: AppText.body(c.textPrimary),
        bodyMedium: AppText.body(c.textPrimary),
        bodySmall: AppText.body(c.textSecondary).copyWith(fontSize: 13),
        labelLarge: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w700),
        labelSmall: AppText.label(c.textSecondary),
      ),
      iconTheme: IconThemeData(color: c.textPrimary, size: 24),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: Elevation.none,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: c.border.withValues(alpha: b == Brightness.light ? 0.7 : 1)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: c.surfaceAlt,
          disabledForegroundColor: c.textSecondary.withValues(alpha: 0.6),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          shape: pill,
          elevation: 5,
          shadowColor: c.accent.withValues(alpha: b == Brightness.light ? 0.45 : 0.55),
          textStyle: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.accent,
          backgroundColor: c.accentSoft,
          disabledForegroundColor: c.textSecondary.withValues(alpha: 0.5),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: pill,
          side: BorderSide(color: c.accent.withValues(alpha: 0.30), width: 1.2),
          textStyle: AppText.body(c.accent).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          backgroundColor: c.accentSoft.withValues(alpha: 0.7),
          shape: pill,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          textStyle: AppText.body(c.accent).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: c.textPrimary)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: field(c.border),
        enabledBorder: field(c.border),
        disabledBorder: field(c.border),
        focusedBorder: field(c.accent, 1.6),
        errorBorder: field(c.danger, 1.2),
        focusedErrorBorder: field(c.danger, 1.6),
        labelStyle: AppText.body(c.textSecondary),
        floatingLabelStyle: AppText.body(c.accent).copyWith(fontWeight: FontWeight.w600),
        hintStyle: AppText.body(c.textSecondary),
        errorStyle: AppText.body(c.danger).copyWith(fontSize: 12),
        prefixStyle: AppText.body(c.textSecondary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        titleTextStyle: AppText.headline(c.textPrimary),
        contentTextStyle: AppText.body(c.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.border),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.accentSoft,
        side: BorderSide.none,
        shape: pill,
        showCheckmark: false,
        labelStyle: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
        secondaryLabelStyle: AppText.body(c.accent).copyWith(fontWeight: FontWeight.w700, fontSize: 13.5),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceAlt,
        linearMinHeight: 8,
        circularTrackColor: c.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: b == Brightness.light ? const Color(0xFF1C1828) : c.surfaceAlt,
        contentTextStyle: AppText.body(Colors.white).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
        actionTextColor: b == Brightness.light ? const Color(0xFFC9A6FF) : c.accent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.textPrimary, borderRadius: BorderRadius.circular(Radii.sm)),
        textStyle: AppText.body(c.background).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.headline(c.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        titleTextStyle: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: AppText.body(c.textSecondary).copyWith(fontSize: 13),
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.textSecondary)),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        headerBackgroundColor: c.accent,
        headerForegroundColor: Colors.white,
        todayBorder: BorderSide(color: c.accent),
        todayForegroundColor: WidgetStatePropertyAll(c.accent),
        dayStyle: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        dialHandColor: c.accent,
      ),
    );
  }
}
