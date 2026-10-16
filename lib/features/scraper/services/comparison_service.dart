import 'package:mineai/core/utils/user_helper.dart';
import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/price_compare_model.dart';

class ComparisonService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<DetailedComparisonModel> comparePrice(String query) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final endpoint =
        '${UserHelper.baseUrl}/prices/compare?q=${Uri.encodeComponent(query.trim())}';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: endpoint,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap =
        responseData['data'] as Map<String, dynamic>? ?? responseData;
    return DetailedComparisonModel.fromJson(dataMap);
  }
}
