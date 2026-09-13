import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

/// نوع مؤشر بطاقة الأداء المالي
enum KpiType {
  credit, // دائن / له (أخضر)
  debit,  // مدين / عليه (أحمر)
  neutral,// محايد / أساسي (كحلي)
}

/// بطاقة عرض مؤشرات الأداء المالي والملخصات (له / عليه / الصافي)
class AppKpiCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final KpiType type;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;

  const AppKpiCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currencySymbol,
    this.type = KpiType.neutral,
    this.icon,
    this.subtitle,
    this.onTap,
  });

  Color get _accentColor {
    switch (type) {
      case KpiType.credit:
        return AppColors.credit;
      case KpiType.debit:
        return AppColors.debit;
      case KpiType.neutral:
        return AppColors.primary;
    }
  }

  Color get _badgeBgColor {
    switch (type) {
      case KpiType.credit:
        return AppColors.creditLight;
      case KpiType.debit:
        return AppColors.debitLight;
      case KpiType.neutral:
        return const Color(0xFFE8EEF5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط العنوان مع الأيقونة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 11.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppDimensions.space2),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: _badgeBgColor,
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    size: 13.0,
                    color: _accentColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.space4),
          // عرض المبلغ والرمز مع FittedBox بعرض كامل البطاقة لمنع أي تجاوز أفقي (RenderFlex Overflow)
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppFormatters.formatAmount(amount),
                    style: AppTextStyles.amountLarge.copyWith(
                      color: _accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space4),
                  Text(
                    currencySymbol,
                    style: AppTextStyles.currencySymbol.copyWith(
                      color: _accentColor.withOpacity(0.85),
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // نص فرعي إضافي
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space2),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(fontSize: 10.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
