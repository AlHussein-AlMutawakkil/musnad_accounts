import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_account_tile.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_kpi_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_transaction_tile.dart';
import '../../models/transaction_model.dart';
import '../accounts/account_statement_view.dart';
import '../accounts/add_account_dialog.dart';
import '../transactions/add_transaction_view.dart';
import '../transfers/transfer_view.dart';

/// الشاشة الرئيسية ولوحة المؤشرات المركزية (Dashboard View)
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final currCtrl = context.read<CurrencyController>();
    final catCtrl = context.read<CategoryController>();
    final accCtrl = context.read<AccountController>();
    final txCtrl = context.read<TransactionController>();

    await Future.wait([
      currCtrl.loadCurrencies(),
      catCtrl.loadCategories(),
      accCtrl.loadAccounts(),
      txCtrl.loadRecentTransactions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final accountController = context.watch<AccountController>();
    final transactionController = context.watch<TransactionController>();

    final currencies = currencyController.currencies;
    final selectedCurrency = currencyController.selectedCurrency ?? currencyController.defaultCurrency;
    final currencyId = selectedCurrency?.id ?? '';
    final currencySymbol = selectedCurrency?.symbol ?? '';

    // جلب مؤشرات العملة النشطة
    final kpis = accountController.getKpisForCurrency(currencyId);
    final totalCredit = kpis['credit'] ?? 0.0;
    final totalDebit = kpis['debit'] ?? 0.0;
    final netBalance = kpis['net'] ?? 0.0;

    final filteredAccounts = accountController.filteredAccounts;
    final categories = accountController.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مُسند - الحسابات والديون'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'إضافة حساب جديد',
            onPressed: () async {
              await AddAccountDialog.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_alt_rounded),
            tooltip: 'تحويل ومصارفة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TransferView()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppDimensions.paddingScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. شريط العملات
                      if (currencies.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: currencies.map((curr) {
                              final isSelected = curr.id == selectedCurrency?.id;
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
                                  onSelected: (selected) {
                                    if (selected) {
                                      currencyController.selectCurrency(curr);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: AppDimensions.space12),

                      // 2. بطاقات الـ KPIs الرئيسية للمؤشرات المالية
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
                              title: 'الصافي',
                              amount: netBalance,
                              currencySymbol: currencySymbol,
                              type: netBalance >= 0 ? KpiType.credit : KpiType.debit,
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // 3. أزرار الإجراءات السريعة
                      Row(
                        children: [
                          Expanded(
                            child: AppPrimaryButton(
                              text: 'قيد (له)',
                              backgroundColor: AppColors.credit,
                              icon: Icons.add_circle_outline,
                              height: AppDimensions.buttonHeightSm,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddTransactionView(
                                      initialType: TransactionType.credit,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Expanded(
                            child: AppPrimaryButton(
                              text: 'قيد (عليه)',
                              backgroundColor: AppColors.debit,
                              icon: Icons.remove_circle_outline,
                              height: AppDimensions.buttonHeightSm,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddTransactionView(
                                      initialType: TransactionType.debit,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Expanded(
                            child: AppSecondaryButton(
                              text: 'تحويل',
                              icon: Icons.swap_horiz,
                              height: AppDimensions.buttonHeightSm,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TransferView(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. التبويبات (قائمة الحسابات | أحدث القيود)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3.0,
                    tabs: const [
                      Tab(text: 'الحسابات والأطراف'),
                      Tab(text: 'أحدث الحركات المسجلة'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // تبويب الحسابات
              Padding(
                padding: AppDimensions.paddingScreen,
                child: Column(
                  children: [
                    // حقل البحث
                    AppTextField(
                      hintText: 'البحث عن طرف بالاسم أو الهاتف...',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search, size: AppDimensions.iconSm),
                      onChanged: (val) {
                        accountController.setSearchQuery(val);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space8),

                    // فلاتر التصنيف
                    if (categories.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: AppDimensions.space8),
                              child: FilterChip(
                                label: const Text('الكل'),
                                selected: accountController.selectedCategoryId == null,
                                onSelected: (_) => accountController.setCategoryFilter(null),
                                selectedColor: AppColors.primaryLight,
                                labelStyle: TextStyle(
                                  color: accountController.selectedCategoryId == null
                                      ? AppColors.textOnPrimary
                                      : AppColors.textPrimary,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            ...categories.map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(left: AppDimensions.space8),
                                child: FilterChip(
                                  label: Text(cat.name),
                                  selected: accountController.selectedCategoryId == cat.id,
                                  onSelected: (_) => accountController.setCategoryFilter(cat.id),
                                  selectedColor: AppColors.primaryLight,
                                  labelStyle: TextStyle(
                                    color: accountController.selectedCategoryId == cat.id
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppDimensions.space8),

                    // قائمة الحسابات
                    Expanded(
                      child: filteredAccounts.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد حسابات مطابقة',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredAccounts.length,
                              itemBuilder: (context, index) {
                                final account = filteredAccounts[index];
                                final categoryName = accountController.getCategoryName(account.categoryId);
                                final balances = accountController.getBalancesMapForAccount(account.id, currencies);

                                return AppAccountTile(
                                  name: account.name,
                                  phone: account.phone,
                                  categoryName: categoryName,
                                  balancesByCurrency: balances,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AccountStatementView(account: account),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // تبويب أحدث القيود
              Padding(
                padding: AppDimensions.paddingScreen,
                child: transactionController.recentTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد حركات مسجلة بعد',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactionController.recentTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactionController.recentTransactions[index];
                          final curr = currencyController.getCurrencyById(tx.currencyId);

                          return AppTransactionTile(
                            type: tx.type,
                            amount: tx.amount,
                            currencySymbol: curr?.symbol ?? '',
                            details: tx.details,
                            date: tx.date,
                            isTransfer: tx.isTransfer,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'تسجيل قيد سريع',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionView(),
            ),
          );
        },
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
