/// نوع الحركة المالية (له / دائن أو عليه / مدين)
enum TransactionType {
  credit('CREDIT'), // له / دائن (يزيد رصيد الطرف)
  debit('DEBIT');   // عليه / مدين (ينقص رصيد الطرف)

  final String value;
  const TransactionType(this.value);

  /// تحويل النص المخزن في قاعدة البيانات إلى نوع الحركة
  static TransactionType fromString(String val) {
    if (val.toUpperCase() == 'CREDIT') {
      return TransactionType.credit;
    }
    return TransactionType.debit;
  }

  /// التسمية العربية المباشرة للواجهات
  String get label => this == TransactionType.credit ? 'له' : 'عليه';

  /// التسمية المحاسبية المعتمدة
  String get accountingLabel => this == TransactionType.credit ? 'دائن' : 'مدين';
}

/// نموذج القيد / الحركة المالية (Transaction)
/// يمثل كل قيد مالي مسجل لحساب بعملة محددة
class TransactionModel {
  final String id;
  final String accountId;
  final String currencyId;
  final String? categoryId;
  final TransactionType type;
  final double amount;
  final String? details;
  final DateTime date;
  final String? transferId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.currencyId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.details,
    required this.date,
    this.transferId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
  });

  /// هل القيد حركة دائنة (له)
  bool get isCredit => type == TransactionType.credit;

  /// هل القيد حركة مدينة (عليه)
  bool get isDebit => type == TransactionType.debit;

  /// هل الحركة جزء من عملية تحويل أو مصارفة مزدوجة
  bool get isTransfer => transferId != null && transferId!.isNotEmpty;

  /// هل الحركة محذوفة (حذف ناعم)
  bool get isDeleted => deletedAt != null;

  TransactionModel copyWith({
    String? id,
    String? accountId,
    String? currencyId,
    String? categoryId,
    TransactionType? type,
    double? amount,
    String? details,
    DateTime? date,
    String? transferId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      currencyId: currencyId ?? this.currencyId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      details: details ?? this.details,
      date: date ?? this.date,
      transferId: transferId ?? this.transferId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'currency_id': currencyId,
      'category_id': categoryId,
      'type': type.value,
      'amount': amount,
      'details': details,
      'date': date.toIso8601String(),
      'transfer_id': transferId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      currencyId: map['currency_id'] as String,
      categoryId: map['category_id'] as String?,
      type: TransactionType.fromString(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      details: map['details'] as String?,
      date: DateTime.parse(map['date'] as String),
      transferId: map['transfer_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TransactionModel(id: $id, accountId: $accountId, type: ${type.value}, amount: $amount, date: $date)';
}
