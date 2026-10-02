import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/user_profile_repository.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileCubit({required UserProfileRepository repository})
    : _repository = repository,
      super(const UserProfileInitial());

  Future<void> loadProfile() async {
    emit(const UserProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? dob,
    String? gender,
    String? countryCode,
    String? language,
  }) async {
    try {
      final payload = {
        'full_name': fullName.trim(),
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
        if (countryCode != null) 'country_code': countryCode.toUpperCase(),
        if (language != null) 'language': language,
      };

      final updated = await _repository.updateProfile(payload);
      emit(UserProfileLoaded(updated));
      return true;
    } catch (e) {
      emit(UserProfileError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }
}
