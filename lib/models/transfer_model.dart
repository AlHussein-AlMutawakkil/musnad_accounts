/// نموذج عملية التحويل أو المصارفة (Transfer)
/// يربط بين حركتين متقابلتين عند التحويل المالي بنفس العملة أو مع المصارفة بين عملتين مختلفتين
class TransferModel {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final String fromCurrencyId;
  final String toCurrencyId;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const TransferModel({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.fromCurrencyId,
    required this.toCurrencyId,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
  });

  /// هل التحويل بنفس العملة دون مصارفة
  bool get isSameCurrency => fromCurrencyId == toCurrencyId;

  /// هل العملية تتضمن مصارفة بين عملتين مختلفتين
  bool get isExchange => fromCurrencyId != toCurrencyId;

  /// هل العملية محذوفة (حذف ناعم)
  bool get isDeleted => deletedAt != null;

  TransferModel copyWith({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    String? fromCurrencyId,
    String? toCurrencyId,
    double? fromAmount,
    double? toAmount,
    double? exchangeRate,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return TransferModel(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      fromCurrencyId: fromCurrencyId ?? this.fromCurrencyId,
      toCurrencyId: toCurrencyId ?? this.toCurrencyId,
      fromAmount: fromAmount ?? this.fromAmount,
      toAmount: toAmount ?? this.toAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'from_currency_id': fromCurrencyId,
      'to_currency_id': toCurrencyId,
      'from_amount': fromAmount,
      'to_amount': toAmount,
      'exchange_rate': exchangeRate,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      id: map['id'] as String,
      fromAccountId: map['from_account_id'] as String,
      toAccountId: map['to_account_id'] as String,
      fromCurrencyId: map['from_currency_id'] as String,
      toCurrencyId: map['to_currency_id'] as String,
      fromAmount: (map['from_amount'] as num).toDouble(),
      toAmount: (map['to_amount'] as num).toDouble(),
      exchangeRate: (map['exchange_rate'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TransferModel(id: $id, fromAmount: $fromAmount, toAmount: $toAmount, rate: $exchangeRate)';
}
