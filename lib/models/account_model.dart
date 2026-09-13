/// نموذج الحساب / الطرف المالي (Account)
/// يمثل الأشخاص أو الجهات التي يتم تسجيل المعاملات المالية (له / عليه) معها
class AccountModel {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const AccountModel({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
  });

  /// التحقق مما إذا كان الحساب محذوفاً (حذف ناعم)
  bool get isDeleted => deletedAt != null;

  AccountModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
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
      'phone': phone,
      'notes': notes,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      notes: map['notes'] as String?,
      categoryId: map['category_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AccountModel(id: $id, name: $name, phone: $phone, categoryId: $categoryId)';
}
