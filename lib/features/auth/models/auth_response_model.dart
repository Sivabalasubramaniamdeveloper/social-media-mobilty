class UserAuthModel {
  final String id;
  final String email;
  final String? username;
  final String? fullName;

  const UserAuthModel({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
  });

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
    };
  }
}

class AuthResponseModel {
  final UserAuthModel? user;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;

  const AuthResponseModel({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    final sessionData = json['session'] as Map<String, dynamic>?;

    return AuthResponseModel(
      user: userData != null ? UserAuthModel.fromJson(userData) : null,
      accessToken: sessionData?['access_token'] as String?,
      refreshToken: sessionData?['refresh_token'] as String?,
      expiresIn: sessionData?['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'session': {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
      },
    };
  }
}
