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
