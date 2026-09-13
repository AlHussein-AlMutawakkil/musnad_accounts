import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_transaction_tile.dart';
import '../../models/transaction_model.dart';
import '../transactions/add_transaction_view.dart';
import '../transfers/transfer_view.dart';

enum OperationFilter {
  all,
  credit,
  debit,
  transfer,
}

/// شاشة العمليات المالية الموحدة (Transactions & Transfers View)
class OperationsView extends StatefulWidget {
  const OperationsView({super.key});

  @override
  State<OperationsView> createState() => _OperationsViewState();
}

class _OperationsViewState extends State<OperationsView> {
  OperationFilter _selectedFilter = OperationFilter.all;
  String? _filterCurrencyId;

  @override
  Widget build(BuildContext context) {
    final currencyController = context.watch<CurrencyController>();
    final transactionController = context.watch<TransactionController>();
    final transferController = context.watch<TransferController>();

    final currencies = currencyController.currencies;
    final transactions = transactionController.recentTransactions;
    final transfers = transferController.transfers;

    // تصفية العمليات
    final filteredTransactions = transactions.where((tx) {
      if (_filterCurrencyId != null && tx.currencyId != _filterCurrencyId) {
        return false;
      }
      switch (_selectedFilter) {
        case OperationFilter.all:
          return true;
        case OperationFilter.credit:
          return tx.type == TransactionType.credit && !tx.isTransfer;
        case OperationFilter.debit:
          return tx.type == TransactionType.debit && !tx.isTransfer;
        case OperationFilter.transfer:
          return tx.isTransfer;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('العمليات والحركات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
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
      body: Column(
        children: [
          // شريط الفلاتر العليا
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: Column(
              children: [
                // فلاتر النوع
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeFilterChip('الكل', OperationFilter.all),
                      const SizedBox(width: AppDimensions.space8),
                      _buildTypeFilterChip('قيود (له)', OperationFilter.credit),
                      const SizedBox(width: AppDimensions.space8),
                      _buildTypeFilterChip('قيود (عليه)', OperationFilter.debit),
                      const SizedBox(width: AppDimensions.space8),
                      _buildTypeFilterChip('التحويلات والمصارفة', OperationFilter.transfer),
                    ],
                  ),
                ),
                // فلاتر العملة
                if (currencies.length > 1) ...[
                  const SizedBox(height: AppDimensions.space8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: AppDimensions.space8),
                          child: ChoiceChip(
                            label: const Text('جميع العملات', style: TextStyle(fontSize: 11)),
                            selected: _filterCurrencyId == null,
                            selectedColor: AppColors.primaryLight,
                            backgroundColor: AppColors.background,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadius,
                              side: BorderSide(color: AppColors.border, width: 1),
                            ),
                            onSelected: (_) => setState(() => _filterCurrencyId = null),
                          ),
                        ),
                        ...currencies.map((curr) {
                          final isSelected = _filterCurrencyId == curr.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: AppDimensions.space8),
                            child: ChoiceChip(
                              label: Text('${curr.name} (${curr.symbol})', style: const TextStyle(fontSize: 11)),
                              selected: isSelected,
                              selectedColor: AppColors.primaryLight,
                              backgroundColor: AppColors.background,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppDimensions.borderRadius,
                                side: BorderSide(color: AppColors.border, width: 1),
                              ),
                              onSelected: (_) => setState(() => _filterCurrencyId = curr.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // قائمة العمليات
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  transactionController.loadRecentTransactions(),
                  transferController.loadTransfers(),
                ]);
              },
              child: _selectedFilter == OperationFilter.transfer
                  ? _buildTransfersList(transfers, currencyController)
                  : _buildTransactionsList(filteredTransactions, currencyController),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'تسجيل حركة جديدة',
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

  Widget _buildTypeFilterChip(String label, OperationFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
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
          setState(() => _selectedFilter = filter);
        }
      },
    );
  }

  Widget _buildTransactionsList(
    List<TransactionModel> list,
    CurrencyController currencyController,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عمليات مطابقة',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: AppDimensions.paddingScreen,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tx = list[index];
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
    );
  }

  Widget _buildTransfersList(
    dynamic transfers,
    CurrencyController currencyController,
  ) {
    if (transfers.isEmpty) {
      return Center(
        child: Text(
          'لا توجد تحويلات مسجلة',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: AppDimensions.paddingScreen,
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final tr = transfers[index];
        final fromCurr = currencyController.getCurrencyById(tr.fromCurrencyId);
        final toCurr = currencyController.getCurrencyById(tr.toCurrencyId);

        return AppCard(
          margin: const EdgeInsets.only(bottom: AppDimensions.space8),
          padding: AppDimensions.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_alt_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        tr.isExchange ? 'عملية مصارفة' : 'تحويل بين حسابين',
                        style: AppTextStyles.bodyMediumBold,
                      ),
                    ],
                  ),
                  Text(
                    AppFormatters.formatDate(tr.date),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: AppDimensions.space12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المبلغ المحول: ${AppFormatters.formatAmount(tr.fromAmount)} ${fromCurr?.symbol ?? ""}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (tr.isExchange)
                    Text(
                      'المستلم: ${AppFormatters.formatAmount(tr.toAmount)} ${toCurr?.symbol ?? ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.credit, fontSize: 13),
                    ),
                ],
              ),
              if (tr.notes != null && tr.notes!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space4),
                Text(
                  tr.notes!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
