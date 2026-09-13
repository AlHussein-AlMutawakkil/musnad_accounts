import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_kpi_card.dart';

/// شاشة التقارير المالية والملخصات التحليلية (Reports View)
class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String? _selectedCurrencyId;

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final accountController = context.watch<AccountController>();
    final transactionController = context.watch<TransactionController>();
    final transferController = context.watch<TransferController>();

    final currencies = currencyController.currencies;
    final selectedCurrency = _selectedCurrencyId != null
        ? currencyController.getCurrencyById(_selectedCurrencyId!)
        : (currencyController.selectedCurrency ?? currencyController.defaultCurrency);
    final currencyId = selectedCurrency?.id ?? '';
    final currencySymbol = selectedCurrency?.symbol ?? '';

    // مؤشرات العملة المحددة
    final kpis = accountController.getKpisForCurrency(currencyId);
    final totalCredit = kpis['credit'] ?? 0.0;
    final totalDebit = kpis['debit'] ?? 0.0;
    final netBalance = kpis['net'] ?? 0.0;

    // إحصائيات الحسابات
    int creditorsCount = 0;
    int debtorsCount = 0;
    int settledCount = 0;

    for (final acc in accountController.accounts) {
      final balance = accountController.getAccountBalance(acc.id, currencyId);
      if (balance > 0.001) {
        creditorsCount++;
      } else if (balance < -0.001) {
        debtorsCount++;
      } else {
        settledCount++;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التقارير المالية والملخصات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            currencyController.loadCurrencies(),
            accountController.loadAccounts(),
            transactionController.loadRecentTransactions(),
            transferController.loadTransfers(),
          ]);
        },
        child: ListView(
          padding: AppDimensions.paddingScreen,
          children: [
            // شريط اختيار عملة التقرير
            if (currencies.isNotEmpty) ...[
              const Text('اختر عملة التقرير:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.space8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: currencies.map((curr) {
                    final isSelected = curr.id == (selectedCurrency?.id ?? '');
                    return Padding(
                      padding: const EdgeInsets.only(left: AppDimensions.space8),
                      child: ChoiceChip(
                        label: Text('${curr.name} (${curr.symbol})'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.0,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadius,
                          side: BorderSide(color: AppColors.border, width: 1),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCurrencyId = curr.id);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
            ],

            // 1. بطاقات المؤشرات الرئيسية للعملة
            Row(
              children: [
                Expanded(
                  child: AppKpiCard(
                    title: 'إجمالي (له)',
                    amount: totalCredit,
                    currencySymbol: currencySymbol,
                    type: KpiType.credit,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: AppDimensions.space4),
                Expanded(
                  child: AppKpiCard(
                    title: 'إجمالي (عليه)',
                    amount: totalDebit,
                    currencySymbol: currencySymbol,
                    type: KpiType.debit,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: AppDimensions.space4),
                Expanded(
                  child: AppKpiCard(
                    title: 'الصافي العام',
                    amount: netBalance,
                    currencySymbol: currencySymbol,
                    type: netBalance >= 0 ? KpiType.credit : KpiType.debit,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.space16),

            // 2. تحليل وتوزيع الأطراف حسب نوع الرصيد
            AppCard(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: AppDimensions.space8),
                      Text('توزيع أطراف الحسابات', style: AppTextStyles.bodyMediumBold),
                    ],
                  ),
                  const Divider(height: AppDimensions.space16),
                  _buildStatRow(
                    label: 'أطراف دائنة (لهم مبالغ)',
                    count: '$creditorsCount طرف',
                    color: AppColors.credit,
                    icon: Icons.arrow_downward_rounded,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  _buildStatRow(
                    label: 'أطراف مدينة (عليهم التزامات)',
                    count: '$debtorsCount طرف',
                    color: AppColors.debit,
                    icon: Icons.arrow_upward_rounded,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  _buildStatRow(
                    label: 'أطراف مخلّصة (رصيدها صفر)',
                    count: '$settledCount طرف',
                    color: AppColors.textSecondary,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // 3. ملخص كافة العملات في النظام
            AppCard(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.currency_exchange, color: AppColors.primary, size: 20),
                      SizedBox(width: AppDimensions.space8),
                      Text('ملخص الصافي لكافة العملات', style: AppTextStyles.bodyMediumBold),
                    ],
                  ),
                  const Divider(height: AppDimensions.space16),
                  if (currencies.isEmpty)
                    const Text('لا توجد عملات معرفة', style: TextStyle(color: AppColors.textSecondary))
                  else
                    ...currencies.map((curr) {
                      final currKpis = accountController.getKpisForCurrency(curr.id);
                      final cNet = currKpis['net'] ?? 0.0;
                      final isPositive = cNet >= 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(curr.name, style: AppTextStyles.bodyMedium),
                            Text(
                              '${AppFormatters.formatAmount(cNet)} ${curr.symbol}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPositive ? AppColors.credit : AppColors.debit,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space16),

            // 4. حجم النشاط المالي الإجمالي
            AppCard(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.query_stats_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: AppDimensions.space8),
                      Text('نشاط القيود والتحويلات', style: AppTextStyles.bodyMediumBold),
                    ],
                  ),
                  const Divider(height: AppDimensions.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي حركات القيود المسجلة:', style: AppTextStyles.bodyMedium),
                      Text(
                        '${transactionController.recentTransactions.length} قيد',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي عمليات المصارفة والتحويل:', style: AppTextStyles.bodyMedium),
                      Text(
                        '${transferController.transfers.length} عملية',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppDimensions.space8),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
        Text(
          count,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
