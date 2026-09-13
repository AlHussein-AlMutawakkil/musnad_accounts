import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../categories/categories_view.dart';
import '../currencies/currencies_view.dart';

/// شاشة المزيد والإعدادات المركزية (More / Settings View)
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final categoryController = context.watch<CategoryController>();
    final accountController = context.watch<AccountController>();
    final transactionController = context.watch<TransactionController>();
    final transferController = context.watch<TransferController>();

    final currenciesCount = currencyController.currencies.length;
    final defaultCurrencyName = currencyController.defaultCurrency?.name ?? 'غير محددة';
    final categoriesCount = categoryController.categories.length;
    final accountsCount = accountController.accounts.length;
    final transactionsCount = transactionController.recentTransactions.length;
    final transfersCount = transferController.transfers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المزيد والإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: AppDimensions.paddingScreen,
        children: [
          // بطاقة ملف المنشأة / النظام
          AppCard(
            padding: AppDimensions.paddingCard,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppDimensions.borderRadius,
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('مُسند المحاسبي', style: AppTextStyles.h3),
                      const SizedBox(height: AppDimensions.space2),
                      Text(
                        'إدارة الحسابات والديون والعملات المتعددة',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // 1. قسم إعدادات العملة
          _buildSectionHeader(title: 'إعدادات العملة والأسعار', icon: Icons.currency_exchange),
          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.payments_outlined,
            title: 'إدارة العملات',
            subtitle: '$currenciesCount عملات مسجلة في النظام',
            badge: '$currenciesCount',
            badgeColor: AppColors.primaryLight,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CurrenciesView()),
              );
            },
          ),

          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.star_border_rounded,
            title: 'العملة الافتراضية للنظام',
            subtitle: 'العملة الحالية: $defaultCurrencyName',
            badge: currencyController.defaultCurrency?.code ?? '',
            badgeColor: AppColors.creditLight,
            badgeTextColor: AppColors.credit,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CurrenciesView()),
              );
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // 2. قسم التصنيفات والأنواع
          _buildSectionHeader(title: 'التصنيفات والأنواع', icon: Icons.category_outlined),
          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.folder_open_outlined,
            title: 'إدارة التصنيفات المالية',
            subtitle: '$categoriesCount تصنيف نشط (عملاء، موردين، مصاريف...)',
            badge: '$categoriesCount',
            badgeColor: AppColors.primaryLight,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CategoriesView()),
              );
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // 3. قسم النسخ الاحتياطي والبيانات
          _buildSectionHeader(title: 'النسخ الاحتياطي والبيانات', icon: Icons.storage_outlined),
          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.cloud_upload_outlined,
            title: 'تصدير نسخة احتياطية',
            subtitle: 'حفظ قاعدة البيانات محلياً ($accountsCount حساب، $transactionsCount حركة)',
            onTap: () => _showUnderDevelopment(context),
          ),

          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.cloud_download_outlined,
            title: 'استيراد نسخة احتياطية',
            subtitle: 'استعادة القيود والحسابات من ملف محفوظ سابقاً',
            onTap: () => _showUnderDevelopment(context),
          ),

          const SizedBox(height: AppDimensions.space8),

          _buildSettingItem(
            icon: Icons.refresh_rounded,
            title: 'تحديث ومزامنة البيانات المحلية',
            subtitle: 'إعادة قراءة الحسابات والمؤشرات التراكمية من الذاكرة',
            onTap: () async {
              await Future.wait([
                currencyController.loadCurrencies(),
                categoryController.loadCategories(),
                accountController.loadAccounts(),
                transactionController.loadRecentTransactions(),
                transferController.loadTransfers(),
              ]);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث البيانات بنجاح'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // 4. قسم حول التطبيق
          _buildSectionHeader(title: 'حول التطبيق والمساعدة', icon: Icons.info_outline),
          const SizedBox(height: AppDimensions.space8),

          AppCard(
            padding: AppDimensions.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإصدار', style: AppTextStyles.bodyMediumBold),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                        vertical: AppDimensions.space2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppDimensions.borderRadiusSm,
                      ),
                      child: Text(
                        'v1.0.0 (Enterprise)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppDimensions.space16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('نوع التخزين', style: AppTextStyles.bodyMedium),
                    Text('محلي مشفر (SQLite Offline-First)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي العمليات المسجلة', style: AppTextStyles.bodyMedium),
                    Text('${transactionsCount + transfersCount} حركة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppDimensions.space8),
          Text(
            title,
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: AppDimensions.borderRadiusSm,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMediumBold),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (badge != null && badge.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space8,
                vertical: AppDimensions.space2,
              ),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.primaryLight,
                borderRadius: AppDimensions.borderRadiusSm,
              ),
              child: Text(
                badge,
                style: AppTextStyles.caption.copyWith(
                  color: badgeTextColor ?? AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
          ],
          const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showUnderDevelopment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('هذه الميزة قيد التطوير حالياً'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
