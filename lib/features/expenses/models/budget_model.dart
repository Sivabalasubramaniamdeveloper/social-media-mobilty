class BudgetModel {
  final int? id;
  final String userId;
  final String categoryId;
  final double allocatedAmount;
  final String monthYear; // 'YYYY-MM'
  final int editCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetModel({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.allocatedAmount,
    required this.monthYear,
    this.editCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'allocated_amount': allocatedAmount,
      'month_year': monthYear,
      'edit_count': editCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      allocatedAmount: (map['allocated_amount'] as num).toDouble(),
      monthYear: map['month_year'] as String,
      editCount: (map['edit_count'] as int? ?? 0),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  BudgetModel copyWith({
    int? id,
    String? userId,
    String? categoryId,
    double? allocatedAmount,
    String? monthYear,
    int? editCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      monthYear: monthYear ?? this.monthYear,
      editCount: editCount ?? this.editCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
