import '../models/auth_response_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoginSuccess extends AuthState {
  final AuthResponseModel authData;
  const AuthLoginSuccess(this.authData);
}

class AuthRegisterSuccess extends AuthState {
  final String email;
  const AuthRegisterSuccess(this.email);
}

/// Confirms Supabase accepted a signup confirmation email resend request.
class AuthEmailConfirmationSent extends AuthState {
  const AuthEmailConfirmationSent();
}

/// Confirms Supabase accepted a password recovery email request.
class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
}

/// Confirms that the recovery session password update succeeded.
class AuthPasswordUpdated extends AuthState {
  const AuthPasswordUpdated();
}

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);
}
