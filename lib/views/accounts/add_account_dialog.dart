import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/account_model.dart';

/// نافذة أو ورقة سفلية لإضافة أو تعديل حساب / طرف مالي
class AddAccountDialog extends StatefulWidget {
  final AccountModel? accountToEdit;

  const AddAccountDialog({super.key, this.accountToEdit});

  static Future<AccountModel?> show(BuildContext context, {AccountModel? accountToEdit}) {
    return showDialog<AccountModel>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AddAccountDialog(accountToEdit: accountToEdit),
        ),
      ),
    );
  }

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditing => widget.accountToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.accountToEdit?.name ?? '');
    _phoneController = TextEditingController(text: widget.accountToEdit?.phone ?? '');
    _notesController = TextEditingController(text: widget.accountToEdit?.notes ?? '');
    _selectedCategoryId = widget.accountToEdit?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final accountController = context.read<AccountController>();

    if (_isEditing) {
      final success = await accountController.updateAccount(
        id: widget.accountToEdit!.id,
        name: _nameController.text,
        phone: _phoneController.text,
        notes: _notesController.text,
        categoryId: _selectedCategoryId,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } else {
      final newAccount = await accountController.addAccount(
        name: _nameController.text,
        phone: _phoneController.text,
        notes: _notesController.text,
        categoryId: _selectedCategoryId,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (newAccount != null) {
          Navigator.of(context).pop(newAccount);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountController = context.watch<AccountController>();
    final categories = accountController.categories;

    return Padding(
      padding: AppDimensions.paddingDialog,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'تعديل بيانات الحساب' : 'إضافة حساب / طرف جديد',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            AppTextField(
              label: 'اسم الطرف / الحساب *',
              hintText: 'مثال: محمد عبدالله المحمدي',
              controller: _nameController,
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم الحساب';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.space12),
            AppTextField(
              label: 'رقم الهاتف (اختياري)',
              hintText: 'مثال: 777123456',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.space12),
            AppDropdownField<String?>(
              label: 'التصنيف',
              hintText: 'اختر التصنيف (اختياري)',
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('بدون تصنيف'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedCategoryId = val);
              },
            ),
            const SizedBox(height: AppDimensions.space12),
            AppTextField(
              label: 'ملاحظات (اختياري)',
              hintText: 'أي تفاصيل إضافية عن الحساب...',
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.space20),
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
                    text: _isEditing ? 'حفظ التعديلات' : 'إضافة الحساب',
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
