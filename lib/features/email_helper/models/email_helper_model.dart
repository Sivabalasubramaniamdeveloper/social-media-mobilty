class EmailGenerationResult {
  final String subject;
  final String body;
  final String tone;
  final int creditsUsed;
  final int creditsLeft;
  final String apiKeySource;

  EmailGenerationResult({
    required this.subject,
    required this.body,
    required this.tone,
    required this.creditsUsed,
    required this.creditsLeft,
    required this.apiKeySource,
  });

  factory EmailGenerationResult.fromJson(Map<String, dynamic> json) {
    return EmailGenerationResult(
      subject: json['subject'] as String? ?? 'No Subject',
      body: json['body'] as String? ?? '',
      tone: json['tone'] as String? ?? 'Professional',
      creditsUsed: (json['credits_used'] as num?)?.toInt() ?? 20,
      creditsLeft: (json['credits_left'] as num?)?.toInt() ?? 0,
      apiKeySource: json['api_key_source'] as String? ?? 'mineai',
    );
  }
}

class SmtpStatusModel {
  final bool isConfigured;
  final String? keyId;
  final String? keyName;
  final String? keyLastFour;
  final String? email;

  SmtpStatusModel({
    required this.isConfigured,
    this.keyId,
    this.keyName,
    this.keyLastFour,
    this.email,
  });

  factory SmtpStatusModel.fromJson(Map<String, dynamic> json) {
    return SmtpStatusModel(
      isConfigured: json['is_configured'] as bool? ?? false,
      keyId: json['key_id'] as String?,
      keyName: json['key_name'] as String?,
      keyLastFour: json['key_last_four'] as String?,
      email: json['email'] as String?,
    );
  }
}

class SavedEmailModel {
  final int? id;
  final String userId;
  final String label;
  final String subject;
  final String body;
  final String tone;
  final String? recipient;
  final DateTime createdAt;

  SavedEmailModel({
    this.id,
    required this.userId,
    required this.label,
    required this.subject,
    required this.body,
    required this.tone,
    this.recipient,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'label': label,
    'subject': subject,
    'body': body,
    'tone': tone,
    'recipient': recipient,
    'created_at': createdAt.toIso8601String(),
  };

  factory SavedEmailModel.fromMap(Map<String, dynamic> map) => SavedEmailModel(
    id: map['id'] as int?,
    userId: map['user_id'] as String? ?? '',
    label: map['label'] as String? ?? 'General',
    subject: map['subject'] as String? ?? '',
    body: map['body'] as String? ?? '',
    tone: map['tone'] as String? ?? 'Professional',
    recipient: map['recipient'] as String?,
    createdAt:
        DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
  );
}
