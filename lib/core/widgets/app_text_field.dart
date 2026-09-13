import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// حقل إدخال نصي موحد مع تسمية علوية وحدود كاملة 1px وزوايا 4px
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
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
          initialValue: initialValue,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          readOnly: readOnly,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          style: AppTextStyles.inputText,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space12,
            ),
            filled: true,
            fillColor: readOnly ? AppColors.background : AppColors.surface,
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
