
import 'package:mineai/core/utils/user_helper.dart';

import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<UserProfileModel> fetchUserProfile() async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: '${UserHelper.baseUrl}/user/me',
    );

    final responseData = response.data as Map<String, dynamic>;
    final userMap =
        responseData['data']?['user'] as Map<String, dynamic>? ?? {};
    return UserProfileModel.fromJson(userMap);
  }

  Future<UserProfileModel> updateUserProfile(
    Map<String, dynamic> updateData,
  ) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'PATCH',
      token: token,
      url: '${UserHelper.baseUrl}/user/me',
      data: updateData,
    );

    final responseData = response.data as Map<String, dynamic>;
    final userMap =
        responseData['data']?['user'] as Map<String, dynamic>? ?? {};
    return UserProfileModel.fromJson(userMap);
  }
}
