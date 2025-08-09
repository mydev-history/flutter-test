import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final String authUrl =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_URL_AUTH_PROD']! : dotenv.env['SUPABASE_URL_AUTH_DEV']!;
    final String authAnonKey = dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_ANON_KEY_AUTH_PROD']! : dotenv.env['SUPABASE_ANON_KEY_AUTH_DEV']!;

    

    await Supabase.initialize(
      url: authUrl, // Replace with your Supabase URL
      anonKey: authAnonKey, // Replace with your Supabase anon key
    );
  }
}
