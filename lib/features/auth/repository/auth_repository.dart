import '../models/auth_response_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  /// Authenticates a user and returns the backend-issued session payload.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Creates an account through the Supabase client and requests email confirmation.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Clears the current user session.
  Future<void> logout();

  /// Resends the signup confirmation email through Supabase Auth.
  Future<void> resendSignupConfirmation(String email);

  /// Requests a password recovery email through Supabase Auth.
  Future<void> requestPasswordReset(String email);

  /// Applies a new password from the active Supabase recovery session.
  Future<void> updatePassword(String password);

  /// Reads the saved backend access token for session restoration.
  Future<String?> checkCachedSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService})
    : _authService = authService;

  /// Delegates user login to the auth API service.
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }

  /// Delegates account creation to Supabase Auth through the auth service.
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

  /// Delegates session cleanup to the auth service.
  @override
  Future<void> logout() {
    return _authService.clearAuthSession();
  }

  /// Delegates signup confirmation resend to the auth service.
  /// Reads the cached token used by app startup session checks.
  @override
  Future<void> resendSignupConfirmation(String email) {
    return _authService.resendSignupConfirmation(email);
  }

  /// Delegates password recovery email requests to the auth service.
  @override
  Future<void> requestPasswordReset(String email) {
    return _authService.requestPasswordReset(email);
  }

  /// Delegates recovery-session password changes to the auth service.
  @override
  Future<void> updatePassword(String password) {
    return _authService.updatePassword(password);
  }

  @override
  Future<String?> checkCachedSession() {
    return _authService.getSavedToken();
  }
}
