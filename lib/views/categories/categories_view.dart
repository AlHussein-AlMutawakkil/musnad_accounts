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

/// شاشة إدارة التصنيفات المالية (Categories View)
class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
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
      case 'business':
        return Icons.business;
      case 'account_balance':
        return Icons.account_balance;
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
      final messenger = ScaffoldMessenger.of(context);
      final controller = context.read<CategoryController>();
      final accController = context.read<AccountController>();
      final success = await controller.deleteCategory(category.id);
      if (success) {
        await accController.loadAccounts();
        messenger.showSnackBar(
          SnackBar(
            content: Text('تم حذف تصنيف ${category.name} بنجاح'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'تعذر حذف التصنيف'),
            backgroundColor: AppColors.debit,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = context.watch<CategoryController>();
    final categories = categoryController.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة التصنيفات المالية'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => categoryController.loadCategories(),
        child: ListView(
          padding: AppDimensions.paddingScreen,
          children: [
            // بطاقة توجيهية عن التصنيفات
            AppCard(
              padding: AppDimensions.paddingCard,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                    child: const Icon(Icons.folder_open_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تنظيم وتبويب الحسابات', style: AppTextStyles.bodyMediumBold),
                        const SizedBox(height: AppDimensions.space2),
                        Text(
                          'تساعد التصنيفات في تصنيف الأطراف والحركات المالية (مثل: عملاء، موردون، شركاء، مصاريف تشغيلية).',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // قائمة التصنيفات
            if (categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.space32),
                  child: Text(
                    'لا توجد تصنيفات مسجلة بعد',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...categories.map((category) {
                final color = _parseColor(category.colorHex);
                final icon = _parseIcon(category.iconName);

                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space10,
                  ),
                  child: Row(
                    children: [
                      // أيقونة ولون التصنيف
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: AppDimensions.borderRadiusSm,
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(icon, size: 22, color: color),
                      ),
                      const SizedBox(width: AppDimensions.space12),

                      // اسم التصنيف
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.name,
                              style: AppTextStyles.bodyMediumBold,
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              'كود اللون: ${category.colorHex}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
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
              }),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'إضافة تصنيف جديد',
        onPressed: () => AddCategoryDialog.show(context),
      ),
    );
  }
}
