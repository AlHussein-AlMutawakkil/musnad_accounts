import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_amount_field.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_date_picker_field.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_type_toggle.dart';
import '../../models/transaction_model.dart';
import '../categories/add_category_dialog.dart';

/// شاشة تسجيل قيد / حركة مالية سريعة (له / دائن أو عليه / مدين)
class AddTransactionView extends StatefulWidget {
  final String? initialAccountId;
  final TransactionType initialType;

  const AddTransactionView({
    super.key,
    this.initialAccountId,
    this.initialType = TransactionType.credit,
  });

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();

  late TransactionType _selectedType;
  String? _selectedAccountId;
  String? _selectedCurrencyId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedAccountId = widget.initialAccountId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyController = context.read<CurrencyController>();
      final categoryController = context.read<CategoryController>();

      if (_selectedCurrencyId == null) {
        setState(() {
          _selectedCurrencyId = currencyController.selectedCurrency?.id ??
              currencyController.defaultCurrency?.id;
        });
      }

      categoryController.loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الحساب / الطرف')),
      );
      return;
    }
    if (_selectedCurrencyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار العملة')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح أكبر من الصفر')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final transactionController = context.read<TransactionController>();
    final accountController = context.read<AccountController>();

    final result = await transactionController.addTransaction(
      accountId: _selectedAccountId!,
      currencyId: _selectedCurrencyId!,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      amount: amount,
      details: _detailsController.text,
      date: _selectedDate,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        // تحديث أرصدة الحسابات فوراً
        await accountController.loadAccounts();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(transactionController.errorMessage ?? 'حدث خطأ أثناء الحفظ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountController = context.watch<AccountController>();
    final currencyController = context.watch<CurrencyController>();
    final categoryController = context.watch<CategoryController>();

    final accounts = accountController.accounts;
    final currencies = currencyController.currencies;
    final categories = categoryController.categories;

    final selectedCurrency = currencyController.getCurrencyById(_selectedCurrencyId ?? '');
    final currencySymbol = selectedCurrency?.symbol ?? '';

    final isCredit = _selectedType == TransactionType.credit;
    final themeColor = isCredit ? AppColors.credit : AppColors.debit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تسجيل قيد مالي جديد'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingScreen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. مفتاح نوع الحركة (له / دائن أو عليه / مدين)
              AppTypeToggle(
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() => _selectedType = type);
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // 2. بطاقة بيانات القيد
              AppCard(
                padding: AppDimensions.paddingAll16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // اختيار الطرف
                    AppDropdownField<String?>(
                      label: 'الطرف / الحساب *',
                      hintText: 'اختر الحساب المسجل له القيد',
                      value: _selectedAccountId,
                      items: accounts.map((acc) {
                        return DropdownMenuItem<String?>(
                          value: acc.id,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedAccountId = val);
                      },
                      validator: (val) => val == null ? 'يرجى اختيار الحساب' : null,
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // اختيار العملة والمبلغ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اختيار العملة
                        Expanded(
                          flex: 2,
                          child: AppDropdownField<String?>(
                            label: 'العملة *',
                            hintText: 'العملة',
                            value: _selectedCurrencyId,
                            items: currencies.map((c) {
                              return DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text('${c.name} (${c.symbol})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedCurrencyId = val);
                            },
                            validator: (val) => val == null ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        // إدخال المبلغ
                        Expanded(
                          flex: 3,
                          child: AppAmountField(
                            label: 'المبلغ *',
                            hintText: '0.00',
                            controller: _amountController,
                            currencySymbol: currencySymbol,
                            amountColor: themeColor,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal <= 0) {
                                return 'مبلغ غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // اختيار تصنيف الحركة مع زر إضافة تصنيف جديد سريع
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppDropdownField<String?>(
                            label: 'تصنيف الحركة (اختياري)',
                            hintText: 'اختر تصنيفاً للعملية',
                            value: _selectedCategoryId,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('بدون تصنيف'),
                              ),
                              ...categories.map(
                                (cat) => DropdownMenuItem<String?>(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedCategoryId = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            tooltip: 'إضافة تصنيف جديد',
                            onPressed: () async {
                              final newCat = await AddCategoryDialog.show(context);
                              if (newCat != null) {
                                setState(() => _selectedCategoryId = newCat.id);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // اختيار التاريخ
                    AppDatePickerField(
                      label: 'تاريخ القيد *',
                      selectedDate: _selectedDate,
                      onDateChanged: (picked) {
                        setState(() => _selectedDate = picked);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // تفاصيل وبيان الحركة
                    AppTextField(
                      label: 'البيان والتفاصيل (اختياري)',
                      hintText: isCredit
                          ? 'مثال: دفعة نقدية، تسليم بضاعة...'
                          : 'مثال: سحب نقدي، شراء آجل...',
                      controller: _detailsController,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // زر حفظ القيد
              AppPrimaryButton(
                text: 'حفظ القيد (${_selectedType.label})',
                backgroundColor: themeColor,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
