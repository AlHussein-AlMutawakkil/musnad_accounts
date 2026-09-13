/// نموذج العملة (Currency)
/// يمثل العملات المالية المدعومة في التطبيق (مثل الريال اليمني والدولار الأمريكي)
class CurrencyModel {
  final String id;
  final String name;
  final String symbol;
  final String code;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const CurrencyModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.code,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
  });

  /// التحقق مما إذا كانت العملة محذوفة (حذف ناعم)
  bool get isDeleted => deletedAt != null;

  CurrencyModel copyWith({
    String? id,
    String? name,
    String? symbol,
    String? code,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      code: code ?? this.code,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'code': code,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      code: map['code'] as String,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CurrencyModel(id: $id, name: $name, code: $code, symbol: $symbol, isDefault: $isDefault)';
}
