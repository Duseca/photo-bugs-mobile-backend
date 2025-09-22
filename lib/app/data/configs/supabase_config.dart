import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase configuration
  static const String supabaseUrl = 'https://gdpxbrcrcfsvpsofsima.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkcHhicmNyY2ZzdnBzb2ZzaW1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxOTI1NTQsImV4cCI6MjA3MDc2ODU1NH0.n0Y_YKRTPdybdx1UmI-s8k3TV4zLtzzrWfcTM-lr1os';

  // Redirect URLs for OAuth
  static const String redirectUrl = 'com.example.photo_bug://callback';

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // OAuth providers
  static const Map<String, OAuthProvider> providers = {
    'google': OAuthProvider.google,
    'facebook': OAuthProvider.facebook,
    'apple': OAuthProvider.apple,
    'github': OAuthProvider.github,
  };

  // Database table names
  static const String usersTable = 'users';
  static const String photosTable = 'photos';
  static const String favoritesTable = 'user_favorites';
  static const String storageTable = 'user_storage';
}
