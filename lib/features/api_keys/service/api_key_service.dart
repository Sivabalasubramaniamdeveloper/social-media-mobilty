import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';
import '../models/api_key_model.dart';

class ApiKeyService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<List<ApiKeyModel>> fetchApiKeys() async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: '${UserHelper.baseUrl}/users/api-keys',
      // url: 'http://localhost:3000/api/v1/users/api-keys',
    );

    final responseData = response.data as Map<String, dynamic>;
    final list = responseData['data']?['apiKeys'] as List<dynamic>? ?? [];
    return list
        .map((item) => ApiKeyModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AiProviderModel>> fetchProviders() async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: '${UserHelper.baseUrl}/users/api-keys/providers',
    );

    final responseData = response.data as Map<String, dynamic>;
    final list = responseData['data']?['providers'] as List<dynamic>? ?? [];
    return list
        .map((item) => AiProviderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ApiKeyModel> addApiKey({
    required String keyName,
    required String apiKey,
    String? providerId,
    String? providerName,
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final payload = <String, dynamic>{'key_name': keyName, 'api_key': apiKey};
    if (providerId != null) payload['provider_id'] = providerId;
    if (providerName != null) payload['provider_name'] = providerName;

    final response = await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      // url: 'http://localhost:3000/api/v1/users/api-keys',
      url: '${UserHelper.baseUrl}/users/api-keys',
      data: payload,
    );

    final responseData = response.data as Map<String, dynamic>;
    final keyData =
        responseData['data']?['apiKey'] as Map<String, dynamic>? ?? {};
    return ApiKeyModel.fromJson(keyData);
  }

  Future<void> deleteApiKey(String keyId) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    await _apiService.makeApiRequest(
      method: 'DELETE',
      token: token,
      url: '${UserHelper.baseUrl}/users/api-keys/$keyId',
    );
  }

  Future<void> updateApiKeyStatus(String keyId, bool isActive) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    await _apiService.makeApiRequest(
      method: 'PATCH',
      token: token,
      url: '${UserHelper.baseUrl}/users/api-keys/$keyId',
      // url: 'http://localhost:3000/api/v1/users/api-keys/$keyId',
      data: {'is_active': isActive},
    );
  }
}
