import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'app_buttons.dart';

/// حوارات التأكيد الموحدة (Confirmation Dialogs)
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.isDestructive = false,
    required this.onConfirm,
  });

  /// دالة مساعدة لفتح مربع حوار التأكيد
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadius,
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(
        AppDimensions.space20,
        AppDimensions.space20,
        AppDimensions.space20,
        AppDimensions.space8,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space20,
        vertical: AppDimensions.space8,
      ),
      actionsPadding: const EdgeInsets.all(AppDimensions.space16),
      title: Text(
        title,
        style: AppTextStyles.h3,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                text: cancelText,
                height: AppDimensions.buttonHeightSm,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: AppPrimaryButton(
                text: confirmText,
                height: AppDimensions.buttonHeightSm,
                backgroundColor: isDestructive ? AppColors.debit : AppColors.primary,
                onPressed: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ورقة الإجراءات السفلية الموحدة (Bottom Sheet)
class AppBottomSheet {
  AppBottomSheet._();

  /// دالة مساعدة لفتح ورقة سفلية موحدة بتصميم منسجم
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب العلوي
                const SizedBox(height: AppDimensions.space8),
                Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                // شريط العنوان وزر الإغلاق
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.h3),
                      if (trailing != null)
                        trailing
                      else
                        IconButton(
                          icon: const Icon(Icons.close, size: AppDimensions.iconSm),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ),
                const Divider(height: AppDimensions.space16, color: AppColors.divider),
                // المحتوى الداخلي
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
