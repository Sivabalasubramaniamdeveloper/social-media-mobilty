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

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);
}
