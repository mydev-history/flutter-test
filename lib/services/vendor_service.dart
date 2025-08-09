import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env variables
import 'package:http/http.dart' as http;
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_deal.dart';

class VendorService {
  final String _baseUrl =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['BASE_URL_PROD']! : dotenv.env['BASE_URL_DEV']!;
  final String _supabaseAnonKey =
      dotenv.env['ENV'] == 'prod' ? dotenv.env['SUPABASE_ANON_KEY_PROD']! : dotenv.env['SUPABASE_ANON_KEY_DEV']!;

  /// Fetches vendor details by phone number
  Future<Map<String, dynamic>> getVendorDetails(String mobilePhone) async {
    final String url = '$_baseUrl/getVendorDetails?mobile_phone=$mobilePhone';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to load vendor details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching Vendor details: $e');
    }
  }

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

  /// Add Vendor
  Future<bool> addVendor(Map<String, dynamic> vendorData) async {
    final String url = '$_baseUrl/addVendor';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_supabaseAnonKey',},
        body: jsonEncode(vendorData),
      );

      if (response.statusCode == 200) {
        return true; // Successfully added vendor
      } else {
        throw Exception('Failed to add vendor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding vendor: $e');
    }
  }

  /// Update Vendor Details
  Future<bool> updateVendorDetails(Map<String, dynamic> updatedData) async {
    final String url = '$_baseUrl/updateVendorDetails';
    print(url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        return true; // Update was successful
      } else {
        throw Exception('Failed to update vendor details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating vendor details: $e');
    }
  }

  /// Fetch vendor deals
  Future<List<VendorDeal>> fetchVendorDeals(String vendorId) async {
    final String url = '$_baseUrl/getVendorDeals?vendor_id=$vendorId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final dealsList = responseData['deals'] as List<dynamic>;
        return dealsList.map((deal) => VendorDeal.fromJson(deal)).toList();
      } else {
        throw Exception('Failed to fetch vendor deals: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching vendor deals: $e');
    }
  }
  
   /// ✅ Fetch Deal Details (For Vendor Deal Details Page)
  Future<Map<String, dynamic>> getDealDetail(String dealId) async {
    final String url = '$_baseUrl/getDealDetail?deal_id=$dealId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"]; // ✅ Returning only deal details
      } else {
        throw Exception('Failed to fetch deal details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching deal details: $e');
    }
  }

    /// ✅ Pause or Resume a Deal
  Future<bool> pauseResumeDeal(String dealId, String action) async {
    final String url = '$_baseUrl/pauseResumeDeal';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    final body = jsonEncode({
      "deal_id": dealId,
      "action": action, // "pause" or "resume"
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return true; // ✅ Successfully paused/resumed deal
      } else {
        throw Exception('Failed to update deal status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating deal status: $e');
    }
  }

 /// ✅ Pause or Resume a Deal
  Future<bool> deactivateDeal(String dealId) async {
    final String url = '$_baseUrl/deactivateDeal';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    final body = jsonEncode({
      "deal_id": dealId,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        return true; // ✅ Successfully paused/resumed deal
      } else {
        throw Exception('Failed to deactivate deal status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deactivating deal status: $e');
    }
  }

  /// ✅ Fetch Store Locations by Vendor ID
  Future<List<Map<String, dynamic>>> fetchStoreLocations(String vendorId) async {
    final String url = '$_baseUrl/getStoreLocations?vendor_id=$vendorId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['storeLocations']);
      } else {
        throw Exception('Failed to fetch store locations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching store locations: $e');
    }
  }

  /// ✅ Add New Deal API
Future<String> addDeal(Map<String, dynamic> dealData) async {
  final String url = '$_baseUrl/addDeal';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(dealData),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return response.body; // ✅ Deal successfully added
    } else {
      print(response.body);
      throw Exception('Failed to add deal: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error adding deal: $e');
  }
}

  updateDeal(Map<String, dynamic> dealPayload) {}

  /// ✅ Validate QR Code API (Redeem Coupon)
Future<bool> validateQrCode({required String qrCode, required String vendorId}) async {
  final String url = '$_baseUrl/validateQrCode';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  final body = jsonEncode({
    "qr_code": qrCode,
    "vendor_id": vendorId,
  });

  print(body);
  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return true; // ✅ Successfully redeemed coupon
    } else {
      throw Exception('Failed to redeem coupon: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error redeeming coupon: $e');
  }
}

/// Fetches all reviews for a given deal and customer
  Future<Map<String, dynamic>> getVendorReviews(String dealId) async {
    final String url = '$_baseUrl/getVendorReviews?deal_id=$dealId';

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

  /// ✅ Vendor Reply API (Updates a review with vendor's response)
Future<void> vendorReplay(String reviewId, String vendorReplay) async {
  final String url = '$_baseUrl/vendorReplays';

  final headers = {
    'Authorization': 'Bearer $_supabaseAnonKey',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "review_id": reviewId,
    "vendor_replay": vendorReplay,
  });

  try {
    final response = await http.put(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Vendor reply updated successfully.");
    } else {
      throw Exception('Failed to update vendor reply: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error updating vendor reply: $e');
  }
}


  /// Fetches vendor notifications
  Future<List<Map<String, dynamic>>> fetchvendorNotifications(String vendorId) async {
    final String url = '$_baseUrl/getNotfications?vendor_id=$vendorId';

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

  Future<int> getUnreadNotificationsCount(String vendorId) async {
  final String url = '$_baseUrl/getNotficationsCount?vendor_id=$vendorId';

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
  Future<bool> markNotificationsAsRead(String vendorId) async {
    final String url = '$_baseUrl/markNotificationsAsRead';

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'vendor_id': vendorId});

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

   /// Fetch Store Locations by Vendor ID
  Future<List<StoreLocation>> getStoreLocations(String vendorId) async {
    final String url = '$_baseUrl/getStoreLocations?vendor_id=$vendorId';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<StoreLocation>.from(
            data['storeLocations'].map((location) => StoreLocation.fromJson(location)));
      } else {
        throw Exception('Failed to fetch store locations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching store locations: $e');
    }
  }

   /// ✅ Add a New Store Location
  Future<bool> addStoreLocation(Map<String, dynamic> storeData) async {
    final String url = '$_baseUrl/addStoreLocations';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(storeData));

      if (response.statusCode == 200) {
        return true; // ✅ Store added successfully
      } else {
        throw Exception('Failed to add store: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding store: $e');
    }
  }

  /// ✅ Edit an Existing Store Location
  Future<bool> editStoreLocation(Map<String, dynamic> storeData) async {
    final String url = '$_baseUrl/editStoreLocations';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    try {
      final response = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(storeData));

      if (response.statusCode == 200) {
        return true; // ✅ Store updated successfully
      } else {
        throw Exception('Failed to update store: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating store: $e');
    }
  }

   /// ✅ Delete a Store Location
  Future<bool> deleteStoreLocation(String vendorId, String locationId) async {
    final String url = '$_baseUrl/deleteVendorLocation';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_supabaseAnonKey',
    };

    final body = jsonEncode({
      "vendor_id": vendorId,
      "location_id": locationId,
    });

    try {
      final response =
          await http.delete(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        // Optionally, you can parse response.body to verify the message.
        return true;
      } else {
        throw Exception('Failed to delete store location: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting store location: $e');
    }
  }

  /// ✅ Fetch Vendor Schedules
Future<List<Map<String, dynamic>>> getVendorSchedules(String vendorId, {String? dealId}) async {
  final String url = dealId != null
      ? '${_baseUrl}getVendorSchedule?vendor_id=$vendorId&deal_id=$dealId'
      : '${_baseUrl}getVendorSchedule?vendor_id=$vendorId';

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to fetch vendor schedules: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching vendor schedules: $e');
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
  Future<Map<String, dynamic>> insertVendorTransaction({
    required String transactionId,
    required String vendorId,
    required String dealId,
    required String transactionType,
    required String status,
    required double amount,
  }) async {
    final String url = '$_baseUrl/insertVendorTransaction'; // Replace with your deployed function URL

    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "transaction_id": transactionId,
      "vendor_id": vendorId,
      "deal_id": dealId,
      "transaction_type": transactionType,
      "status": status,
      "amount": amount
    });
    print(body);

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
