import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../models/category_model.dart';
import 'add_category_dialog.dart';

/// نافذة إدارة التصنيفات المالية للنظام
class CategoryManagementDialog extends StatelessWidget {
  const CategoryManagementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: const CategoryManagementDialog(),
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'receipt':
        return Icons.receipt_long;
      case 'store':
        return Icons.store;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  Future<void> _deleteCategory(BuildContext context, CategoryModel category) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'تأكيد حذف التصنيف',
      message: 'هل أنت متأكد من رغبتك في حذف تصنيف (${category.name})؟ لن تُحذف الحسابات أو القيود المرتبطة به.',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = context.read<CategoryController>();
      final accController = context.read<AccountController>();
      final success = await controller.deleteCategory(category.id);
      if (success && context.mounted) {
        // تحديث الحسابات لتعكس التغيير
        await accController.loadAccounts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = context.watch<CategoryController>();
    final categories = categoryController.categories;

    return Padding(
      padding: AppDimensions.paddingDialog,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.category_outlined, color: AppColors.primary),
                  SizedBox(width: AppDimensions.space8),
                  Text('إدارة التصنيفات', style: AppTextStyles.h3),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // زر إضافة تصنيف جديد
          AppPrimaryButton(
            text: 'إضافة تصنيف جديد',
            icon: Icons.add,
            height: AppDimensions.buttonHeightSm,
            onPressed: () => AddCategoryDialog.show(context),
          ),
          const SizedBox(height: AppDimensions.space12),

          // قائمة التصنيفات
          Flexible(
            child: categories.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.space24),
                      child: Text(
                        'لا توجد تصنيفات مسجلة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final color = _parseColor(category.colorHex);
                      final icon = _parseIcon(category.iconName);

                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppDimensions.space8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                          vertical: AppDimensions.space8,
                        ),
                        child: Row(
                          children: [
                            // أيقونة التصنيف
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: AppDimensions.borderRadiusSm,
                              ),
                              child: Icon(icon, size: 20, color: color),
                            ),
                            const SizedBox(width: AppDimensions.space12),

                            // اسم التصنيف
                            Expanded(
                              child: Text(
                                category.name,
                                style: AppTextStyles.bodyMediumBold,
                              ),
                            ),

                            // تعديل
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: AppColors.textSecondary,
                              tooltip: 'تعديل',
                              onPressed: () {
                                AddCategoryDialog.show(context, categoryToEdit: category);
                              },
                            ),

                            // حذف
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: AppColors.debit,
                              tooltip: 'حذف',
                              onPressed: () => _deleteCategory(context, category),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
