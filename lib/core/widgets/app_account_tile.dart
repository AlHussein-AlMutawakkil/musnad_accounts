import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'app_card.dart';
import 'app_formatted_amount.dart';

/// عنصر قائمة الحساب / الطرف المالي
class AppAccountTile extends StatelessWidget {
  final String name;
  final String? phone;
  final String? categoryName;
  final Map<String, double> balancesByCurrency; // مثل: {'ر.ي': 250000, '$': -120}
  final VoidCallback? onTap;

  const AppAccountTile({
    super.key,
    required this.name,
    this.phone,
    this.categoryName,
    this.balancesByCurrency = const {},
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppDimensions.paddingListItem,
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Row(
        children: [
          // أيقونة / الحرف الأول من الاسم
          Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: AppDimensions.borderRadiusSm,
            ),
            child: Text(
              name.isNotEmpty ? name.characters.first : '؟',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          // تفاصيل الحساب (الاسم، الهاتف، التصنيف)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space2),
                Row(
                  children: [
                    if (categoryName != null && categoryName!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space4,
                          vertical: AppDimensions.space2,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppDimensions.borderRadiusSm,
                        ),
                        child: Text(
                          categoryName!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space8),
                    ],
                    if (phone != null && phone!.isNotEmpty)
                      Expanded(
                        child: Text(
                          phone!,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          // قائمة الأرصدة بحسب العملات
          if (balancesByCurrency.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: balancesByCurrency.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space2),
                  child: AppFormattedAmount(
                    amount: entry.value,
                    currencySymbol: entry.key,
                    style: AppTextStyles.amountSmall,
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'لا توجد حركات',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
            ),
          const SizedBox(width: AppDimensions.space4),
          const Icon(
            Icons.chevron_left,
            color: AppColors.textHint,
            size: AppDimensions.iconSm,
          ),
        ],
      ),
    );
  }
}
