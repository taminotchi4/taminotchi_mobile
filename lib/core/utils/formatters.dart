import 'package:intl/intl.dart';

String formatPrice(double value) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return '${formatter.format(value)} so\'m';
}

String formatCompactCount(int value) {
  const thousand = 1000;
  const million = 1000000;
  if (value >= million) {
    final result = (value / million).toStringAsFixed(1);
    return '${result}m';
  }
  if (value >= thousand) {
    final result = (value / thousand).toStringAsFixed(1);
    return '${result}k';
  }
  return value.toString();
}
