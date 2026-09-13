import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';

/// ودجت لعرض المبالغ المالية مع فواصل الآلاف وتلوين تلقائي (أخضر لدائن / أحمر لمدين)
class AppFormattedAmount extends StatelessWidget {
  final double amount;
  final String? currencySymbol;
  final bool? isCredit;
  final bool showSign;
  final TextStyle? style;
  final bool forceDecimals;

  const AppFormattedAmount({
    super.key,
    required this.amount,
    this.currencySymbol,
    this.isCredit,
    this.showSign = false,
    this.style,
    this.forceDecimals = false,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الحالة المحاسبية: إذا تم تمريرها صراحة أو بناءً على إشارة المبلغ
    final effectiveIsCredit = isCredit ?? (amount >= 0);
    final isZero = amount == 0;

    Color color;
    if (isZero) {
      color = AppColors.textPrimary;
    } else if (effectiveIsCredit) {
      color = AppColors.credit;
    } else {
      color = AppColors.debit;
    }

    final effectiveStyle = (style ?? AppTextStyles.amountMedium).copyWith(color: color);

    final sign = showSign && !isZero
        ? (effectiveIsCredit ? '+' : '-')
        : '';

    final absAmount = amount.abs();
    final formattedValue = '$sign${AppFormatters.formatAmount(absAmount, forceDecimals: forceDecimals)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formattedValue,
          style: effectiveStyle,
        ),
        if (currencySymbol != null && currencySymbol!.isNotEmpty) ...[
          const SizedBox(width: AppDimensions.space4),
          Text(
            currencySymbol!,
            style: AppTextStyles.currencySymbol.copyWith(
              color: color.withOpacity(0.85),
            ),
          ),
        ],
      ],
    );
  }
}
