import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env variables
import 'package:http/http.dart' as http;

class AppService {
  final String _baseUrl =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['BASE_URL_PROD']! : dotenv.env['BASE_URL_DEV']!;
  final String _supabaseAnonKey =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_ANON_KEY_PROD']! : dotenv.env['SUPABASE_ANON_KEY_DEV']!;

  /// Fetch Categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final String url = '$_baseUrl/getCategories';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['categories']);
      } else {
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch Discount Types
  Future<List<Map<String, dynamic>>> fetchDiscountTypes() async {
    final String url = '$_baseUrl/getDiscountTypes';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['discountType']);
      } else {
        throw Exception('Failed to fetch discount types: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching discount types: $e');
    }
  }

 /// Fetch Banners
  Future<List<Map<String, dynamic>>> fetchBanners(String referenceTo) async {
    final String url = '$_baseUrl/getMarketingBanners?reference_to=$referenceTo';
     // Prepare request headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch banners: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }

   /// Send Invite (Appointment Scheduling Notification)
  Future<Map<String, dynamic>> sendInvite({
    required String vendorId,
    required String dealId,
    required String customerId,
    required String scheduledDate,
    required String scheduledTime,
    required String initiatedBy, // "vendor" or "customer"
  }) async {
    final String url = '$_baseUrl/sendInvite';
    
    // Request headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    // Request body
    final Map<String, dynamic> requestBody = {
      'vendor_id': vendorId,
      'deal_id': dealId,
      'customer_id': customerId,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'initiated_by': initiatedBy,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send invite: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending invite: $e');
    }
  }
}
