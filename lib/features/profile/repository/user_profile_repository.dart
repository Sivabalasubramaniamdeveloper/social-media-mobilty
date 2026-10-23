import '../models/user_profile_model.dart';
import '../service/user_profile_service.dart';

abstract class UserProfileRepository {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileService _service;

  UserProfileRepositoryImpl({required UserProfileService service})
    : _service = service;

  @override
  Future<UserProfileModel> getProfile() {
    return _service.fetchUserProfile();
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) {
    return _service.updateUserProfile(data);
  }
}
