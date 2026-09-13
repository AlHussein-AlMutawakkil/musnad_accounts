import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/currency_model.dart';

/// وحدة التحكم وإدارة حالة العملات (Currency Controller)
class CurrencyController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<CurrencyModel> _currencies = [];
  CurrencyModel? _selectedCurrency;
  bool _isLoading = false;
  String? _errorMessage;

  List<CurrencyModel> get currencies => _currencies;
  CurrencyModel? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// العملة الافتراضية للنظام (عادة الريال اليمني)
  CurrencyModel? get defaultCurrency {
    try {
      return _currencies.firstWhere((c) => c.isDefault);
    } catch (_) {
      return _currencies.isNotEmpty ? _currencies.first : null;
    }
  }

  /// تحميل كافة العملات النشطة من قاعدة البيانات
  Future<void> loadCurrencies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCurrencies,
        where: 'deleted_at IS NULL',
        orderBy: 'is_default DESC, name ASC',
      );

      _currencies = maps.map((m) => CurrencyModel.fromMap(m)).toList();

      // إذا لم تكن هناك عملة محددة، نختار الافتراضية
      if (_selectedCurrency == null || !_currencies.any((c) => c.id == _selectedCurrency!.id)) {
        _selectedCurrency = defaultCurrency;
      }
    } catch (e) {
      _errorMessage = 'فشل في تحميل العملات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تغيير العملة المحددة للعرض والفلترة
  void selectCurrency(CurrencyModel currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  /// البحث عن عملة بالمعرف
  CurrencyModel? getCurrencyById(String currencyId) {
    try {
      return _currencies.firstWhere((c) => c.id == currencyId);
    } catch (_) {
      return null;
    }
  }

  /// البحث عن عملة برمز الكود الدولي
  CurrencyModel? getCurrencyByCode(String code) {
    try {
      final clean = code.trim().toUpperCase();
      return _currencies.firstWhere((c) => c.code.toUpperCase() == clean);
    } catch (_) {
      return null;
    }
  }

  /// إضافة عملة جديدة للنظام مع التحقق من عدم تكرار الكود
  Future<CurrencyModel?> addCurrency({
    required String name,
    required String symbol,
    required String code,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanCode = code.trim().toUpperCase();
      final cleanName = name.trim();
      final cleanSymbol = symbol.trim();

      // 1. التحقق من عدم تكرار كود العملة
      if (_currencies.any((c) => c.code.toUpperCase() == cleanCode)) {
        _errorMessage = 'رمز العملة ($cleanCode) موجود مسبقاً في النظام';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      final String newId = _uuid.v4();

      final CurrencyModel newCurrency = CurrencyModel(
        id: newId,
        name: cleanName,
        symbol: cleanSymbol,
        code: cleanCode,
        isDefault: isDefault,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      await db.transaction((txn) async {
        if (isDefault) {
          // إلغاء الافتراضي عن أي عملة سابقة
          await txn.update(
            DatabaseHelper.tableCurrencies,
            {'is_default': 0, 'updated_at': nowUtc},
            where: 'is_default = 1',
          );
        }
        await txn.insert(DatabaseHelper.tableCurrencies, newCurrency.toMap());
      });

      await loadCurrencies();
      return newCurrency;
    } catch (e) {
      _errorMessage = 'فشل في إضافة العملة: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// تعديل بيانات عملة قائمة
  Future<bool> updateCurrency({
    required String id,
    required String name,
    required String symbol,
    required String code,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanCode = code.trim().toUpperCase();
      final cleanName = name.trim();
      final cleanSymbol = symbol.trim();

      // التحقق من عدم تكرار الكود مع عملة أخرى
      if (_currencies.any((c) => c.id != id && c.code.toUpperCase() == cleanCode)) {
        _errorMessage = 'رمز العملة ($cleanCode) مستخدم بالفعل لعملة أخرى';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.transaction((txn) async {
        if (isDefault) {
          await txn.update(
            DatabaseHelper.tableCurrencies,
            {'is_default': 0, 'updated_at': nowUtc},
            where: 'is_default = 1 AND id != ?',
            whereArgs: [id],
          );
        }

        await txn.update(
          DatabaseHelper.tableCurrencies,
          {
            'name': cleanName,
            'symbol': cleanSymbol,
            'code': cleanCode,
            'is_default': isDefault ? 1 : 0,
            'updated_at': nowUtc,
            'is_synced': 0,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      await loadCurrencies();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في تعديل العملة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تعيين عملة كعملة افتراضية للنظام
  Future<bool> setDefaultCurrency(String currencyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.transaction((txn) async {
        // إلغاء الافتراضي عن كافة العملات
        await txn.update(
          DatabaseHelper.tableCurrencies,
          {'is_default': 0, 'updated_at': nowUtc},
          where: 'is_default = 1',
        );

        // تعيين العملة المحددة كافتراضية
        await txn.update(
          DatabaseHelper.tableCurrencies,
          {'is_default': 1, 'updated_at': nowUtc},
          where: 'id = ?',
          whereArgs: [currencyId],
        );
      });

      await loadCurrencies();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في تعيين العملة الافتراضية: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف ناعم لعملة (Soft Delete)
  Future<bool> deleteCurrency(String currencyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final target = getCurrencyById(currencyId);
      if (target != null && target.isDefault) {
        _errorMessage = 'لا يمكن حذف العملة الافتراضية للنظام';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Database db = await _dbHelper.database;

      // فحص وجود حركات مرتبطة بهذه العملة
      final List<Map<String, dynamic>> txCheck = await db.query(
        DatabaseHelper.tableTransactions,
        where: 'currency_id = ? AND deleted_at IS NULL',
        whereArgs: [currencyId],
        limit: 1,
      );

      if (txCheck.isNotEmpty) {
        _errorMessage = 'لا يمكن حذف العملة لوجود حركات مالية مسجلة بها';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      await db.update(
        DatabaseHelper.tableCurrencies,
        {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [currencyId],
      );

      await loadCurrencies();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حذف العملة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
