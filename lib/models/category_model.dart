/// نموذج التصنيف (Category)
/// يُستخدم لتصنيف الحسابات والجهات المالية (مثل: عملاء، موردين، شخصي)
class CategoryModel {
  final String id;
  final String name;
  final String? colorHex;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isSynced;

  const CategoryModel({
    required this.id,
    required this.name,
    this.colorHex,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isSynced = false,
  });

  /// التحقق مما إذا كان التصنيف محذوفاً (حذف ناعم)
  bool get isDeleted => deletedAt != null;

  CategoryModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isSynced,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
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
      'color_hex': colorHex,
      'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String?,
      iconName: map['icon_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, colorHex: $colorHex, iconName: $iconName)';
}
