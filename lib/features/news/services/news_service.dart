import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';
import '../models/news_article_model.dart';

class NewsService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<List<NewsArticleModel>> fetchCityNews(String city, {String? provider}) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    String url = '${UserHelper.baseUrl}/news?city=${Uri.encodeComponent(city)}';
    if (provider != null && provider.isNotEmpty && provider != 'all') {
      url += '&provider=${Uri.encodeComponent(provider)}';
    }

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: url,
    );

    final data = response.data as Map<String, dynamic>;
    final list = data['data']?['articles'] as List<dynamic>? ?? [];

    return list
        .map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
