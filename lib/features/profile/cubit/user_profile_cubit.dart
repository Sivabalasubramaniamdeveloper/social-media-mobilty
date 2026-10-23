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
    String? phone,
    String? dob,
    String? gender,
    String? countryCode,
    String? language,
    String? avatarUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'full_name': fullName.trim(),
      };
      if (phone != null) payload['phone'] = phone.trim();
      if (dob != null) payload['dob'] = dob;
      if (gender != null) payload['gender'] = gender;
      if (countryCode != null) payload['country_code'] = countryCode.toUpperCase();
      if (language != null) payload['language'] = language;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;

      final updated = await _repository.updateProfile(payload);
      emit(UserProfileLoaded(updated));
      return true;
    } catch (e) {
      emit(UserProfileError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }
}
