class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? dob;
  final String? gender;
  final String? countryCode;
  final String? timezone;
  final String? language;
  final String? avatarUrl;
  final int credits;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.dob,
    this.gender,
    this.countryCode,
    this.timezone,
    this.language,
    this.avatarUrl,
    this.credits = 1250,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      countryCode: json['country_code'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      credits: (json['credits'] as num?)?.toInt() ?? 1250,
    );
  }
}
