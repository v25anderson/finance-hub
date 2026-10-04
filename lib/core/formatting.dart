import 'package:intl/intl.dart';

final _day = DateFormat('dd/MM/yyyy', 'pt_BR');
final _dayShort = DateFormat('dd/MM', 'pt_BR');
final _dateTime = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
final _monthYear = DateFormat('MMMM yyyy', 'pt_BR');
final _monthName = DateFormat('MMMM', 'pt_BR');

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String formatDay(DateTime d) => _day.format(d);
String formatDayShort(DateTime d) => _dayShort.format(d);

/// Recebe um instante (UTC ou local) e mostra no horário local.
String formatDateTime(DateTime d) => _dateTime.format(d.toLocal());

/// `Outubro 2026`.
String formatMonthYear(DateTime d) => _cap(_monthYear.format(d));
String formatMonthName(int month) => _cap(_monthName.format(DateTime(2000, month)));

String formatPercent(double fraction) {
  final v = (fraction * 100);
  final s = v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1).replaceAll('.', ',');
  return '$s%';
}

/// `mar/26`.
String formatMonthShort(DateTime d) =>
    '${_cap(_monthName.format(d)).substring(0, 3).toLowerCase()}/${(d.year % 100).toString().padLeft(2, '0')}';

final _dayLong = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

/// `Sexta-feira, 10 de outubro`.
String formatDayLong(DateTime d) => _cap(_dayLong.format(d));
