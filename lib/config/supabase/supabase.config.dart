import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_config.dart';

class SupabaseConfig {
  /// Initializes the Supabase singleton instance
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// Global client accessor
  static SupabaseClient get client => Supabase.instance.client;

  /// Quick helper getters
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static String? get accessToken => client.auth.currentSession?.accessToken;
  static bool get isAuthenticated => client.auth.currentUser != null;
}
