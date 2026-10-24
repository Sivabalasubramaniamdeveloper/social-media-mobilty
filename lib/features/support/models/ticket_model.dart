class TicketModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String module;
  final String category;
  final String priority;
  final String subject;
  final String description;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.module,
    required this.category,
    required this.priority,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userEmail: json['user_email'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      module: json['module'] as String? ?? 'general',
      category: json['category'] as String? ?? 'bug',
      priority: json['priority'] as String? ?? 'medium',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'module': module,
      'category': category,
      'priority': priority,
      'subject': subject,
      'description': description,
      'status': status,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
