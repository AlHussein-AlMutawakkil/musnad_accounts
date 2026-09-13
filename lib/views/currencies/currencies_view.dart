import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/currency_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../models/currency_model.dart';
import 'add_currency_dialog.dart';

/// شاشة إدارة العملات المالية (Currencies View)
class CurrenciesView extends StatelessWidget {
  const CurrenciesView({super.key});

  Future<void> _deleteCurrency(BuildContext context, CurrencyModel currency) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'تأكيد حذف العملة',
      message: 'هل أنت متأكد من رغبتك في حذف عملة (${currency.name} - ${currency.code})؟ لن يمكن التراجع في حال وجود حركات مسجلة بها.',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = context.read<CurrencyController>();
      final success = await controller.deleteCurrency(currency.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف عملة ${currency.name} بنجاح'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage ?? 'تعذر حذف العملة'),
              backgroundColor: AppColors.debit,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final currencies = currencyController.currencies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة العملات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => currencyController.loadCurrencies(),
        child: ListView(
          padding: AppDimensions.paddingScreen,
          children: [
            // بطاقة توجيهية عن العملة الافتراضية
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
                    child: const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('العملة الافتراضية للنظام', style: AppTextStyles.bodyMediumBold),
                        const SizedBox(height: AppDimensions.space2),
                        Text(
                          'تُستخدم العملة الافتراضية كأساس رئيسي لعرض الأرصدة العامة وإجراء عمليات التحويل والمصارفة.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // قائمة العملات
            if (currencies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.space32),
                  child: Text(
                    'لا توجد عملات مسجلة بعد',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...currencies.map((currency) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space10,
                  ),
                  child: Row(
                    children: [
                      // شارة رمز العملة
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: currency.isDefault ? AppColors.primary : AppColors.background,
                          borderRadius: AppDimensions.borderRadiusSm,
                          border: Border.all(
                            color: currency.isDefault ? AppColors.primary : AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            color: currency.isDefault ? AppColors.textOnPrimary : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),

                      // اسم وكود العملة وحالة الافتراضية
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currency.name,
                                  style: AppTextStyles.bodyMediumBold,
                                ),
                                if (currency.isDefault) ...[
                                  const SizedBox(width: AppDimensions.space8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.space8,
                                      vertical: AppDimensions.space2,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.creditLight,
                                      borderRadius: AppDimensions.borderRadiusSm,
                                    ),
                                    child: Text(
                                      'افتراضية',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.credit,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              'كود العملة: ${currency.code}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // إجراءات
                      if (!currency.isDefault)
                        TextButton(
                          onPressed: () async {
                            final success = await currencyController.setDefaultCurrency(currency.id);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تعيين ${currency.name} كعملة افتراضية'),
                                  backgroundColor: AppColors.credit,
                                ),
                              );
                            }
                          },
                          child: const Text('تعيين كافتراضية', style: TextStyle(fontSize: 11)),
                        ),

                      // تعديل
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: AppColors.textSecondary,
                        tooltip: 'تعديل',
                        onPressed: () {
                          AddCurrencyDialog.show(context, currencyToEdit: currency);
                        },
                      ),

                      // حذف (فقط إذا لم تكن افتراضية)
                      if (!currency.isDefault)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.debit,
                          tooltip: 'حذف',
                          onPressed: () => _deleteCurrency(context, currency),
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
        tooltip: 'إضافة عملة جديدة',
        onPressed: () => AddCurrencyDialog.show(context),
      ),
    );
  }
}
