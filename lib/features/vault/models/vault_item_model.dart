class VaultItemModel {
  final int? id;
  final String userId;
  final String type; // 'password', 'photo', 'document'
  final String title;
  final String content; // password value or local file path
  final String? accountUsername; // for passwords
  final String? websiteUrl; // for passwords
  final String? notes;
  final String? fileName;
  final int? fileSize;
  final DateTime createdAt;

  VaultItemModel({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.accountUsername,
    this.websiteUrl,
    this.notes,
    this.fileName,
    this.fileSize,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'content': content,
        'account_username': accountUsername,
        'website_url': websiteUrl,
        'notes': notes,
        'file_name': fileName,
        'file_size': fileSize,
        'created_at': createdAt.toIso8601String(),
      };

  factory VaultItemModel.fromMap(Map<String, dynamic> map) => VaultItemModel(
        id: map['id'] as int?,
        userId: map['user_id'] as String? ?? '',
        type: map['type'] as String? ?? 'password',
        title: map['title'] as String? ?? 'Untitled',
        content: map['content'] as String? ?? '',
        accountUsername: map['account_username'] as String?,
        websiteUrl: map['website_url'] as String?,
        notes: map['notes'] as String?,
        fileName: map['file_name'] as String?,
        fileSize: (map['file_size'] as num?)?.toInt(),
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
