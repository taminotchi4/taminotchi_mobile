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

String formatPhoneNumber(String phone) {
  if (phone.isEmpty) return '';
  
  // Remove all non-digits to start clean
  String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  
  if (digits.isEmpty) return phone;

  // Check if it's a 12-digit number (Uzbekistan: 998 + 9 digits)
  if (digits.length == 12 && digits.startsWith('998')) {
    return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10)}';
  }
  
  return phone; // Return original if it doesn't match expected pattern
}
