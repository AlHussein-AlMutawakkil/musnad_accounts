import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// حقل إدخال المبالغ المالية مع إظهار رمز العملة وخيارات التلوين المحاسبي
class AppAmountField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? currencySymbol;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool autofocus;
  final Color? amountColor;

  const AppAmountField({
    super.key,
    this.label,
    this.hintText = '0.00',
    this.controller,
    this.currencySymbol,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.amountColor,
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
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: autofocus,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
          ],
          style: AppTextStyles.amountLarge.copyWith(
            color: amountColor ?? AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textHint,
            ),
            suffixIcon: currencySymbol != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
                    child: Center(
                      widthFactor: 1.0,
                      child: Text(
                        currencySymbol!,
                        style: AppTextStyles.currencySymbol.copyWith(
                          fontSize: 14.0,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : null,
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
