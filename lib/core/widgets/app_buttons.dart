import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

/// الزر الأساسي المعتمد في المنظومة (Primary Button)
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
    this.height = AppDimensions.buttonHeight,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: effectiveBgColor.withOpacity(0.5),
          disabledForegroundColor: AppColors.textOnPrimary.withOpacity(0.7),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSm),
                    const SizedBox(width: AppDimensions.space4),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.button,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// الزر الثانوي أو زر الإلغاء (Secondary Button)
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? textColor;
  final Color? borderColor;

  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = AppDimensions.buttonHeight,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.primary;
    final effectiveBorderColor = borderColor ?? AppColors.border;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          backgroundColor: AppColors.surface,
          elevation: 0,
          side: BorderSide(
            color: effectiveBorderColor,
            width: AppDimensions.borderWidth,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimensions.iconSm, color: effectiveTextColor),
              const SizedBox(width: AppDimensions.space4),
            ],
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.buttonSecondary.copyWith(
                  color: effectiveTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر العمل الإجرائي العائم لإضافة قيد سريع (Floating Action Button)
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  final IconData icon;
  final Object? heroTag;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.icon = Icons.add,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadius,
      ),
      child: Icon(icon, size: AppDimensions.iconMd),
    );
  }
}
