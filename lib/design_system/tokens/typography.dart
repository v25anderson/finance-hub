import 'package:flutter/material.dart';

/// Tipografia: Inter embutida, números grandes e hierarquia clara.
abstract final class AppText {
  static const family = 'Inter';
  static const _tabular = [FontFeature.tabularFigures()];

  /// Número de destaque (cabeçalho).
  static TextStyle hero(Color c) => TextStyle(
      fontFamily: family, fontSize: 48, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1.8, color: c, fontFeatures: _tabular);

  static TextStyle display(Color c) => TextStyle(
      fontFamily: family, fontSize: 40, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1.4, color: c, fontFeatures: _tabular);

  /// Título de página.
  static TextStyle title(Color c) =>
      TextStyle(fontFamily: family, fontSize: 26, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: c);

  static TextStyle headline(Color c) =>
      TextStyle(fontFamily: family, fontSize: 19, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: c);

  static TextStyle number(Color c) =>
      TextStyle(fontFamily: family, fontSize: 17, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: c, fontFeatures: _tabular);

  static TextStyle body(Color c) => TextStyle(fontFamily: family, fontSize: 15, height: 1.45, fontWeight: FontWeight.w400, color: c);

  static TextStyle label(Color c) =>
      TextStyle(fontFamily: family, fontSize: 11.5, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: c);
}
