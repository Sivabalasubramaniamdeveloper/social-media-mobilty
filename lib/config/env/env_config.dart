import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('Missing SUPABASE_URL in .env file');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('Missing SUPABASE_ANON_KEY in .env file');
    }
    return key;
  }

  static String get backendBaseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:3000/api/v1';

  /// Deep link for Supabase signup confirmation emails.
  static String get emailConfirmationRedirectUri =>
      dotenv.env['SUPABASE_EMAIL_REDIRECT_URL'] ??
      Uri.parse(backendBaseUrl)
          .replace(path: '/auth/verified', query: null, fragment: null)
          .toString();

  /// Deep link for Supabase password recovery emails.
  static String get passwordRecoveryRedirectUri =>
      dotenv.env['SUPABASE_PASSWORD_REDIRECT_URL'] ??
      'mineai://auth-callback/reset-password';

  /// Call this inside main() to load the .env file
  static Future<void> init({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }
}
