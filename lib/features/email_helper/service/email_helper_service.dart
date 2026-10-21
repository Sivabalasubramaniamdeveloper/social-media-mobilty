import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';
import '../models/email_helper_model.dart';

class EmailHelperService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<EmailGenerationResult> generateEmail({
    required String instructions,
    String tone = 'Professional',
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      url: '${UserHelper.baseUrl}/email-helper/generate',
      // url: 'http://localhost:3000/api/v1/email-helper/generate',
      data: {'instructions': instructions, 'tone': tone},
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>? ?? {};
    return EmailGenerationResult.fromJson(data);
  }

  Future<SmtpStatusModel> getSmtpStatus() async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final response = await _apiService.makeApiRequest(
      method: 'GET',
      token: token,
      url: '${UserHelper.baseUrl}/email-helper/smtp-status',
      // url: 'http://localhost:3000/api/v1/email-helper/smtp-status',
    );

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>? ?? {};
    return SmtpStatusModel.fromJson(data);
  }

  Future<void> saveSmtpPassword(String appPassword) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      url: '${UserHelper.baseUrl}/email-helper/smtp-config',
      data: {'app_password': appPassword, 'key_name': 'Gmail App Password'},
    );
  }

  Future<void> sendDirectEmail({
    required String to,
    String? cc,
    required String subject,
    required String body,
  }) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    final payload = <String, dynamic>{
      'to': to,
      'subject': subject,
      'body': body,
    };
    if (cc != null && cc.trim().isNotEmpty) {
      payload['cc'] = cc.trim();
    }

    await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      // url: 'http://localhost:3000/api/v1/email-helper/send',
      url: '${UserHelper.baseUrl}/email-helper/send',
      data: payload,
    );
  }
}
