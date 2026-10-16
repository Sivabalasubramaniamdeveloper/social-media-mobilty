import 'package:mineai/core/utils/user_helper.dart';
import '../../../../core/network/custom_api_call.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../instance/locator.dart';
import '../models/product_scrape_model.dart';

class ProductScraperService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  /// Scrape all stores with pagination
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';
    final endpoint =
        '${UserHelper.baseUrl}/products/search?q=${Uri.encodeComponent(query)}&page=$page';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: endpoint,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap =
        responseData['data'] as Map<String, dynamic>? ?? responseData;

    final rawList = dataMap['products'] as List<dynamic>? ?? [];
    final products = rawList
        .map((e) => ScrapedProduct.fromJson(e as Map<String, dynamic>))
        .toList();

    BestDealInfo? bestDeal;
    if (dataMap['bestDeal'] != null) {
      bestDeal = BestDealInfo.fromJson(
        dataMap['bestDeal'] as Map<String, dynamic>,
      );
    }

    return {
      'products': products,
      'bestDeal': bestDeal,
      'totalFound': dataMap['totalFound'] ?? products.length,
    };
  }

  /// Single Product Price Comparison AI
  Future<PriceComparisonData> compareSingleProduct(String query) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';
    final endpoint =
        '${UserHelper.baseUrl}/prices/compare?q=${Uri.encodeComponent(query)}';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: endpoint,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataMap =
        responseData['data'] as Map<String, dynamic>? ?? responseData;

    return PriceComparisonData.fromJson(dataMap);
  }
}
