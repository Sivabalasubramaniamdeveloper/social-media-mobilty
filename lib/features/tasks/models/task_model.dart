class TaskModel {
  final int? id;
  final String userId;
  final String title;
  final String category;
  final String dateDisplay;
  final String? dateIso;
  final String timeDisplay;
  final String? timeIso;
  final String? location;
  final String? details;
  final bool isCompleted;
  final String createdAt;

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.dateDisplay,
    this.dateIso,
    required this.timeDisplay,
    this.timeIso,
    this.location,
    this.details,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'date_display': dateDisplay,
      'date_iso': dateIso,
      'time_display': timeDisplay,
      'time_iso': timeIso,
      'location': location,
      'details': details,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Task',
      category: map['category'] as String? ?? 'Work',
      dateDisplay: map['date_display'] as String? ?? 'Today',
      dateIso: map['date_iso'] as String?,
      timeDisplay: map['time_display'] as String? ?? '10:00 AM',
      timeIso: map['time_iso'] as String?,
      location: map['location'] as String?,
      details: map['details'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  factory TaskModel.fromAiJson(Map<String, dynamic> json, String userId) {
    return TaskModel(
      userId: userId,
      title: json['title'] as String? ?? 'Meeting with Design Team',
      category: json['category'] as String? ?? 'Work',
      dateDisplay: json['date_display'] as String? ?? 'Tomorrow',
      dateIso: json['date_iso'] as String?,
      timeDisplay: json['time_display'] as String? ?? '10:00 AM',
      timeIso: json['time_iso'] as String?,
      location: json['location'] as String?,
      details: json['details'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
