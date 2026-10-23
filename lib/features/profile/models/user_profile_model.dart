class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? countryCode;
  final String? timezone;
  final String? language;
  final String? avatarUrl;
  final int credits;
  final int dailyCreditLimit;
  final int creditsUsedToday;
  final String? creditsRechargeCountdown;
  final String? nextResetAt;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.phone,
    this.dob,
    this.gender,
    this.countryCode,
    this.timezone,
    this.language,
    this.avatarUrl,
    this.credits = 100,
    this.dailyCreditLimit = 100,
    this.creditsUsedToday = 0,
    this.creditsRechargeCountdown,
    this.nextResetAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      countryCode: json['country_code'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      credits: (json['credits'] as num?)?.toInt() ?? 100,
      dailyCreditLimit: (json['daily_credit_limit'] as num?)?.toInt() ?? 100,
      creditsUsedToday: (json['credits_used_today'] as num?)?.toInt() ?? 0,
      creditsRechargeCountdown: json['credits_recharge_countdown'] as String?,
      nextResetAt: json['next_reset_at'] as String?,
    );
  }
}
