import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/currency_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/currency_model.dart';

/// نافذة منبثقة لإضافة عملة مالية جديدة
class AddCurrencyDialog extends StatefulWidget {
  final CurrencyModel? currencyToEdit;

  const AddCurrencyDialog({super.key, this.currencyToEdit});

  static Future<CurrencyModel?> show(BuildContext context, {CurrencyModel? currencyToEdit}) {
    return showDialog<CurrencyModel>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AddCurrencyDialog(currencyToEdit: currencyToEdit),
        ),
      ),
    );
  }

  @override
  State<AddCurrencyDialog> createState() => _AddCurrencyDialogState();
}

class _AddCurrencyDialogState extends State<AddCurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _codeController;
  late bool _isDefault;
  bool _isLoading = false;

  bool get _isEditing => widget.currencyToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currencyToEdit?.name ?? '');
    _symbolController = TextEditingController(text: widget.currencyToEdit?.symbol ?? '');
    _codeController = TextEditingController(text: widget.currencyToEdit?.code ?? '');
    _isDefault = widget.currencyToEdit?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currencyController = context.read<CurrencyController>();

    if (_isEditing) {
      final success = await currencyController.updateCurrency(
        id: widget.currencyToEdit!.id,
        name: _nameController.text,
        symbol: _symbolController.text,
        code: _codeController.text,
        isDefault: _isDefault,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currencyController.errorMessage ?? 'فشل في تعديل العملة'),
              backgroundColor: AppColors.debit,
            ),
          );
        }
      }
    } else {
      final newCurrency = await currencyController.addCurrency(
        name: _nameController.text,
        symbol: _symbolController.text,
        code: _codeController.text,
        isDefault: _isDefault,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (newCurrency != null) {
          Navigator.of(context).pop(newCurrency);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currencyController.errorMessage ?? 'فشل في إضافة العملة'),
              backgroundColor: AppColors.debit,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.paddingDialog,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'تعديل بيانات العملة' : 'إضافة عملة جديدة',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // اسم العملة
            AppTextField(
              label: 'اسم العملة *',
              hintText: 'مثال: ريال سعودي، يورو...',
              controller: _nameController,
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم العملة';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.space12),

            // رمز العملة وكود العملة
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'رمز العملة *',
                    hintText: 'مثال: ر.س، €...',
                    controller: _symbolController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال الرمز';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: AppTextField(
                    label: 'كود العملة (ISO) *',
                    hintText: 'مثال: SAR، EUR...',
                    controller: _codeController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'يرجى إدخال الكود';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),

            // خيار تعيين كعملة افتراضية
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'تعيين كعملة افتراضية للنظام',
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'تُستخدم كمرجع أساسي للأسعار والتقارير المالية',
                style: TextStyle(fontSize: 11.0, color: AppColors.textSecondary),
              ),
              value: _isDefault,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _isDefault = val);
              },
            ),

            const SizedBox(height: AppDimensions.space20),

            // أزرار الحفظ والإلغاء
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    text: 'إلغاء',
                    height: AppDimensions.buttonHeight,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: AppPrimaryButton(
                    text: _isEditing ? 'حفظ التعديلات' : 'إضافة العملة',
                    isLoading: _isLoading,
                    height: AppDimensions.buttonHeight,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
