import 'package:intl/intl.dart';

/// دوال مساعدة موحدة لتنسيق الأرقام والمبالغ المالية والتواريخ
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _amountFormat = NumberFormat('#,##0.##', 'en_US');
  static final NumberFormat _twoDecimalsFormat = NumberFormat('#,##0.00', 'en_US');
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy/MM/dd hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// تنسيق المبالغ المالية مع فواصل الآلاف وخيار تحديد الكسور العشرية
  static String formatAmount(double amount, {bool forceDecimals = false}) {
    if (forceDecimals) {
      return _twoDecimalsFormat.format(amount);
    }
    return _amountFormat.format(amount);
  }

  /// تنسيق التاريخ بصيغة تقويم موحدة (yyyy/MM/dd)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// تنسيق التاريخ والوقت معاً
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// تنسيق الوقت فقط
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }
}
