import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/secure_storage.dart';
import '../../instance/locator.dart';

class UserHelper {
  /// Returns the authenticated user's ID or falls back to 'guest_user'.
  /// Consistently checks secure storage first, then Supabase session.
  static Future<String> getCurrentUserId() async {
    try {
      final storage = getIt<CustomSecureStorage>();
      final savedId = await storage.readSecureData('userId');
      if (savedId != null && savedId.isNotEmpty) {
        return savedId;
      }
    } catch (e) {
      debugPrint('Error reading userId from storage: $e');
    }

    try {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser != null && supabaseUser.id.isNotEmpty) {
        return supabaseUser.id;
      }
    } catch (_) {}

    return 'guest_user';
  }
}
