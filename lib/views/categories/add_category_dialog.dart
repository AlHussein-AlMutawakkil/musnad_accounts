import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/category_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/category_model.dart';

/// نافذة منبثقة لإضافة أو تعديل تصنيف مالي
class AddCategoryDialog extends StatefulWidget {
  final CategoryModel? categoryToEdit;

  const AddCategoryDialog({super.key, this.categoryToEdit});

  static Future<CategoryModel?> show(BuildContext context, {CategoryModel? categoryToEdit}) {
    return showDialog<CategoryModel>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadius,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AddCategoryDialog(categoryToEdit: categoryToEdit),
        ),
      ),
    );
  }

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedColorHex;
  late String _selectedIconName;
  bool _isLoading = false;

  bool get _isEditing => widget.categoryToEdit != null;

  static const List<String> _availableColors = [
    '#1B365D', // كحلي أساسي
    '#1B873F', // أخضر دائن
    '#C5221F', // أحمر مدين
    '#E37400', // برتقالي تحذيري
    '#7B1FA2', // بنفسجي
    '#0097A7', // فيروزي
    '#5D4037', // بني
    '#455A64', // رمادي داكن
  ];

  static const List<Map<String, dynamic>> _availableIcons = [
    {'name': 'person', 'icon': Icons.person},
    {'name': 'local_shipping', 'icon': Icons.local_shipping},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'receipt', 'icon': Icons.receipt_long},
    {'name': 'store', 'icon': Icons.store},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'category', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
    _selectedColorHex = widget.categoryToEdit?.colorHex ?? _availableColors.first;
    _selectedIconName = widget.categoryToEdit?.iconName ?? _availableIcons.first['name'] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final categoryController = context.read<CategoryController>();

    if (_isEditing) {
      final success = await categoryController.updateCategory(
        id: widget.categoryToEdit!.id,
        name: _nameController.text,
        colorHex: _selectedColorHex,
        iconName: _selectedIconName,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.read<AccountController>().loadAccounts();
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(categoryController.errorMessage ?? 'فشل في تعديل التصنيف'),
              backgroundColor: AppColors.debit,
            ),
          );
        }
      }
    } else {
      final newCategory = await categoryController.addCategory(
        name: _nameController.text,
        colorHex: _selectedColorHex,
        iconName: _selectedIconName,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (newCategory != null) {
          context.read<AccountController>().loadAccounts();
          Navigator.of(context).pop(newCategory);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(categoryController.errorMessage ?? 'فشل في إضافة التصنيف'),
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
              _isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // اسم التصنيف
            AppTextField(
              label: 'اسم التصنيف *',
              hintText: 'مثال: مشتريات، إيجارات، ديون شخصية...',
              controller: _nameController,
              autofocus: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم التصنيف';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.space12),

            // اختيار اللون
            const Text(
              'لون التصنيف المميز',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableColors.map((hex) {
                final isSelected = hex == _selectedColorHex;
                final color = _parseColor(hex);
                return InkWell(
                  onTap: () => setState(() => _selectedColorHex = hex),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space12),

            // اختيار الأيقونة
            const Text(
              'أيقونة التصنيف',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableIcons.map((item) {
                final isSelected = item['name'] == _selectedIconName;
                return InkWell(
                  onTap: () => setState(() => _selectedIconName = item['name'] as String),
                  borderRadius: AppDimensions.borderRadiusSm,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: AppDimensions.borderRadiusSm,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
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
                    text: _isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف',
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
