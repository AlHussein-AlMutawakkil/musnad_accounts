import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/transfer_model.dart';

/// وحدة التحكم في عمليات التحويل المالي والمصارفة (Transfer Controller)
/// تنفذ العمليات المحاسبية المزدوجة داخل معاملات ذرية db.transaction تضمن توازن القيود وسلامتها
class TransferController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<TransferModel> _transfers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransferModel> get transfers => _transfers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تنفيذ عملية تحويل مالي بنفس العملة بين حسابين
  Future<TransferModel?> executeSameCurrencyTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String fromAccountName,
    required String toAccountName,
    required String currencyId,
    required String currencySymbol,
    required double amount,
    DateTime? date,
    String? notes,
  }) async {
    return await executeExchangeTransfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      fromAccountName: fromAccountName,
      toAccountName: toAccountName,
      fromCurrencyId: currencyId,
      toCurrencyId: currencyId,
      fromCurrencySymbol: currencySymbol,
      toCurrencySymbol: currencySymbol,
      fromAmount: amount,
      toAmount: amount,
      exchangeRate: 1.0,
      date: date,
      notes: notes,
    );
  }

  /// تنفيذ عملية تحويل ومصارفة بين حسابين بعملات مختلفة (أو نفس العملة)
  /// المعاملة تنفذ بالكامل ذرّياً داخل db.transaction(...)
  Future<TransferModel?> executeExchangeTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String fromAccountName,
    required String toAccountName,
    required String fromCurrencyId,
    required String toCurrencyId,
    required String fromCurrencySymbol,
    required String toCurrencySymbol,
    required double fromAmount,
    required double toAmount,
    required double exchangeRate,
    DateTime? date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();
      final DateTime effectiveDate = date ?? DateTime.now();

      final String transferId = _uuid.v4();
      final String fromTxId = _uuid.v4();
      final String toTxId = _uuid.v4();

      final isExchange = fromCurrencyId != toCurrencyId;

      final TransferModel transfer = TransferModel(
        id: transferId,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        fromCurrencyId: fromCurrencyId,
        toCurrencyId: toCurrencyId,
        fromAmount: fromAmount,
        toAmount: toAmount,
        exchangeRate: exchangeRate,
        date: effectiveDate,
        notes: notes?.trim(),
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      // تفاصيل الحركة للمرسل وللمستلم
      final String fromDetails = isExchange
          ? 'مصارفة وتحويل إلى: $toAccountName ($toAmount $toCurrencySymbol بسعر $exchangeRate)${notes != null && notes.isNotEmpty ? ' - $notes' : ''}'
          : 'تحويل إلى: $toAccountName${notes != null && notes.isNotEmpty ? ' - $notes' : ''}';

      final String toDetails = isExchange
          ? 'استلام مصارفة من: $fromAccountName ($fromAmount $fromCurrencySymbol بسعر $exchangeRate)${notes != null && notes.isNotEmpty ? ' - $notes' : ''}'
          : 'تحويل مستلم من: $fromAccountName${notes != null && notes.isNotEmpty ? ' - $notes' : ''}';

      // 1. قيد المدين على الطرف المحول (عليه - ينقص رصيده)
      final TransactionModel fromTx = TransactionModel(
        id: fromTxId,
        accountId: fromAccountId,
        currencyId: fromCurrencyId,
        type: TransactionType.debit,
        amount: fromAmount,
        details: fromDetails,
        date: effectiveDate,
        transferId: transferId,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      // 2. قيد الدائن للطرف المستلم (له - يزيد رصيده)
      final TransactionModel toTx = TransactionModel(
        id: toTxId,
        accountId: toAccountId,
        currencyId: toCurrencyId,
        type: TransactionType.credit,
        amount: toAmount,
        details: toDetails,
        date: effectiveDate,
        transferId: transferId,
        createdAt: DateTime.parse(nowUtc),
        updatedAt: DateTime.parse(nowUtc),
        isSynced: false,
      );

      // تنفيذ المعاملة الذرية التزاماً بقواعد النظام المحاسبي
      await db.transaction((txn) async {
        await txn.insert(DatabaseHelper.tableTransfers, transfer.toMap());
        await txn.insert(DatabaseHelper.tableTransactions, fromTx.toMap());
        await txn.insert(DatabaseHelper.tableTransactions, toTx.toMap());
      });

      _isLoading = false;
      notifyListeners();
      return transfer;

    } catch (e) {
      _errorMessage = 'فشل في تنفيذ عملية التحويل: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// تحميل قائمة عمليات التحويل والمصارفة
  Future<void> loadTransfers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransfers,
        where: 'deleted_at IS NULL',
        orderBy: 'date DESC, created_at DESC',
      );

      _transfers = maps.map((m) => TransferModel.fromMap(m)).toList();
    } catch (e) {
      _errorMessage = 'فشل في تحميل التحويلات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حذف عملية تحويل وإلغاء القيدين المزدوجين المقترنين بها ذرياً
  Future<bool> deleteTransfer(String transferId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Database db = await _dbHelper.database;
      final String nowUtc = DateTime.now().toUtc().toIso8601String();

      await db.transaction((txn) async {
        // حذف التحويل
        await txn.update(
          DatabaseHelper.tableTransfers,
          {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
          where: 'id = ?',
          whereArgs: [transferId],
        );

        // حذف القيدين المرتبطين
        await txn.update(
          DatabaseHelper.tableTransactions,
          {'deleted_at': nowUtc, 'updated_at': nowUtc, 'is_synced': 0},
          where: 'transfer_id = ?',
          whereArgs: [transferId],
        );
      });

      await loadTransfers();
      return true;
    } catch (e) {
      _errorMessage = 'فشل في إلغاء التحويل: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
