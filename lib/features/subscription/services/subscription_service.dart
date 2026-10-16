import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';

/// Uses authenticated backend routes so plan reads and updates share backend DB access.
class SubscriptionService {
  final CustomApiCallService _api = getIt<CustomApiCallService>();
  final CustomSecureStorage _storage = getIt<CustomSecureStorage>();

  /// Loads the plan catalog and current user profile through authenticated APIs.
  Future<Map<String, dynamic>> fetchPlanData() async {
    final token = await _storage.readSecureData('loginToken') ?? '';
    final responses = await Future.wait([
      _api.makeApiRequest(
        method: 'GET',
        token: token,
        url: '${UserHelper.baseUrl}/user/plans',
      ),
      _api.makeApiRequest(
        method: 'GET',
        token: token,
        url: '${UserHelper.baseUrl}/user/me',
      ),
    ]);
    final planResponse = responses[0].data as Map<String, dynamic>;
    final userResponse = responses[1].data as Map<String, dynamic>;
    return {
      'plans': planResponse['data']?['plans'] as List<dynamic>? ?? const [],
      'user':
          userResponse['data']?['user'] as Map<String, dynamic>? ?? const {},
    };
  }

  /// Persists the selected plan and returns the server-confirmed user record.
  Future<Map<String, dynamic>> updatePlan(String planId) async {
    final token = await _storage.readSecureData('loginToken') ?? '';
    final response = await _api.makeApiRequest(
      method: 'PATCH',
      token: token,
      url: '${UserHelper.baseUrl}/user/me/plan',
      data: {'plan_id': planId},
    );
    final body = response.data as Map<String, dynamic>;
    return body['data']?['user'] as Map<String, dynamic>? ?? const {};
  }
}
