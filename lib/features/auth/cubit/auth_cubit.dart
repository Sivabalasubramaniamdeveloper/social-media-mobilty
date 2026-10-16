import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInitial());

  /// Authenticates through the backend and publishes the signed-in user state.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final authModel = await _repository.login(
        email: email,
        password: password,
      );
      emit(AuthLoginSuccess(authModel));
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(cleanMessage));
    }
  }

  /// Creates an account and waits for Supabase email confirmation before login.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(const AuthLoading());
    try {
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      emit(AuthRegisterSuccess(email));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Clears Supabase and app tokens, then returns auth state to its initial value.
  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthInitial());
  }

  /// Requests a replacement Supabase signup confirmation email.
  Future<void> resendSignupConfirmation(String email) async {
    emit(const AuthLoading());
    try {
      await _repository.resendSignupConfirmation(email);
      emit(const AuthEmailConfirmationSent());
    } catch (error) {
      emit(AuthFailure(_messageFrom(error)));
    }
  }

  /// Requests a password recovery email without disclosing account existence.
  Future<void> requestPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _repository.requestPasswordReset(email);
      emit(const AuthPasswordResetEmailSent());
    } catch (error) {
      emit(AuthFailure(_messageFrom(error)));
    }
  }

  /// Updates the password using the session Supabase creates from a recovery link.
  Future<void> updatePassword(String password) async {
    emit(const AuthLoading());
    try {
      await _repository.updatePassword(password);
      emit(const AuthPasswordUpdated());
    } catch (error) {
      emit(AuthFailure(_messageFrom(error)));
    }
  }

  /// Removes Dart's exception wrapper before a failure is shown to the user.
  String _messageFrom(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
