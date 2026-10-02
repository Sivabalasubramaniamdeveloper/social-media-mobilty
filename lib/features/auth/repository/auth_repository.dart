import '../models/auth_response_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<String?> checkCachedSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService})
    : _authService = authService;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _authService.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<void> logout() {
    return _authService.clearAuthSession();
  }

  @override
  Future<String?> checkCachedSession() {
    return _authService.getSavedToken();
  }
}
