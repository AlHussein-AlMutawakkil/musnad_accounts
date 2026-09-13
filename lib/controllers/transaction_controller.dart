import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';

/// كائن يمثل قيداً في كشف الحساب مقترناً بالرصيد التراكمي اللحظي
class StatementEntry {
  final TransactionModel transaction;
  final double runningBalance;

  const StatementEntry({
    required this.transaction,
    required this.runningBalance,
  });
}

/// وحدة التحكم وإدارة القيود المالية وكشف الحساب (Transaction Controller)
class TransactionController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // قيود كشف الحساب النشط
  List<StatementEntry> _statementEntries = [];
  
  // ملخصات كشف الحساب المفلتر
  double _statementTotalCredit = 0.0;
  double _statementTotalDebit = 0.0;
  double _statementNetBalance = 0.0;

  // أحدث الحركات العامة للشاشة الرئيسية
  List<TransactionModel> _recentTransactions = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<StatementEntry> get statementEntries => _statementEntries;
  double get statementTotalCredit => _statementTotalCredit;
  double get statementTotalDebit => _statementTotalDebit;
  double get statementNetBalance => _statementNetBalance;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تسجيل قيد جديد (له / دائن أو عليه / مدين)
  Future<TransactionModel?> addTransaction({
    required String accountId,
    required String currencyId,
    String? categoryId,
    required TransactionType type,
    required double amount,
    String? details,
    DateTime? date,
    String? transferId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      final String newId = _uuid.v4();
      final DateTime effectiveDate = date ?? DateTime.now();

      final TransactionModel newTx = TransactionModel(
        id: newId,
        accountId: accountId,
        currencyId: currencyId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        details: details?.trim(),
        date: effectiveDate,
        transferId: transferId,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      await db.insert(DatabaseHelper.tableTransactions, newTx.toMap());

      _isLoading = false;
      notifyListeners();
      return newTx;
    } catch (e) {
      _errorMessage = 'فشل في إضافة القيد: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// تحميل كشف حساب تفصيلي لطرف محدد مع الفلاتر وحساب الرصيد التراكمي
  Future<void> loadAccountStatement({
    required String accountId,
    required String currencyId,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? typeFilter,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;

      // 1. حساب الرصيد الافتتاحي ما قبل تاريخ البداية (إذا تم تحديد fromDate)
      double openingBalance = 0.0;
      if (fromDate != null) {
        final List<Map<String, dynamic>> openRows = await db.rawQuery('''
          SELECT 
            SUM(CASE WHEN type = 'CREDIT' THEN amount ELSE -amount END) AS prev_balance
          FROM ${DatabaseHelper.tableTransactions}
          WHERE account_id = ? 
            AND currency_id = ? 
            AND date < ?
            AND deleted_at IS NULL
        ''', [accountId, currencyId, fromDate.toIso8601String()]);

        if (openRows.isNotEmpty && openRows.first['prev_balance'] != null) {
          openingBalance = (openRows.first['prev_balance'] as num).toDouble();
        }
      }

      // 2. بناء استعلام الحركات المفلترة تصاعدياً بحسب التاريخ لحساب التراكمي بدقة
      final List<String> whereClauses = [
        'account_id = ?',
        'currency_id = ?',
        'deleted_at IS NULL',
      ];
      final List<dynamic> whereArgs = [accountId, currencyId];

      if (fromDate != null) {
        whereClauses.add('date >= ?');
        whereArgs.add(fromDate.toIso8601String());
      }
      if (toDate != null) {
        // نضبط حتى نهاية اليوم
        final endOfDay = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
        whereClauses.add('date <= ?');
        whereArgs.add(endOfDay.toIso8601String());
      }
      if (typeFilter != null) {
        whereClauses.add('type = ?');
        whereArgs.add(typeFilter.value);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'date ASC, created_at ASC',
      );

      final List<TransactionModel> txList =
          maps.map((m) => TransactionModel.fromMap(m)).toList();

      // 3. احتساب الرصيد التراكمي وإجماليات الكشف
      double currentBalance = openingBalance;
      double creditSum = 0.0;
      double debitSum = 0.0;

      final List<StatementEntry> entries = [];

      for (final tx in txList) {
        if (tx.isCredit) {
          creditSum += tx.amount;
          currentBalance += tx.amount;
        } else {
          debitSum += tx.amount;
          currentBalance -= tx.amount;
        }

        entries.add(StatementEntry(
          transaction: tx,
          runningBalance: currentBalance,
        ));
      }

      // نعكس الترتيب ليكون الأحدث في الأعلى لعرض الكشف
      _statementEntries = entries.reversed.toList();
      _statementTotalCredit = creditSum;
      _statementTotalDebit = debitSum;
      _statementNetBalance = creditSum - debitSum;

    } catch (e) {
      _errorMessage = 'فشل في تحميل كشف الحساب: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل أحدث الحركات للشاشة الرئيسية
  Future<void> loadRecentTransactions({int limit = 20, String? currencyId}) async {
    try {
      final Database db = await _dbHelper.database;
      final List<String> whereClauses = ['deleted_at IS NULL'];
      final List<dynamic> whereArgs = [];

      if (currencyId != null) {
        whereClauses.add('currency_id = ?');
        whereArgs.add(currencyId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'date DESC, created_at DESC',
        limit: limit,
      );

      _recentTransactions = maps.map((m) => TransactionModel.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل في جلب أحدث الحركات: $e';
    }
  }

  /// تعديل قيد مالي
  Future<bool> updateTransaction({
    required String id,
    required TransactionType type,
    required double amount,
    String? details,
    String? categoryId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.update(
        DatabaseHelper.tableTransactions,
        {
          'type': type.value,
          'amount': amount,
          'details': details?.trim(),
          'category_id': categoryId,
          'date': date.toIso8601String(),
          'updated_at': nowUtc,
          'is_synced': 0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في تعديل القيد: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف ناعم للقيد المالي (Soft Delete)
  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      // فحص إذا كان القيد مرتبطاً بعملية تحويل مزدوجة
      final List<Map<String, dynamic>> currentTx = await db.query(
        DatabaseHelper.tableTransactions,
        columns: ['transfer_id'],
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      final String? transferId = currentTx.isNotEmpty
          ? currentTx.first['transfer_id'] as String?
          : null;

      await db.transaction((txn) async {
        if (transferId != null && transferId.isNotEmpty) {
          // حذف الحركتين المقترنتين وعملية التحويل معاً لضمان التوازن
          await txn.update(
            DatabaseHelper.tableTransactions,
            {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
            where: 'transfer_id = ?',
            whereArgs: [transferId],
          );
          await txn.update(
            DatabaseHelper.tableTransfers,
            {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
            where: 'id = ?',
            whereArgs: [transferId],
          );
        } else {
          // قيد فردي عادي
          await txn.update(
            DatabaseHelper.tableTransactions,
            {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
            where: 'id = ?',
            whereArgs: [transactionId],
          );
        }
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في حذف القيد: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
