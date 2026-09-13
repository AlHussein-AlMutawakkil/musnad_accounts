import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_kpi_card.dart';
import '../../core/widgets/app_transaction_tile.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../transactions/add_transaction_view.dart';
import 'add_account_dialog.dart';

/// شاشة كشف حساب تفصيلي لطرف مالي (Account Statement View)
class AccountStatementView extends StatefulWidget {
  final AccountModel account;

  const AccountStatementView({super.key, required this.account});

  @override
  State<AccountStatementView> createState() => _AccountStatementViewState();
}

class _AccountStatementViewState extends State<AccountStatementView> {
  String? _selectedCurrencyId;
  DateTime? _fromDate;
  DateTime? _toDate;
  TransactionType? _typeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyController = context.read<CurrencyController>();
      final initialCurrId = currencyController.selectedCurrency?.id ??
          currencyController.defaultCurrency?.id;
      setState(() {
        _selectedCurrencyId = initialCurrId;
      });
      _loadStatement();
    });
  }

  void _loadStatement() {
    if (_selectedCurrencyId == null) return;
    context.read<TransactionController>().loadAccountStatement(
      accountId: widget.account.id,
      currencyId: _selectedCurrencyId!,
      fromDate: _fromDate,
      toDate: _toDate,
      typeFilter: _typeFilter,
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadStatement();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _loadStatement();
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'تأكيد حذف القيد',
      message: tx.isTransfer
          ? 'هذا القيد مرتبط بعملية تحويل. حذفه سيؤدي إلى حذف القيد المقابل والعملية بالكامل. هل أنت متأكد؟'
          : 'هل أنت متأكد من رغبتك في حذف هذا القيد؟',
      confirmText: 'حذف',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final txController = context.read<TransactionController>();
      final accController = context.read<AccountController>();
      final success = await txController.deleteTransaction(tx.id);
      if (success) {
        await accController.loadAccounts();
        _loadStatement();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountController = context.watch<AccountController>();
    final currencyController = context.watch<CurrencyController>();
    final transactionController = context.watch<TransactionController>();

    final currencies = currencyController.currencies;
    final selectedCurrency = currencyController.getCurrencyById(_selectedCurrencyId ?? '');
    final currencySymbol = selectedCurrency?.symbol ?? '';

    final entries = transactionController.statementEntries;
    final categoryName = accountController.getCategoryName(widget.account.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.account.name, style: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary)),
            if (categoryName != null)
              Text(
                categoryName,
                style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary.withOpacity(0.8)),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'تعديل بيانات الحساب',
            onPressed: () async {
              await AddAccountDialog.show(context, accountToEdit: widget.account);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await accountController.loadAccounts();
          _loadStatement();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDimensions.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. شريط تبديل العملات
              if (currencies.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: currencies.map((curr) {
                      final isSelected = curr.id == _selectedCurrencyId;
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
                              setState(() => _selectedCurrencyId = curr.id);
                              _loadStatement();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: AppDimensions.space12),

              // 2. مؤشرات ملخص كشف الحساب (له / عليه / الصافي)
              Row(
                children: [
                  Expanded(
                    child: AppKpiCard(
                      title: 'إجمالي (له)',
                      amount: transactionController.statementTotalCredit,
                      currencySymbol: currencySymbol,
                      type: KpiType.credit,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: AppKpiCard(
                      title: 'إجمالي (عليه)',
                      amount: transactionController.statementTotalDebit,
                      currencySymbol: currencySymbol,
                      type: KpiType.debit,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: AppKpiCard(
                      title: 'الصافي',
                      amount: transactionController.statementNetBalance,
                      currencySymbol: currencySymbol,
                      type: transactionController.statementNetBalance >= 0
                          ? KpiType.credit
                          : KpiType.debit,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space12),

              // 3. شريط الفلاتر (التاريخ والنوع)
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space8,
                ),
                child: Row(
                  children: [
                    // زر فلتر التاريخ
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: AppDimensions.borderRadiusSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space8,
                          vertical: AppDimensions.space4,
                        ),
                        decoration: BoxDecoration(
                          color: _fromDate != null ? AppColors.primary : AppColors.background,
                          borderRadius: AppDimensions.borderRadiusSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.date_range,
                              size: AppDimensions.iconSm,
                              color: _fromDate != null ? AppColors.textOnPrimary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppDimensions.space4),
                            Text(
                              _fromDate != null && _toDate != null
                                  ? '${AppFormatters.formatDate(_fromDate!)} - ${AppFormatters.formatDate(_toDate!)}'
                                  : 'كل التواريخ',
                              style: AppTextStyles.caption.copyWith(
                                color: _fromDate != null ? AppColors.textOnPrimary : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_fromDate != null) ...[
                      const SizedBox(width: AppDimensions.space4),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _clearDateFilter,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                    const Spacer(),
                    // تبديل فلتر نوع الحركة (الكل، له، عليه)
                    PopupMenuButton<TransactionType?>(
                      initialValue: _typeFilter,
                      onSelected: (type) {
                        setState(() => _typeFilter = type);
                        _loadStatement();
                      },
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadius,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space8,
                          vertical: AppDimensions.space4,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppDimensions.borderRadiusSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _typeFilter == null
                                  ? 'كل العمليات'
                                  : (_typeFilter == TransactionType.credit ? 'له فقط' : 'عليه فقط'),
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('كل العمليات'),
                        ),
                        const PopupMenuItem(
                          value: TransactionType.credit,
                          child: Text('له (دائن) فقط'),
                        ),
                        const PopupMenuItem(
                          value: TransactionType.debit,
                          child: Text('عليه (مدين) فقط'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // 4. جدول وقائمة الحركات
              if (transactionController.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.space32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.space40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          'لا توجد حركات مسجلة لهذا الحساب بالعملة المحددة',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final tx = entry.transaction;

                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: AppDimensions.space20),
                        color: AppColors.debit,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        await _deleteTransaction(tx);
                        return false;
                      },
                      child: AppTransactionTile(
                        type: tx.type,
                        amount: tx.amount,
                        currencySymbol: currencySymbol,
                        details: tx.details,
                        date: tx.date,
                        isTransfer: tx.isTransfer,
                        runningBalance: entry.runningBalance,
                        onTap: () {
                          // خيارات الحركة
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
                            ),
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline, color: AppColors.debit),
                                    title: const Text('حذف القيد', style: TextStyle(color: AppColors.debit)),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _deleteTransaction(tx);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'إضافة حركة لهذا الحساب',
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => AddTransactionView(
                initialAccountId: widget.account.id,
              ),
            ),
          );
          if (added == true) {
            _loadStatement();
          }
        },
      ),
    );
  }
}
