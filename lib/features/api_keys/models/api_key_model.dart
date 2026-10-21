class ApiKeyModel {
  final String id;
  final String keyName;
  final String keyLastFour;
  final bool isActive;
  final String? providerName;
  final String? providerDisplayName;
  final String? lastUsedAt;
  final String? createdAt;

  ApiKeyModel({
    required this.id,
    required this.keyName,
    required this.keyLastFour,
    required this.isActive,
    this.providerName,
    this.providerDisplayName,
    this.lastUsedAt,
    this.createdAt,
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>? ?? {};
    return ApiKeyModel(
      id: json['id'] as String? ?? '',
      keyName: json['key_name'] as String? ?? 'API Key',
      keyLastFour: json['key_last_four'] as String? ?? '****',
      isActive: json['is_active'] as bool? ?? true,
      providerName: provider['name'] as String? ?? json['provider_name'] as String?,
      providerDisplayName: provider['display_name'] as String? ?? json['provider_display_name'] as String?,
      lastUsedAt: json['last_used_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class AiProviderModel {
  final String id;
  final String name;
  final String displayName;
  final bool isActive;

  AiProviderModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isActive,
  });

  factory AiProviderModel.fromJson(Map<String, dynamic> json) {
    return AiProviderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
