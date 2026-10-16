
import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/weather_model.dart';

class WeatherService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

 

  Future<WeatherResponseModel> fetchWeather({
    required String state,
    required String city,
    String day = 'today',
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final endpoint =
        'https://mineaibackend-production.up.railway.app/api/v1/weather?state=$state&city=$city&day=$day';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: endpoint,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap =
        responseData['data'] as Map<String, dynamic>? ?? responseData;
    return WeatherResponseModel.fromJson(dataMap);
  }
}
