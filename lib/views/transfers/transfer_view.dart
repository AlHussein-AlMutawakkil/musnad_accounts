import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/currency_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_amount_field.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_date_picker_field.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';

/// اتجاه العملية الحسابية في المصارفة (ضرب أو قسمة)
enum ExchangeDirection {
  divide,   // قسمة: المبلغ المستلم = المبلغ المرسل ÷ سعر الصرف
  multiply, // ضرب: المبلغ المستلم = المبلغ المرسل × سعر الصرف
}

/// شاشة التحويل المالي والمصارفة بين العملات (Transfer & Exchange View)
class TransferView extends StatefulWidget {
  final String? initialFromAccountId;

  const TransferView({super.key, this.initialFromAccountId});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  final _formKey = GlobalKey<FormState>();
  final _fromAmountController = TextEditingController();
  final _toAmountController = TextEditingController();
  final _rateController = TextEditingController(text: '1.0');
  final _notesController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  String? _fromCurrencyId;
  String? _toCurrencyId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  // اتجاه العملية الحسابية للمصارفة
  ExchangeDirection _exchangeDirection = ExchangeDirection.divide;

  bool get _isExchange =>
      _fromCurrencyId != null &&
      _toCurrencyId != null &&
      _fromCurrencyId != _toCurrencyId;

  @override
  void initState() {
    super.initState();
    _fromAccountId = widget.initialFromAccountId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyController = context.read<CurrencyController>();
      final defaultCurr = currencyController.defaultCurrency ??
          (currencyController.currencies.isNotEmpty ? currencyController.currencies.first : null);

      if (defaultCurr != null) {
        setState(() {
          _fromCurrencyId = defaultCurr.id;
          _toCurrencyId = defaultCurr.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _fromAmountController.dispose();
    _toAmountController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// التحديد التلقائي لاتجاه المصارفة بناءً على العملة المرجعية الأساسية
  void _autoDetectDirection() {
    if (!_isExchange) return;
    final currCtrl = context.read<CurrencyController>();
    final fromCurr = currCtrl.getCurrencyById(_fromCurrencyId ?? '');
    final toCurr = currCtrl.getCurrencyById(_toCurrencyId ?? '');

    if (fromCurr == null || toCurr == null) return;

    // من عملة محلية أساسية (مثل ريال يمني) إلى عملة أجنبية (مثل دولار) -> قسمة (YER ÷ 535 = USD)
    if (fromCurr.isDefault && !toCurr.isDefault) {
      _exchangeDirection = ExchangeDirection.divide;
    }
    // من عملة أجنبية (مثل دولار) إلى عملة محلية أساسية (مثل ريال يمني) -> ضرب (USD × 535 = YER)
    else if (!fromCurr.isDefault && toCurr.isDefault) {
      _exchangeDirection = ExchangeDirection.multiply;
    }

    _recalculateToAmount();
  }

  /// إعادة حساب المبلغ المستلم بناءً على المبلغ المرسل وسعر الصرف واتجاه العملية
  void _recalculateToAmount() {
    if (!_isExchange) {
      _toAmountController.text = _fromAmountController.text;
      return;
    }

    final fromAmount = double.tryParse(_fromAmountController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;

    // الحماية الصارمة من القسمة على صفر أو القيم السالبة وغير المعرفة
    if (rate <= 0 || fromAmount <= 0) {
      if (fromAmount <= 0) {
        _toAmountController.text = '';
      }
      return;
    }

    double calculatedToAmount;
    if (_exchangeDirection == ExchangeDirection.divide) {
      calculatedToAmount = fromAmount / rate;
    } else {
      calculatedToAmount = fromAmount * rate;
    }

    // تقريب الناتج إلى منزلتين عشريتين
    _toAmountController.text = calculatedToAmount.toStringAsFixed(2);
  }

  void _onFromAmountChanged(String val) {
    _recalculateToAmount();
  }

  void _onRateChanged(String val) {
    _recalculateToAmount();
  }

  /// احتساب سعر الصرف العكسي عند تعديل المبلغ المستلم يدوياً
  void _onToAmountChanged(String val) {
    if (!_isExchange) {
      _fromAmountController.text = val;
      return;
    }

    final toAmount = double.tryParse(val.trim()) ?? 0.0;
    final fromAmount = double.tryParse(_fromAmountController.text.trim()) ?? 0.0;
    if (toAmount <= 0 || fromAmount <= 0) return;

    double impliedRate;
    if (_exchangeDirection == ExchangeDirection.divide) {
      impliedRate = fromAmount / toAmount;
    } else {
      impliedRate = toAmount / fromAmount;
    }

    if (impliedRate > 0) {
      _rateController.text = impliedRate.toStringAsFixed(impliedRate >= 10 ? 2 : 4);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد طرفي التحويل (المحوّل منه والمستلم)')),
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن التحويل لنفس الحساب')),
      );
      return;
    }

    final fromAmount = double.tryParse(_fromAmountController.text.trim()) ?? 0.0;
    final toAmount = double.tryParse(_toAmountController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 1.0;

    if (fromAmount <= 0 || toAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبالغ صحيحة أكبر من الصفر')),
      );
      return;
    }

    if (_isExchange && rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سعر الصرف يجب أن يكون أكبر من الصفر')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final accountController = context.read<AccountController>();
    final currencyController = context.read<CurrencyController>();
    final transferController = context.read<TransferController>();

    final fromAccount = accountController.accounts.firstWhere((a) => a.id == _fromAccountId);
    final toAccount = accountController.accounts.firstWhere((a) => a.id == _toAccountId);

    final fromCurrency = currencyController.getCurrencyById(_fromCurrencyId!);
    final toCurrency = currencyController.getCurrencyById(_toCurrencyId!);

    // ضبط المبالغ بدقة منزلتين عشريتين
    final cleanFromAmount = double.parse(fromAmount.toStringAsFixed(2));
    final cleanToAmount = double.parse(toAmount.toStringAsFixed(2));
    final cleanRate = double.parse(rate.toStringAsFixed(4));

    final result = await transferController.executeExchangeTransfer(
      fromAccountId: _fromAccountId!,
      toAccountId: _toAccountId!,
      fromAccountName: fromAccount.name,
      toAccountName: toAccount.name,
      fromCurrencyId: _fromCurrencyId!,
      toCurrencyId: _toCurrencyId!,
      fromCurrencySymbol: fromCurrency?.symbol ?? '',
      toCurrencySymbol: toCurrency?.symbol ?? '',
      fromAmount: cleanFromAmount,
      toAmount: cleanToAmount,
      exchangeRate: cleanRate,
      date: _selectedDate,
      notes: _notesController.text,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        // تحديث الأرصدة ديناميكياً
        await accountController.loadAccounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تنفيذ التحويل بنجاح')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(transferController.errorMessage ?? 'فشل في تنفيذ التحويل')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountController = context.watch<AccountController>();
    final currencyController = context.watch<CurrencyController>();

    final accounts = accountController.accounts;
    final currencies = currencyController.currencies;

    final fromCurrency = currencyController.getCurrencyById(_fromCurrencyId ?? '');
    final toCurrency = currencyController.getCurrencyById(_toCurrencyId ?? '');

    final fromSymbol = fromCurrency?.symbol ?? '';
    final toSymbol = toCurrency?.symbol ?? '';

    final fromAmountVal = double.tryParse(_fromAmountController.text.trim()) ?? 0.0;
    final toAmountVal = double.tryParse(_toAmountController.text.trim()) ?? 0.0;
    final rateVal = double.tryParse(_rateController.text.trim()) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isExchange ? 'تحويل مع مصارفة عملات' : 'تحويل مالي بين حسابين'),
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
              // 1. بطاقة أطراف التحويل
              AppCard(
                padding: AppDimensions.paddingAll16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أطراف المعاملة',
                      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // الحساب المحول منه (المرسل)
                    AppDropdownField<String?>(
                      label: 'من الحساب (المرسل / عليه) *',
                      hintText: 'اختر الطرف المرسل',
                      value: _fromAccountId,
                      prefixIcon: const Icon(Icons.arrow_upward_rounded, color: AppColors.debit),
                      items: accounts.map((acc) {
                        return DropdownMenuItem<String?>(
                          value: acc.id,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _fromAccountId = val);
                      },
                      validator: (val) => val == null ? 'يرجى اختيار الحساب المرسل' : null,
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // الحساب المحول إليه (المستلم)
                    AppDropdownField<String?>(
                      label: 'إلى الحساب (المستلم / له) *',
                      hintText: 'اختر الطرف المستلم',
                      value: _toAccountId,
                      prefixIcon: const Icon(Icons.arrow_downward_rounded, color: AppColors.credit),
                      items: accounts.map((acc) {
                        return DropdownMenuItem<String?>(
                          value: acc.id,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _toAccountId = val);
                      },
                      validator: (val) {
                        if (val == null) return 'يرجى اختيار الحساب المستلم';
                        if (val == _fromAccountId) return 'لا يمكن التحويل لنفس الحساب';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // 2. بطاقة المبالغ والعملات والمصارفة
              AppCard(
                padding: AppDimensions.paddingAll16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبالغ والعملات',
                      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // عملة الإرسال والمبلغ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppDropdownField<String?>(
                            label: 'عملة الإرسال *',
                            value: _fromCurrencyId,
                            items: currencies.map((c) {
                              return DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.code),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _fromCurrencyId = val;
                                if (!_isExchange) {
                                  _toCurrencyId = val;
                                }
                                _autoDetectDirection();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          flex: 3,
                          child: AppAmountField(
                            label: 'المبلغ المرسل *',
                            controller: _fromAmountController,
                            currencySymbol: fromSymbol,
                            amountColor: AppColors.debit,
                            onChanged: _onFromAmountChanged,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'مطلوب';
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal <= 0) return 'غير صحيح';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space12),

                    // عملة الاستلام والمبلغ المستلم
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppDropdownField<String?>(
                            label: 'عملة الاستلام *',
                            value: _toCurrencyId,
                            items: currencies.map((c) {
                              return DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.code),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _toCurrencyId = val;
                                if (val == _fromCurrencyId) {
                                  _rateController.text = '1.0';
                                  _toAmountController.text = _fromAmountController.text;
                                } else {
                                  _autoDetectDirection();
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          flex: 3,
                          child: AppAmountField(
                            label: 'المبلغ المستلم *',
                            controller: _toAmountController,
                            currencySymbol: toSymbol,
                            amountColor: AppColors.credit,
                            onChanged: _onToAmountChanged,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'مطلوب';
                              final numVal = double.tryParse(val.trim());
                              if (numVal == null || numVal <= 0) return 'غير صحيح';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    // إعدادات سعر الصرف عند اختلاف العملتين
                    if (_isExchange) ...[
                      const SizedBox(height: AppDimensions.space16),

                      // مفتاح التبديل بين القسمة والضرب
                      const Text(
                        'اتجاه العملية الحسابية *',
                        style: AppTextStyles.labelBold,
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Container(
                        height: AppDimensions.buttonHeightSm,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppDimensions.borderRadiusSm,
                          border: Border.all(
                            color: AppColors.border,
                            width: AppDimensions.borderWidth,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppDimensions.space2),
                        child: Row(
                          children: [
                            // خيار القسمة (÷)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _exchangeDirection = ExchangeDirection.divide;
                                    _recalculateToAmount();
                                  });
                                },
                                borderRadius: AppDimensions.borderRadiusSm,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _exchangeDirection == ExchangeDirection.divide
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: AppDimensions.borderRadiusSm,
                                  ),
                                  child: Text(
                                    'قسمة (÷) [المبلغ ÷ السعر]',
                                    style: TextStyle(
                                      color: _exchangeDirection == ExchangeDirection.divide
                                          ? AppColors.textOnPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space2),
                            // خيار الضرب (×)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _exchangeDirection = ExchangeDirection.multiply;
                                    _recalculateToAmount();
                                  });
                                },
                                borderRadius: AppDimensions.borderRadiusSm,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _exchangeDirection == ExchangeDirection.multiply
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: AppDimensions.borderRadiusSm,
                                  ),
                                  child: Text(
                                    'ضرب (×) [المبلغ × السعر]',
                                    style: TextStyle(
                                      color: _exchangeDirection == ExchangeDirection.multiply
                                          ? AppColors.textOnPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // حقل إدخال سعر الصرف
                      AppTextField(
                        label: 'سعر الصرف (المعامل) *',
                        hintText: 'مثال: 535.0',
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: _onRateChanged,
                        prefixIcon: const Icon(
                          Icons.currency_exchange_rounded,
                          size: AppDimensions.iconSm,
                          color: AppColors.primary,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'يرجى إدخال سعر الصرف';
                          final rate = double.tryParse(val.trim());
                          if (rate == null || rate <= 0) return 'سعر الصرف يجب أن يكون أكبر من الصفر';
                          return null;
                        },
                      ),

                      // شريط توضيح المعادلة المحاسبية الحالية
                      if (fromAmountVal > 0 && rateVal > 0) ...[
                        const SizedBox(height: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space12,
                            vertical: AppDimensions.space8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppDimensions.borderRadiusSm,
                            border: Border.all(
                              color: AppColors.border,
                              width: AppDimensions.borderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calculate_outlined,
                                size: AppDimensions.iconSm,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              Expanded(
                                child: Text(
                                  'المعادلة: $fromAmountVal $fromSymbol ${_exchangeDirection == ExchangeDirection.divide ? '÷' : '×'} $rateVal = $toAmountVal $toSymbol',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // 3. التاريخ والملاحظات
              AppCard(
                padding: AppDimensions.paddingAll16,
                child: Column(
                  children: [
                    AppDatePickerField(
                      label: 'تاريخ التحويل *',
                      selectedDate: _selectedDate,
                      onDateChanged: (picked) {
                        setState(() => _selectedDate = picked);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    AppTextField(
                      label: 'ملاحظات العملية (اختياري)',
                      hintText: 'سبب التحويل أو تفاصيل إضافية...',
                      controller: _notesController,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // زر التنفيذ
              AppPrimaryButton(
                text: 'تنفيذ التحويل والمصارفة',
                isLoading: _isSubmitting,
                icon: Icons.sync_alt_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
