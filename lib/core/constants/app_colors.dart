import 'package:flutter/material.dart';

/// الألوان المركزية للمنظومة التصميمية (Enterprise / Dense)
/// مستندة إلى وثيقة docs/DESIGN_SYSTEM.md
class AppColors {
  AppColors._();

  // 1. الألوان الأساسية للمنظومة
  /// اللون الكحلي المؤسسي الرئيسي
  static const Color primary = Color(0xFF1B365D);

  /// تدرج كحلي أفتح للعناصر النشطة والتفاعلية
  static const Color primaryLight = Color(0xFF2E4D78);

  /// تدرج كحلي داكن للحالات المركزة والرؤوس
  static const Color primaryDark = Color(0xFF10233E);

  /// الخلفية العامة للتطبيق (رمادي فاتح محايد)
  static const Color background = Color(0xFFF4F5F7);

  /// أسطح البطاقات والحاويات (أبيض نقي)
  static const Color surface = Color(0xFFFFFFFF);

  /// لون (له / دائن) المعتمد محاسبياً
  static const Color credit = Color(0xFF1B873F);

  /// خلفية مخففة لمؤشرات وبطاقات الدائن
  static const Color creditLight = Color(0xFFE8F5E9);

  /// لون (عليه / مدين) المعتمد محاسبياً
  static const Color debit = Color(0xFFC5221F);

  /// خلفية مخففة لمؤشرات وبطاقات المدين
  static const Color debitLight = Color(0xFFFFEBEE);

  /// الحدود الدقيقة الموحدة لكافة البطاقات والحقول
  static const Color border = Color(0xFFE0E0E0);

  /// لون الحدود في حالة التركيز (Focus)
  static const Color borderFocused = Color(0xFF1B365D);

  // 2. ألوان النصوص
  /// النص الأساسي الأكثر وضوحاً
  static const Color textPrimary = Color(0xFF202124);

  /// النص الثانوي والشروحات
  static const Color textSecondary = Color(0xFF5F6368);

  /// نصوص التلميح داخل الحقول
  static const Color textHint = Color(0xFF9AA0A6);

  /// النص المعكوس على الخلفيات الداكنة كالأزرار الرئيسية
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 3. ألوان الحالات والوظائف
  /// خطوط التقسيم الدقيقة
  static const Color divider = Color(0xFFEEEEEE);

  /// لون التحذير
  static const Color warning = Color(0xFFE37400);

  /// خلفية خفيفة للتحذيرات
  static const Color warningLight = Color(0xFFFFF3E0);

  /// لون المعلومات
  static const Color info = Color(0xFF1A73E8);

  /// خلفية خفيفة للمعلومات
  static const Color infoLight = Color(0xFFE8F0FE);

  /// شفاف
  static const Color transparent = Colors.transparent;

  // 4. دوال مساعدة لحساب اللون محاسبياً
  /// تحديد اللون المناسب للرصيد (أخضر للدائن، أحمر للمدين، رمادي للمتعادل)
  static Color forBalance(double balance) {
    if (balance > 0) return credit;
    if (balance < 0) return debit;
    return textSecondary;
  }

  /// تحديد لون نوع الحركة ('CREDIT' دائن، 'DEBIT' مدين)
  static Color forTransactionType(String type) {
    if (type.toUpperCase() == 'CREDIT') return credit;
    if (type.toUpperCase() == 'DEBIT') return debit;
    return textSecondary;
  }
}
