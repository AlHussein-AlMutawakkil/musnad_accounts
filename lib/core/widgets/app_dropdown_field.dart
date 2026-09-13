import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// حقل القائمة المنسدلة الموحد للمنظومة
class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const AppDropdownField({
    super.key,
    this.label,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.inputText,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconMd,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: prefixIcon,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space12,
            ),
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppDimensions.borderRadius,
              borderSide: BorderSide(
                color: AppColors.border,
                width: AppDimensions.borderWidth,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppDimensions.borderRadius,
              borderSide: BorderSide(
                color: AppColors.borderFocused,
                width: AppDimensions.borderWidthThick,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppDimensions.borderRadius,
              borderSide: BorderSide(
                color: AppColors.debit,
                width: AppDimensions.borderWidth,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppDimensions.borderRadius,
              borderSide: BorderSide(
                color: AppColors.debit,
                width: AppDimensions.borderWidthThick,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
