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

/// نافذة إدارة العملات المالية للنظام
class CurrencyManagementDialog extends StatelessWidget {
  const CurrencyManagementDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: const CurrencyManagementDialog(),
        ),
      ),
    );
  }

  Future<void> _deleteCurrency(BuildContext context, CurrencyModel currency) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'تأكيد حذف العملة',
      message: 'هل أنت متأكد من رغبتك في حذف عملة (${currency.name})؟',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = context.read<CurrencyController>();
      final success = await controller.deleteCurrency(currency.id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'تعذر حذف العملة'),
            backgroundColor: AppColors.debit,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final currencies = currencyController.currencies;

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
                  Icon(Icons.payments_outlined, color: AppColors.primary),
                  SizedBox(width: AppDimensions.space8),
                  Text('إدارة العملات', style: AppTextStyles.h3),
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

          // زر إضافة عملة جديدة
          AppPrimaryButton(
            text: 'إضافة عملة جديدة',
            icon: Icons.add,
            height: AppDimensions.buttonHeightSm,
            onPressed: () => AddCurrencyDialog.show(context),
          ),
          const SizedBox(height: AppDimensions.space12),

          // قائمة العملات
          Flexible(
            child: currencies.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.space24),
                      child: Text(
                        'لا توجد عملات مسجلة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: currencies.length,
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppDimensions.space8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                          vertical: AppDimensions.space8,
                        ),
                        child: Row(
                          children: [
                            // شارة رمز العملة
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: currency.isDefault
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: AppDimensions.borderRadiusSm,
                              ),
                              child: Text(
                                currency.symbol,
                                style: TextStyle(
                                  color: currency.isDefault
                                      ? AppColors.textOnPrimary
                                      : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),

                            // اسم وكود العملة
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
                                  Text(
                                    'كود: ${currency.code}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),

                            // إجراءات العملة
                            if (!currency.isDefault)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  currencyController.setDefaultCurrency(currency.id);
                                },
                                child: const Text(
                                  'تعيين كافتراضية',
                                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                                ),
                              ),

                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: AppColors.textSecondary,
                              tooltip: 'تعديل',
                              onPressed: () {
                                AddCurrencyDialog.show(context, currencyToEdit: currency);
                              },
                            ),

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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
