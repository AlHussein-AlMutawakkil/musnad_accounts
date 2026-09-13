import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../utils/formatters.dart';

/// حقل اختيار التاريخ بتصميم موحد للمنظومة
class AppDatePickerField extends StatelessWidget {
  final String? label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePickerField({
    super.key,
    this.label,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AppTextStyles.labelBold,
          ),
          const SizedBox(height: AppDimensions.space4),
        ],
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: AppDimensions.borderRadius,
          child: Container(
            height: AppDimensions.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.borderRadius,
              border: Border.all(
                color: AppColors.border,
                width: AppDimensions.borderWidth,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppDimensions.iconSm,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Text(
                    AppFormatters.formatDate(selectedDate),
                    style: AppTextStyles.inputText,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconMd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
