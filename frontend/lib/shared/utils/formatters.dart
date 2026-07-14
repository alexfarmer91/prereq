import 'package:intl/intl.dart';

final _dollars = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
final _compact = NumberFormat.compactCurrency(symbol: r'$', decimalDigits: 1);
final _dateTime = DateFormat('MMM d, y HH:mm');

/// `$0.87` — contract price in dollars.
String formatPrice(double dollars) => _dollars.format(dollars);

/// `$14.1K` — compact volume.
String formatVolume(double dollars) => _compact.format(dollars);

/// `$1,000.00`.
String formatDollars(double dollars) => _dollars.format(dollars);

/// `+5.0%` / `-3.2%` (signed) for edges.
String formatEdge(double edge) {
  final pct = (edge * 100).toStringAsFixed(1);
  return edge >= 0 ? '+$pct%' : '$pct%';
}

/// `62%` for probabilities.
String formatPercent(double fraction, {int decimals = 0}) =>
    '${(fraction * 100).toStringAsFixed(decimals)}%';

/// `24.0%` for ROI-style values (signed).
String formatSignedPercent(double fraction, {int decimals = 1}) {
  final pct = (fraction * 100).toStringAsFixed(decimals);
  return fraction >= 0 ? '+$pct%' : '$pct%';
}

/// Human time-to-close: `3d 4h`, `5h 12m`, `42m`, or `Closed`.
String formatTimeToClose(Duration remaining) {
  if (remaining.isNegative) return 'Closed';
  if (remaining.inDays >= 1) {
    return '${remaining.inDays}d ${remaining.inHours % 24}h';
  }
  if (remaining.inHours >= 1) {
    return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
  }
  return '${remaining.inMinutes}m';
}

/// `May 19, 2026 04:59` (UTC).
String formatDateTimeUtc(DateTime dt) => '${_dateTime.format(dt.toUtc())} UTC';

/// `May 19` style short date (local time), used on chart axes.
String formatShortDate(DateTime dt) => DateFormat.MMMd().format(dt.toLocal());
