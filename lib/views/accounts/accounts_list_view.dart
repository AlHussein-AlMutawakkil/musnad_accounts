import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_account_tile.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import 'account_statement_view.dart';
import 'add_account_dialog.dart';

/// شاشة إدارة الحسابات والأطراف المالية (Accounts & Parties View)
class AccountsListView extends StatefulWidget {
  const AccountsListView({super.key});

  @override
  State<AccountsListView> createState() => _AccountsListViewState();
}

class _AccountsListViewState extends State<AccountsListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountController = context.watch<AccountController>();
    final currencyController = context.watch<CurrencyController>();

    final accounts = accountController.filteredAccounts;
    final categories = accountController.categories;
    final currencies = currencyController.currencies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الحسابات والأطراف'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'إضافة طرف جديد',
            onPressed: () => AddAccountDialog.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلترة
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  hintText: 'البحث عن طرف بالاسم أو رقم الهاتف...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search, size: AppDimensions.iconSm),
                  onChanged: (val) {
                    accountController.setSearchQuery(val);
                  },
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space8),
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
                ],
              ],
            ),
          ),

          // قائمة الحسابات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => accountController.loadAccounts(),
              child: accounts.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد حسابات مطابقة',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: AppDimensions.paddingScreen,
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
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
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'إضافة حساب جديد',
        onPressed: () => AddAccountDialog.show(context),
      ),
    );
  }
}
