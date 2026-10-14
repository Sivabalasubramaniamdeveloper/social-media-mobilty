class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime time;
  final DateTime updateTime;
  final String? note;

  const ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.time,
    required this.updateTime,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'time': time.toIso8601String(),
      'update_time': updateTime.toIso8601String(),
      'note': note,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      time: DateTime.parse(map['time'] as String),
      updateTime: DateTime.parse(map['update_time'] as String),
      note: map['note'] as String?,
    );
  }

  ExpenseModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? time,
    DateTime? updateTime,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      time: time ?? this.time,
      updateTime: updateTime ?? this.updateTime,
      note: note ?? this.note,
    );
  }
}
