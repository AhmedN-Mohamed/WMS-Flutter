import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.0', 'en_US');
  static final NumberFormat _intFormat = NumberFormat('#,##0', 'en_US');

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFormat.format(date);
  }

  static DateTime? tryParseDate(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    try {
      return _dateFormat.parseStrict(input.trim());
    } catch (_) {
      return DateTime.tryParse(input.trim());
    }
  }

  static String formatAmount(double amount, {String? currency}) {
    final formatted = amount == amount.roundToDouble()
        ? _intFormat.format(amount)
        : _currencyFormat.format(amount);
    if (currency != null && currency.isNotEmpty) {
      return '$formatted $currency';
    }
    return formatted;
  }

  static String formatNumber(num value) {
    return _intFormat.format(value);
  }

  static String arabicDayName(DateTime date) {
    const days = <int, String>{
      DateTime.monday: 'الإثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
    };
    return days[date.weekday] ?? '';
  }
}
