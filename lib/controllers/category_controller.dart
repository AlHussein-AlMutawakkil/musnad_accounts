import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/category_model.dart';

/// وحدة التحكم وإدارة التصنيفات المالية (Category Controller)
class CategoryController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل كافة التصنيفات غير المحذوفة
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );

      _categories = maps.map((m) => CategoryModel.fromMap(m)).toList();
    } catch (e) {
      _errorMessage = 'فشل في تحميل التصنيفات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث عن تصنيف بالمعرف
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  /// إضافة تصنيف مالي جديد مع التحقق من عدم تكرار الاسم
  Future<CategoryModel?> addCategory({
    required String name,
    String? colorHex,
    String? iconName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanName = name.trim();

      // التحقق من عدم التكرار
      if (_categories.any((c) => c.name.toLowerCase() == cleanName.toLowerCase())) {
        _errorMessage = 'التصنيف ($cleanName) موجود مسبقاً';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      final String newId = _uuid.v4();

      final CategoryModel newCat = CategoryModel(
        id: newId,
        name: cleanName,
        colorHex: colorHex,
        iconName: iconName,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      await db.insert(DatabaseHelper.tableCategories, newCat.toMap());
      await loadCategories();
      return newCat;
    } catch (e) {
      _errorMessage = 'فشل في إضافة التصنيف: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// تعديل تصنيف قائم
  Future<bool> updateCategory({
    required String id,
    required String name,
    String? colorHex,
    String? iconName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanName = name.trim();

      if (_categories.any((c) => c.id != id && c.name.toLowerCase() == cleanName.toLowerCase())) {
        _errorMessage = 'اسم التصنيف ($cleanName) مستخدم بالفعل';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.update(
        DatabaseHelper.tableCategories,
        {
          'name': cleanName,
          'color_hex': colorHex,
          'icon_name': iconName,
          'updated_at': nowUtc,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في تعديل التصنيف: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف ناعم للتصنيف
  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.update(
        DatabaseHelper.tableCategories,
        {
          'deleted_at': nowUtc,
          'updated_at': nowUtc,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [categoryId],
      );

      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حذف التصنيف: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
