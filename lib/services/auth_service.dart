import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env variables
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['BASE_URL_PROD']! : dotenv.env['BASE_URL_DEV']!;
  final String _supabaseAnonKey = dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_ANON_KEY_PROD']! : dotenv.env['SUPABASE_ANON_KEY_DEV']!;

  /// Checks if a phone number is unique
  Future<String> isPhoneNumberUnique(String phoneNumber) async {
    final String url = '$_baseUrl/isPhoneNumberUnique';

    // Prepare request headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    // Prepare request payload
    final payload = jsonEncode({'mobile_phone': phoneNumber});
    print(payload);
    try {
      // Make the API call
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: payload,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['message'] ?? 'No message in response'; // Return the message
      } else {
        // Handle error
        print('Error: ${response.body}');
        throw Exception('Failed to check phone number uniqueness');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to make API call');
    }
  }
}
