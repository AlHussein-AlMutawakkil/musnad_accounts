import 'package:flutter/material.dart';
import 'app_colors.dart';

/// أنماط النصوص الموحدة للمنظومة (Enterprise Dense Typography)
/// تضمن وضوحاً عالياً للأرقام المالية والنصوص العربية
class AppTextStyles {
  AppTextStyles._();

  // 1. العناوين الرئيسية والفرعية (Headings)
  static const TextStyle h1 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // 2. نصوص المحتوى والقوائم (Body Text)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmallBold = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // 3. التسميات والتلميحات (Labels & Hints)
  static const TextStyle label = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // 4. الأزرار (Buttons)
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  // 5. الأرقام والمبالغ المالية (Financial & Amounts)
  static const TextStyle amountLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountCredit = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.credit,
  );

  static const TextStyle amountDebit = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.debit,
  );

  static const TextStyle currencySymbol = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
