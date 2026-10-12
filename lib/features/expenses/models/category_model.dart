class CategoryModel {
  final String id;
  final String? userId; // null for system categories
  final String name;
  final String type; // 'expense' or 'income'
  final String? icon;
  final int? color;
  final bool isCustom;

  const CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as int?,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
    );
  }
}
