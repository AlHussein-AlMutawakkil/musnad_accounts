import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// زر التبديل المزدوج المحاسبي بين (له / دائن) و (عليه / مدين)
class AppTypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const AppTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadius,
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.space2),
      child: Row(
        children: [
          // زر (له / دائن)
          Expanded(
            child: _buildOption(
              type: TransactionType.credit,
              title: 'له (دائن)',
              isSelected: selectedType == TransactionType.credit,
              activeColor: AppColors.credit,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          const SizedBox(width: AppDimensions.space2),
          // زر (عليه / مدين)
          Expanded(
            child: _buildOption(
              type: TransactionType.debit,
              title: 'عليه (مدين)',
              isSelected: selectedType == TransactionType.debit,
              activeColor: AppColors.debit,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required TransactionType type,
    required String title,
    required bool isSelected,
    required Color activeColor,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: AppDimensions.borderRadiusSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: AppDimensions.borderRadiusSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSm,
              color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.space4),
            Text(
              title,
              style: isSelected
                  ? AppTextStyles.button.copyWith(fontSize: 13.0)
                  : AppTextStyles.labelBold.copyWith(fontSize: 13.0),
            ),
          ],
        ),
      ),
    );
  }
}
