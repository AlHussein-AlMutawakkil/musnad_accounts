import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'app_formatted_amount.dart';

/// عنصر قائمة القيد / الحركة المالية في كشف الحساب أو الشاشة الرئيسية
class AppTransactionTile extends StatelessWidget {
  final TransactionType type;
  final double amount;
  final String currencySymbol;
  final String? details;
  final DateTime date;
  final bool isTransfer;
  final double? runningBalance;
  final VoidCallback? onTap;

  const AppTransactionTile({
    super.key,
    required this.type,
    required this.amount,
    required this.currencySymbol,
    this.details,
    required this.date,
    this.isTransfer = false,
    this.runningBalance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = type == TransactionType.credit;
    final typeColor = isCredit ? AppColors.credit : AppColors.debit;
    final typeBgColor = isCredit ? AppColors.creditLight : AppColors.debitLight;

    return AppCard(
      onTap: onTap,
      padding: AppDimensions.paddingListItem,
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Row(
        children: [
          // شارة نوع الحركة (له / عليه / تحويل)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space8,
              vertical: AppDimensions.space4,
            ),
            decoration: BoxDecoration(
              color: isTransfer ? AppColors.background : typeBgColor,
              borderRadius: AppDimensions.borderRadiusSm,
              border: Border.all(
                color: isTransfer ? AppColors.border : typeColor.withOpacity(0.3),
                width: AppDimensions.borderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isTransfer
                      ? Icons.swap_horiz_rounded
                      : (isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                  size: AppDimensions.iconXs,
                  color: isTransfer ? AppColors.primary : typeColor,
                ),
                const SizedBox(width: AppDimensions.space2),
                Text(
                  isTransfer ? 'تحويل' : type.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isTransfer ? AppColors.primary : typeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          // تفاصيل الحركة وتاريخها
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  details != null && details!.isNotEmpty ? details! : (isCredit ? 'قيد دائن (له)' : 'قيد مدين (عليه)'),
                  style: AppTextStyles.bodyMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  AppFormatters.formatDateTime(date),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          // المبلغ المالي والرصيد التراكمي
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFormattedAmount(
                amount: amount,
                currencySymbol: currencySymbol,
                isCredit: isCredit,
                showSign: true,
                style: AppTextStyles.amountMedium,
              ),
              if (runningBalance != null) ...[
                const SizedBox(height: AppDimensions.space2),
                Text(
                  'الرصيد: ${AppFormatters.formatAmount(runningBalance!)} $currencySymbol',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
