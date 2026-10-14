class TransactionModel {
  final int? id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'expense' or 'income'
  final String categoryId;
  final DateTime time;
  final DateTime updateTime;
  final String? note;
  final bool isSynced;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.time,
    required this.updateTime,
    this.note,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'time': time.toIso8601String(),
      'update_time': updateTime.toIso8601String(),
      'note': note,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as String,
      time: DateTime.parse(map['time'] as String),
      updateTime: DateTime.parse(map['update_time'] as String),
      note: map['note'] as String?,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
    );
  }
}
