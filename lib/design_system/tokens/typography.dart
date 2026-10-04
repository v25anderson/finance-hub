import 'package:flutter/material.dart';

/// Tipografia: números grandes e hierarquia clara.
abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle display(Color c) =>
      TextStyle(fontSize: 44, height: 1.05, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: c, fontFeatures: _tabular);
  static TextStyle title(Color c) =>
      TextStyle(fontSize: 22, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: c);
  static TextStyle number(Color c) =>
      TextStyle(fontSize: 18, height: 1.2, fontWeight: FontWeight.w600, color: c, fontFeatures: _tabular);
  static TextStyle body(Color c) => TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w400, color: c);
  static TextStyle label(Color c) =>
      TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: c);
}
