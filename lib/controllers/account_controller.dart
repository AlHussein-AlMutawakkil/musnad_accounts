import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/currency_model.dart';

/// وحدة التحكم وإدارة الحسابات والأرصدة الديناميكية (Account Controller)
class AccountController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];
  
  // خريطة الأرصدة: accountId -> {currencyId: balance}
  final Map<String, Map<String, double>> _accountBalances = {};

  // خريطة المؤشرات الإجمالية: currencyId -> {'credit': X, 'debit': Y, 'net': Z}
  final Map<String, Map<String, double>> _overallKpis = {};

  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  List<AccountModel> get accounts => _accounts;
  List<CategoryModel> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// قائمة الحسابات بعد تطبيق البحث والفلترة حسب التصنيف
  List<AccountModel> get filteredAccounts {
    return _accounts.where((account) {
      final matchesSearch = _searchQuery.isEmpty ||
          account.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (account.phone != null && account.phone!.contains(_searchQuery));

      final matchesCategory = _selectedCategoryId == null ||
          account.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// تحميل كافة الحسابات والتصنيفات وحساب الأرصدة التراكمية ديناميكياً
  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;

      // 1. جلب التصنيفات
      final List<Map<String, dynamic>> categoryMaps = await db.query(
        DatabaseHelper.tableCategories,
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      _categories = categoryMaps.map((m) => CategoryModel.fromMap(m)).toList();

      // 2. جلب الحسابات غير المحذوفة
      final List<Map<String, dynamic>> accountMaps = await db.query(
        DatabaseHelper.tableAccounts,
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      _accounts = accountMaps.map((m) => AccountModel.fromMap(m)).toList();

      // 3. حساب الأرصدة والمؤشرات ديناميكياً وفق المعادلة المحاسبية:
      // رصيد الحساب = مجموع (له / CREDIT) - مجموع (عليه / DEBIT)
      await _calculateDynamicBalances(db);

    } catch (e) {
      _errorMessage = 'فشل في تحميل الحسابات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حساب الأرصدة ديناميكياً من جدول الحركات القياسية
  Future<void> _calculateDynamicBalances(Database db) async {
    _accountBalances.clear();
    _overallKpis.clear();

    final List<Map<String, dynamic>> balanceRows = await db.rawQuery('''
      SELECT 
        account_id,
        currency_id,
        SUM(CASE WHEN type = 'CREDIT' THEN amount ELSE 0 END) AS total_credit,
        SUM(CASE WHEN type = 'DEBIT' THEN amount ELSE 0 END) AS total_debit
      FROM ${DatabaseHelper.tableTransactions}
      WHERE deleted_at IS NULL
      GROUP BY account_id, currency_id
    ''');

    for (final row in balanceRows) {
      final String accountId = row['account_id'] as String;
      final String currencyId = row['currency_id'] as String;
      final double totalCredit = (row['total_credit'] as num).toDouble();
      final double totalDebit = (row['total_debit'] as num).toDouble();
      final double balance = totalCredit - totalDebit;

      // تحديث أرصدة الحساب
      _accountBalances.putIfAbsent(accountId, () => {})[currencyId] = balance;

      // تحديث المؤشرات الإجمالية العامة للنظام لكل عملة
      final kpi = _overallKpis.putIfAbsent(currencyId, () => {
        'credit': 0.0,
        'debit': 0.0,
        'net': 0.0,
      });

      kpi['credit'] = (kpi['credit'] ?? 0.0) + totalCredit;
      kpi['debit'] = (kpi['debit'] ?? 0.0) + totalDebit;
      kpi['net'] = (kpi['net'] ?? 0.0) + balance;
    }
  }

  /// الحصول على رصيد حساب بعملة محددة
  double getAccountBalance(String accountId, String currencyId) {
    return _accountBalances[accountId]?[currencyId] ?? 0.0;
  }

  /// الحصول على خريطة أرصدة الحساب لكافة العملات التي يملك فيها رصيداً
  Map<String, double> getBalancesMapForAccount(String accountId, List<CurrencyModel> currencies) {
    final Map<String, double> result = {};
    final balances = _accountBalances[accountId];
    if (balances == null) return result;

    for (final entry in balances.entries) {
      if (entry.value != 0.0) {
        final currency = currencies.cast<CurrencyModel?>().firstWhere(
          (c) => c?.id == entry.key,
          orElse: () => null,
        );
        final symbol = currency != null ? currency.symbol : entry.key;
        result[symbol] = entry.value;
      }
    }
    return result;
  }

  /// جلب مؤشرات النظام الإجمالية لعملة معينة (له، عليه، الصافي)
  Map<String, double> getKpisForCurrency(String currencyId) {
    return _overallKpis[currencyId] ?? {
      'credit': 0.0,
      'debit': 0.0,
      'net': 0.0,
    };
  }

  /// اسم التصنيف بناء على معرّفه
  String? getCategoryName(String? categoryId) {
    if (categoryId == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return null;
    }
  }

  /// إضافة حساب جديد
  Future<AccountModel?> addAccount({
    required String name,
    String? phone,
    String? notes,
    String? categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      final String newId = _uuid.v4();

      final AccountModel newAccount = AccountModel(
        id: newId,
        name: name.trim(),
        phone: phone != null && phone.trim().isNotEmpty ? phone.trim() : null,
        notes: notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
        categoryId: categoryId,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      await db.insert(DatabaseHelper.tableAccounts, newAccount.toMap());
      await loadAccounts();
      return newAccount;
    } catch (e) {
      _errorMessage = 'فشل في إضافة الحساب: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// تعديل بيانات حساب
  Future<bool> updateAccount({
    required String id,
    required String name,
    String? phone,
    String? notes,
    String? categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.update(
        DatabaseHelper.tableAccounts,
        {
          'name': name.trim(),
          'phone': phone != null && phone.trim().isNotEmpty ? phone.trim() : null,
          'notes': notes != null && notes.trim().isNotEmpty ? notes.trim() : null,
          'category_id': categoryId,
          'updated_at': nowUtc,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadAccounts();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في تعديل الحساب: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف ناعم للحساب (Soft Delete)
  Future<bool> deleteAccount(String accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.update(
        DatabaseHelper.tableAccounts,
        {
          'deleted_at': nowUtc,
          'updated_at': nowUtc,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [accountId],
      );

      await loadAccounts();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حذف الحساب: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث نص البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// تحديد تصنيف للفلترة (أو null لجميع الحسابات)
  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}
