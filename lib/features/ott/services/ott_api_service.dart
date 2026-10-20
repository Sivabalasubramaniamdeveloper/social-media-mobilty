import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/logger/app_logger.dart';
import '../../../core/utils/user_helper.dart';
import '../models/ott_video.dart';

class OttApiService {
  Future<List<OttVideo>> getVideos({String? accessToken}) async {
    final url = Uri.parse('${UserHelper.baseUrl}/ott/videos');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      CustomAppLogger.debug('OTT API URL: $url - status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'OTT API failed (${response.statusCode}): ${response.body}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Invalid OTT API response');
      }

      final items = body['data'] as List<dynamic>;

      return items
          .map((item) => OttVideo.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error, stack) {
      CustomAppLogger.error('OTT API error: $error', error, stack);
      rethrow;
    }
  }
}
