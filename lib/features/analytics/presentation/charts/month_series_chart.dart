import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/dates.dart';
import '../../../../core/formatting.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import 'chart_format.dart';

enum SeriesKind { line, stackedBars, groupedBars }

class ChartSeries {
  const ChartSeries({required this.label, required this.color, required this.values});
  final String label;
  final Color color;

  /// Um valor por mês (mesma ordem de `months`). Nulo = sem dado (a linha interrompe).
  final List<double?> values;
}

/// Gráfico por mês: linha, barras empilhadas ou barras agrupadas, num único eixo (nunca dois).
///
/// - Marcas finas: barra ≤ 24 px com 4 px de arredondamento só na ponta, linha de 2 px, ponto final de 9 px com anel.
/// - Espaçador de 2 px entre trechos empilhados e entre barras agrupadas.
/// - Toque ou arraste seleciona o mês; a leitura (valores de todas as séries) fica acima do gráfico.
/// - Legenda quando há 2 ou mais séries; "ver como tabela" dá acesso a todos os valores sem depender do gráfico.
class MonthSeriesChart extends StatefulWidget {
  const MonthSeriesChart({
    super.key,
    required this.id,
    required this.months,
    required this.series,
    required this.kind,
    required this.format,
    required this.axisFormat,
    this.height = 190,
  });

  final String id;
  final List<String> months;
  final List<ChartSeries> series;
  final SeriesKind kind;

  /// Formata um valor completo (leitura e tabela).
  final String Function(double) format;

  /// Formata um valor de eixo (compacto).
  final String Function(double) axisFormat;
  final double height;

  @override
  State<MonthSeriesChart> createState() => _MonthSeriesChartState();
}

class _MonthSeriesChartState extends State<MonthSeriesChart> {
  int? _selected;
  bool _table = false;

  @override
  void didUpdateWidget(covariant MonthSeriesChart old) {
    super.didUpdateWidget(old);
    if (old.months.length != widget.months.length) _selected = null;
  }

  int get _index => (_selected ?? widget.months.length - 1).clamp(0, widget.months.length - 1);

  void _pick(double x, double width) {
    final i = nearestSlotIndex(x, left: _SeriesPainter.left, width: width - _SeriesPainter.left - _SeriesPainter.right, count: widget.months.length);
    if (i != _selected) setState(() => _selected = i);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = widget;
    if (w.months.isEmpty) return const SizedBox.shrink();
    final idx = _index;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Readout(chart: w, index: idx)),
        IconButton(
          key: Key('table-toggle-${w.id}'),
          tooltip: _table ? 'Ver gráfico' : 'Ver como tabela',
          visualDensity: VisualDensity.compact,
          onPressed: () => setState(() => _table = !_table),
          icon: Icon(_table ? Icons.show_chart_rounded : Icons.table_rows_outlined, size: 20, color: c.textSecondary),
        ),
      ]),
      const SizedBox(height: Space.sm),
      if (_table)
        _DataTable(chart: w)
      else ...[
        SizedBox(
          height: w.height,
          child: LayoutBuilder(builder: (context, box) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _pick(d.localPosition.dx, box.maxWidth),
              onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, box.maxWidth),
              child: Semantics(
                label: '${w.series.map((s) => s.label).join(', ')} por mês, de ${formatMonthShort(parseYearMonth(w.months.first))} a ${formatMonthShort(parseYearMonth(w.months.last))}. Use "ver como tabela" para todos os valores.',
                child: CustomPaint(
                  key: Key('chart-${w.id}'),
                  size: Size(box.maxWidth, w.height),
                  painter: _SeriesPainter(chart: w, selected: idx, colors: c),
                ),
              ),
            );
          }),
        ),
        if (w.series.length >= 2) ...[const SizedBox(height: Space.sm), _Legend(chart: w)],
      ],
    ]);
  }
}

/// Valores do mês selecionado: o valor lidera (tinta primária), o nome da série vem depois (secundária).
class _Readout extends StatelessWidget {
  const _Readout({required this.chart, required this.index});
  final MonthSeriesChart chart;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final month = formatMonthShort(parseYearMonth(chart.months[index]));
    return Wrap(
      key: Key('readout-${chart.id}'),
      spacing: Space.md,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(month, key: Key('readout-month-${chart.id}'), style: AppText.body(c.textSecondary).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
        for (final (i, s) in chart.series.indexed)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: chart.kind == SeriesKind.line ? 14 : 9,
              height: chart.kind == SeriesKind.line ? 3 : 9,
              decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(chart.kind == SeriesKind.line ? 2 : 2.5)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  s.values[index] == null ? '—' : chart.format(s.values[index]!),
                  key: Key('readout-value-${chart.id}-$i'),
                  maxLines: 1,
                  style: AppText.number(c.textPrimary).copyWith(fontSize: 16),
                ),
              ),
            ),
            if (chart.series.length > 1) ...[
              const SizedBox(width: 5),
              Flexible(child: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5))),
            ],
          ]),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.chart});
  final MonthSeriesChart chart;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(spacing: Space.md, runSpacing: 4, children: [
      for (final s in chart.series)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: chart.kind == SeriesKind.line ? 14 : 10,
            height: chart.kind == SeriesKind.line ? 3 : 10,
            decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 6),
          Text(s.label, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ]),
    ]);
  }
}

/// Todos os valores em tabela (acessível, não depende de cor nem de toque).
class _DataTable extends StatelessWidget {
  const _DataTable({required this.chart});
  final MonthSeriesChart chart;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget cell(String t, {bool header = false, bool first = false}) => Expanded(
          flex: first ? 2 : 3,
          child: Align(
            alignment: first ? Alignment.centerLeft : Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(t, maxLines: 1, style: header ? AppText.label(c.textSecondary) : AppText.body(first ? c.textSecondary : c.textPrimary).copyWith(fontSize: 13.5, fontWeight: first ? FontWeight.w500 : FontWeight.w600)),
            ),
          ),
        );
    return Column(key: Key('table-${chart.id}'), children: [
      Row(children: [cell('MÊS', header: true, first: true), for (final s in chart.series) cell(s.label.toUpperCase(), header: true)]),
      Divider(color: c.border, height: Space.md),
      for (final (i, ym) in chart.months.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            cell(formatMonthShort(parseYearMonth(ym)), first: true),
            for (final s in chart.series) cell(s.values[i] == null ? '—' : chart.format(s.values[i]!)),
          ]),
        ),
    ]);
  }
}

class _SeriesPainter extends CustomPainter {
  _SeriesPainter({required this.chart, required this.selected, required this.colors});
  final MonthSeriesChart chart;
  final int selected;
  final AppColors colors;

  static const left = 46.0, right = 6.0, top = 10.0, bottom = 24.0;
  static const _gap = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final n = chart.months.length;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0 || n == 0) return;
    final surface = colors.surface;

    // escala (um único eixo, sempre a partir de zero)
    var maxV = 0.0;
    for (var i = 0; i < n; i++) {
      var sum = 0.0;
      for (final s in chart.series) {
        final v = s.values[i];
        if (v == null || v <= 0) continue;
        sum += v;
        if (chart.kind != SeriesKind.stackedBars && v > maxV) maxV = v;
      }
      if (chart.kind == SeriesKind.stackedBars && sum > maxV) maxV = sum;
    }
    final ticks = niceTicks(maxV);
    final yMax = ticks.last;
    double y(double v) => plot.bottom - (v / yMax) * plot.height;
    final slotW = plot.width / n;
    double cx(int i) => plot.left + slotW * (i + 0.5);

    // faixa do mês selecionado (barras)
    if (chart.kind != SeriesKind.line) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(plot.left + slotW * selected, plot.top, slotW, plot.height), const Radius.circular(6)),
        Paint()..color = colors.surfaceAlt.withValues(alpha: 0.7),
      );
    }

    // grade fina e rótulos do eixo y
    for (final t in ticks) {
      final yy = y(t);
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), Paint()..color = colors.border.withValues(alpha: t == 0 ? 1 : 0.6)..strokeWidth = 1);
      _text(canvas, chart.axisFormat(t), Offset(plot.left - 6, yy), align: _Align.right, color: colors.textSecondary, size: 10.5);
    }

    // rótulos do eixo x: o mais recente sempre aparece
    final maxLabels = (plot.width / 44).floor().clamp(2, 24);
    final step = (n / maxLabels).ceil().clamp(1, 24);
    for (var i = 0; i < n; i++) {
      if ((n - 1 - i) % step != 0) continue;
      _text(canvas, formatMonthShort(parseYearMonth(chart.months[i])), Offset(cx(i), plot.bottom + 13), align: _Align.center, color: colors.textSecondary, size: 10.5, clampWidth: size.width);
    }

    switch (chart.kind) {
      case SeriesKind.stackedBars:
        _stacked(canvas, plot, slotW, cx, y, surface);
      case SeriesKind.groupedBars:
        _grouped(canvas, plot, slotW, cx, y);
      case SeriesKind.line:
        _lines(canvas, plot, n, cx, y, surface);
    }
  }

  void _stacked(Canvas canvas, Rect plot, double slotW, double Function(int) cx, double Function(double) y, Color surface) {
    final barW = (slotW * 0.62).clamp(3.0, 24.0);
    for (var i = 0; i < chart.months.length; i++) {
      final live = [for (final (k, s) in chart.series.indexed) if ((s.values[i] ?? 0) > 0) k];
      var base = plot.bottom;
      for (final (pos, k) in live.indexed) {
        final s = chart.series[k];
        final top = y(s.values[i]!) - (plot.bottom - base);
        final isTop = pos == live.length - 1;
        final seg = Rect.fromLTRB(cx(i) - barW / 2, top, cx(i) + barW / 2, base - (pos == 0 ? 0 : _gap));
        if (seg.height < 0.5) continue;
        canvas.drawRRect(
          RRect.fromRectAndCorners(seg, topLeft: Radius.circular(isTop ? 4 : 0), topRight: Radius.circular(isTop ? 4 : 0)),
          Paint()..color = s.color,
        );
        base = top;
      }
    }
  }

  void _grouped(Canvas canvas, Rect plot, double slotW, double Function(int) cx, double Function(double) y) {
    final k = chart.series.length;
    final bw = ((slotW * 0.74 - _gap * (k - 1)) / k).clamp(3.0, 14.0);
    final total = k * bw + (k - 1) * _gap;
    for (var i = 0; i < chart.months.length; i++) {
      var x0 = cx(i) - total / 2;
      for (final s in chart.series) {
        final v = s.values[i];
        if (v != null && v > 0) {
          final r = Rect.fromLTRB(x0, y(v), x0 + bw, plot.bottom);
          canvas.drawRRect(RRect.fromRectAndCorners(r, topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), Paint()..color = s.color);
        }
        x0 += bw + _gap;
      }
    }
  }

  void _lines(Canvas canvas, Rect plot, int n, double Function(int) cx, double Function(double) y, Color surface) {
    // cruzeta do mês selecionado
    canvas.drawLine(Offset(cx(selected), plot.top), Offset(cx(selected), plot.bottom), Paint()..color = colors.textSecondary.withValues(alpha: 0.35)..strokeWidth = 1);
    for (final s in chart.series) {
      final runs = <List<int>>[];
      var cur = <int>[];
      for (var i = 0; i < n; i++) {
        if (s.values[i] == null) {
          if (cur.isNotEmpty) runs.add(cur);
          cur = <int>[];
        } else {
          cur.add(i);
        }
      }
      if (cur.isNotEmpty) runs.add(cur);

      for (final run in runs) {
        if (run.length < 2) continue;
        final line = Path()..moveTo(cx(run.first), y(s.values[run.first]!));
        for (final i in run.skip(1)) {
          line.lineTo(cx(i), y(s.values[i]!));
        }
        final area = Path.from(line)
          ..lineTo(cx(run.last), plot.bottom)
          ..lineTo(cx(run.first), plot.bottom)
          ..close();
        canvas.drawPath(area, Paint()..color = s.color.withValues(alpha: 0.10));
        canvas.drawPath(
          line,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
      // ponto final e ponto do mês selecionado, com anel da cor da superfície
      final last = [for (var i = 0; i < n; i++) if (s.values[i] != null) i];
      final marks = <int>{if (last.isNotEmpty) last.last, if (s.values[selected] != null) selected};
      for (final i in marks) {
        final c = Offset(cx(i), y(s.values[i]!));
        canvas.drawCircle(c, 6.5, Paint()..color = surface);
        canvas.drawCircle(c, 4.5, Paint()..color = s.color);
      }
    }
  }

  void _text(Canvas canvas, String text, Offset anchor, {required _Align align, required Color color, required double size, double? clampWidth}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontFamily: AppText.family, fontSize: size, color: color, fontWeight: FontWeight.w500)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    var dx = switch (align) {
      _Align.right => anchor.dx - tp.width,
      _Align.center => anchor.dx - tp.width / 2,
    };
    if (clampWidth != null) dx = dx.clamp(0.0, clampWidth - tp.width);
    tp.paint(canvas, Offset(dx, anchor.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SeriesPainter old) => true;
}

enum _Align { right, center }
