import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env variables
import 'package:http/http.dart' as http;

class CustomerService {
  final String _baseUrl =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['BASE_URL_PROD']! : dotenv.env['BASE_URL_DEV']!;
  final String _supabaseAnonKey =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_ANON_KEY_PROD']! : dotenv.env['SUPABASE_ANON_KEY_DEV']!;

  /// Fetches customer details by phone number
  Future<Map<String, dynamic>> getCustomerDetails(String mobilePhone) async {
    final String url = '$_baseUrl/getCustomerDetails?mobile_phone=$mobilePhone';
    print(url);
    // Prepare request headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // Check for successful response
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; // Return the customer data
      } else {
        // Handle API errors
        throw Exception('Failed to load customer details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching customer details: $e');
    }
  }

   /// Registers a new customer
  Future<bool> addCustomer(Map<String, dynamic> customerData) async {
    final String url = '$_baseUrl/addCustomer';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(customerData));

      if (response.statusCode == 200) {
        return true; // Registration successful
      } else {
        throw Exception('Failed to add customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding customer: $e');
    }
  }

  /// Updates customer details
  Future<bool> editCustomer(String customerId, Map<String, dynamic> updates) async {
    final String url = '$_baseUrl/editCustomer';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    final body = {
      'customer_id': customerId,
      'updates': updates,
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to edit customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error editing customer: $e');
    }
  }
  
  /// Fetches deals by customer zip code
Future<List<Map<String, dynamic>>> fetchDeals(String zipCode, String customerId) async {
  final String url = '$_baseUrl/searchDeals?zipcode=$zipCode&customer_id=$customerId';

  final headers = {
    'Authorization': 'Bearer $_supabaseAnonKey',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("totalDealRating");
      return List<Map<String, dynamic>>.from(data['data']['deals']);
    } else {
      throw Exception('Failed to fetch deals: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching deals: $e');
  }
}

/// Generates a coupon for a customer
  Future<Map<String, dynamic>> generateCoupon(String customerId, String dealId) async {
    final String url = '$_baseUrl/generateCoupon';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'customer_id': customerId,
      'deal_id': dealId,
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate coupon: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating coupon: $e');
    }
  }

   /// Fetches coupons for a customer
  Future<List<Map<String, dynamic>>> fetchCoupons(String customerId) async {
    final String url = '$_baseUrl/getCoupons?customer_id=$customerId';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    print("Inside Coupons");
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['coupons']);
      } else {
        throw Exception('Failed to fetch coupons: ${response.body}');
      }
    } catch (e) {
      print(e);
      throw Exception('Error fetching coupons: $e');
    }
  }

  /// Cancel a coupon for a customer
  Future<Map<String, dynamic>> cancelCoupon(String qrCode) async {
    final String url = '$_baseUrl/cancelCoupon';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'qr_code': qrCode,
    };

    print(body);
    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to cancel coupon: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error canceclling coupon: $e');
    }
  }

  /// Submits a review for a deal
  Future<Map<String, dynamic>> submitReview(
      String customerId, String dealId, int rating, String feedback) async {
    final String url = '$_baseUrl/addReview';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'customer_id': customerId,
      'deal_id': dealId,
      'rating': rating,
      'feedback': feedback,
    };

    print(body);

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
         print(response.body);
        return jsonDecode(response.body);
       
      } else {
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
       print(e);
      throw Exception('Error submitting review: $e');
    }
  }

   /// Fetches all reviews for a given deal and customer
  Future<Map<String, dynamic>> getCustomerReviews(String customerId, String dealId) async {
    final String url = '$_baseUrl/getCustomerReview?customer_id=$customerId&deal_id=$dealId';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch customer reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching customer reviews: $e');
    }
  }

    /// Edits an existing review
  Future<Map<String, dynamic>> editReview(String reviewId, int rating, {String? feedback, String? imageUrl}) async {
    print("Inside Edit");
    final String url = '$_baseUrl/editReview';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'review_id': reviewId,
      'rating': rating,
    };

    if (feedback != null) body['feedback'] = feedback;
    if (imageUrl != null) body['image_url'] = imageUrl;

    try {
      final response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to edit review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error editing review: $e');
    }
  }

  /// Deletes a review
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    final String url = '$_baseUrl/deleteReview';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'review_id': reviewId,
    };

    try {
      final response = await http.delete(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  /// Submits a review for a deal
  Future<Map<String, dynamic>> userFavorites(
      String customerId, String dealId) async {
    final String url = '$_baseUrl/userFavorites';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'customer_id': customerId,
      'deal_id': dealId,
    };

    print(body);

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          print("Full API Response: ${jsonEncode(data)}"); // Debugging: Print full response
        //  print(response.body);
        return jsonDecode(response.body);
       
      } else {
        throw Exception('Failed to submit favorites: ${response.body}');
      }
    } catch (e) {
       print(e);
      throw Exception('Error submitting favorites: $e');
    }
  }

  /// Fetches customer notifications
  Future<List<Map<String, dynamic>>> fetchCustomerNotifications(String customerId) async {
    final String url = '$_baseUrl/getNotfications?customer_id=$customerId';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch notifications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<int> getUnreadNotificationsCount(String customerId) async {
  final String url = '$_baseUrl/getNotficationsCount?customer_id=$customerId';

  final headers = {
    'Authorization': 'Bearer $_supabaseAnonKey',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unread_count'] ?? 0;
    } else {
      throw Exception('Failed to fetch unread notifications count: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching unread notifications count: $e');
  }
}

/// ✅ Marks all notifications as read
  Future<bool> markNotificationsAsRead(String customerId) async {
    final String url = '$_baseUrl/markNotificationsAsRead';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'customer_id': customerId});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['success'] == true;
      } else {
        throw Exception('Failed to mark notifications as read: ${response.body}');
      }
    } catch (e) {
      print("Error marking notifications as read: $e");
      return false;
    }
  }

   /// ✅ Fetch Customer Schedules
Future<List<Map<String, dynamic>>> getCustomerSchedules(String customerId, {String? dealId}) async {
  final String url = dealId != null
      ? '${_baseUrl}getCustomerSchedule?customer_id=$customerId&deal_id=$dealId'
      : '${_baseUrl}getCustomerSchedule?customer_id=$customerId';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to fetch customer schedules: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching customer schedules: $e');
  }
}

/// ✅ Process Payment & Get Transaction Details
  Future<Map<String, dynamic>> processPayment(String customerId, double amount) async {
    final String url = '$_baseUrl/couponPayment';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'customer_id': customerId,
      'amount': amount,
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to process payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }

  /// ✅ Create Payment Intent & Get Client Secret
  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    final String url = '$_baseUrl/paymentIntent';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'amount': amount,
      'currency': 'usd',
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  /// **✅ Inserts Customer Payment Transaction into Supabase**
  Future<Map<String, dynamic>> insertCustomerTransaction({
    required String transactionId,
    required String customerId,
    required String couponId,
    required String transactionType,
    required String status,
  }) async {
    final String url = '$_baseUrl/insertCustomerTransaction'; // Replace with your deployed function URL

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "transaction_id": transactionId,
      "customer_id": customerId,
      "coupon_id": couponId,
      "transaction_type": transactionType,
      "status": status,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to insert transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error inserting transaction: $e');
    }
  }

}
