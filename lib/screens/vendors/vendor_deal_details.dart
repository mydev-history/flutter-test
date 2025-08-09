// ignore_for_file: library_private_types_in_public_api

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/config/theme.dart';
import 'package:wah_frontend_flutter/screens/chat_room.dart';
import 'package:wah_frontend_flutter/screens/schedule_appointment.dart';
import 'package:wah_frontend_flutter/screens/vendors/edit_deal.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:intl/intl.dart';

class VendorDealDetails extends StatefulWidget {
  final String dealId;

  const VendorDealDetails({Key? key, required this.dealId}) : super(key: key);

  @override
  _VendorDealDetailsState createState() => _VendorDealDetailsState();
}

class _VendorDealDetailsState extends State<VendorDealDetails> {
  final VendorService _vendorService = VendorService();
  Map<String, dynamic>? dealDetails;
  bool isLoading = true;
  String? errorMessage;
  int _currentIndex = 0; // For carousel indicator
  bool _isFetchingReviews = true;
  double _rating = 0;
  // Review Data
  Map<String, dynamic>? _reviewsData;

  String? _selectedReviewId; // Stores the review ID for reply mode
  TextEditingController _replyController = TextEditingController(); // Handles the reply input


  @override
  void initState() {
    super.initState();
    fetchDealDetails();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isFetchingReviews = true);
    try {
      final response = await _vendorService.getVendorReviews(
        widget.dealId,
      );
      print(response);
      setState(() => _reviewsData = response);
      _rating = _reviewsData!['totalRating'];
      print(_rating);
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      setState(() => _isFetchingReviews = false);
    }
  }

  /// ✅ FORMAT DATE FUNCTION
  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// ✅ Fetch Deal Details
  Future<void> fetchDealDetails() async {
    try {
      final details = await _vendorService.getDealDetail(widget.dealId);
      setState(() {
        dealDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching deal details: $e";
        isLoading = false;
      });
    }
  }

   /// ✅ Group customers by email and count their generated coupons
// List<Map<String, dynamic>> getGroupedCustomers() {
//   if (dealDetails == null || !dealDetails!.containsKey('customerDetails')) return [];

//   List<Map<String, dynamic>> customerDetails = List<Map<String, dynamic>>.from(dealDetails!['customerDetails']);

//   Map<String, Map<String, dynamic>> groupedCustomers = {};

//   for (var entry in customerDetails) {
//     String status = entry['status'].toLowerCase();
    
//     // Only include "active" and "redeemed" customers
//     if (status == "active" || status == "redeemed") {
//       String email = entry['customer']['email_id'];
//       String firstName = entry['customer']['first_name'] ?? "Unknown";
//       String lastName = entry['customer']['last_name'] ?? "";
//       String formattedDate = formatDate(entry['created_at']);

//       if (groupedCustomers.containsKey(email)) {
//         groupedCustomers[email]!['coupon_count'] += 1;
//       } else {
//         groupedCustomers[email] = {
//           'email': email,
//           'name': "$firstName $lastName",
//           'date': formattedDate,
//           'status': status,
//           'coupon_count': 1
//         };
//       }
//     }
//   }

//   return groupedCustomers.values.toList();
// }

List<Map<String, dynamic>> getGroupedCustomers() {
  if (dealDetails == null || !dealDetails!.containsKey('customerDetails')) return [];

  List<Map<String, dynamic>> customerDetails = List<Map<String, dynamic>>.from(dealDetails!['customerDetails']);

  Map<String, Map<String, dynamic>> groupedCustomers = {};

  for (var entry in customerDetails) {
    String status = entry['status'].toLowerCase();
    
    // Only include "active" and "redeemed" customers
    if (status == "active" || status == "redeemed") {
      String email = entry['customer']['email_id'];
      String firstName = entry['customer']['first_name'] ?? "Unknown";
      String lastName = entry['customer']['last_name'] ?? "";
      String formattedDate = formatDate(entry['created_at']);
      String customerId = entry['customer']['customer_id'] ?? ""; // ✅ Extract customer_id

      if (groupedCustomers.containsKey(email)) {
        groupedCustomers[email]!['coupon_count'] += 1;
      } else {
        groupedCustomers[email] = {
          'email': email,
          'name': "$firstName $lastName",
          'date': formattedDate,
          'status': status,
          'customer_id': customerId, // ✅ Include customer_id
          'coupon_count': 1
        };
      }
    }
  }

  return groupedCustomers.values.toList();
}



  /// ✅ Get Status Color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "active":
        return Colors.green;
      case "inactive":
        return Colors.red;
      case "paused":
      case "under review":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

   /// ✅ Function to Handle Deal Pause/Resume
void handlePauseResume() async {
  String currentStatus = dealDetails!['deal_status'].toLowerCase();
  String action = currentStatus == "active" ? "pause" : "resume";
  String buttonText = action == "pause" ? "Pause" : "Resume";

  bool? confirmed = await showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (context) {
      return PopUp(
        message: "Type '${dealDetails!['deal_id'].split("_")[1]}' to confirm $buttonText this deal.",
        icon: "assets/pause.png",
        isCancel: true,
        mainButtonText: buttonText, // ✅ Dynamic button text
        isConfirmationRequired: true,
        confirmationText: dealDetails!['deal_id'].split("_")[1],
      );
    },
  );
  

  if (confirmed == true) {
    try {
      bool success = await _vendorService.pauseResumeDeal(dealDetails!['deal_id'], action);

      if (success) {
        _showSuccessPopup(context, "Deal ${buttonText}d successfully!");
        fetchDealDetails(); // ✅ Refresh deal details after action
      }
    } catch (e) {
      _showFailurePopup(context, "Deal ${buttonText}d unsuccessful, Please try again later");
    }
  }
}

Future<void> _showSuccessPopup(BuildContext context, String message) async {
  bool? isClosed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return  PopUp(
        message: message,
        icon: "assets/success.png",
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );
}


Future<void> _showFailurePopup(BuildContext context, String message) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return  PopUp(
        message: message,
        icon: "assets/close.png", // Provide the actual success icon path
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );
}

Future<void> _submitVendorReply(String reviewId) async {
  try {
    await _vendorService.vendorReplay(reviewId, _replyController.text);
    setState(() {
      _selectedReviewId = null;
      _replyController.clear();
      _fetchReviews(); // Refresh Reviews After Submission
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reply submitted successfully!")),
    );
  } catch (e) {
    print("Error submitting reply: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit reply. Please try again.")),
    );
  }
}

Future<void> navigateToChatRoomForCustomer(String customerId, String customerName) async {
  final vendorId = dealDetails!['vendor_id'];
  final dealId = dealDetails!['deal_id'];

  if (customerId.isEmpty || vendorId.isEmpty) {
    print("❌ Missing Customer or Vendor ID");
    return;
  }

  print("🟢 Checking for existing chat session: Vendor: $vendorId, Customer: $customerId, Deal: $dealId");

  try {
    String? chatId;

    // ✅ Query ChatSession ensuring participant_1 or participant_2 can be customer/vendor with the SAME deal_id
    final response = await Supabase.instance.client
        .from("ChatSession")
        .select("chat_id")
        .or([
          "participant_1.eq.$customerId,participant_2.eq.$vendorId",
          "participant_1.eq.$vendorId,participant_2.eq.$customerId"
        ].join(","))
        .eq("deal_id", dealId)  // ✅ Ensure only the chat with the given deal_id is selected
        .limit(1) // ✅ Prevent multiple rows error
        .maybeSingle(); // ✅ Returns null if no matching session is found

    if (response != null && response["chat_id"] != null) {
      chatId = response["chat_id"];
      print("✅ Existing chat session found: $chatId");
    } else {
      print("⚡ No chat session found. Navigating to an empty chat room.");
    }

    // ✅ Navigate to Chat Room
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoom(
          chatId: chatId ?? "", // If empty, ChatRoom knows it's a new session
          participantName: customerName,
          participantAvatar: null, // Customer may not have an avatar
          receiver_id: customerId,
          sender_id: vendorId,
          dealId: dealId, // Pass deal ID to create a session if needed
        ),
      ),
    );
  } catch (error) {
    print("❌ Error checking chat session: $error");
  }
}



  /// ✅ Function to Handle Deal Deactivate
void handleDeactivate() async {
  // String currentStatus = dealDetails!['deal_status'].toLowerCase();
  // String action = currentStatus == "active" ? "pause" : "resume";
  // String buttonText = action == "pause" ? "Pause" : "Resume";

  bool? confirmed = await showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (context) {
      return PopUp(
        message: "Type '${dealDetails!['deal_id'].split("_")[1]}' to confirm to deactivate this deal.",
        icon: "assets/deactivate.png",
        isCancel: true,
        mainButtonText: "Deactivate", // ✅ Dynamic button text
        isConfirmationRequired: true,
        confirmationText: dealDetails!['deal_id'].split("_")[1],
      );
    },
  );
  

  if (confirmed == true) {
    try {
      bool success = await _vendorService.deactivateDeal(dealDetails!['deal_id']);

      if (success) {
         _showSuccessPopup(context, "Deal deactivated successfully!");
        fetchDealDetails(); // ✅ Refresh deal details after action
      }
    } catch (e) {
      print(e);
      _showFailurePopup(context, "Deal deactivation unsuccessful");
    }
  }
}



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : dealDetails == null
                  ? Center(child: Text("No deal details found"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ IMAGE CAROUSEL WITH ICONS
                        Stack(
                          children: [
                            // ✅ Image Carousel
                            SizedBox(
                              height: screenHeight * 0.5, // Responsive height
                              width: screenWidth,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: screenHeight * 0.5,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                                items: dealDetails!['images'].map<Widget>((image) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(screenWidth * 0.05)),
                                    child: Image.network(
                                      image['image_url'],
                                      fit: BoxFit.cover,
                                      width: screenWidth,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                           Positioned(
                              top: screenHeight * 0.06,
                              left: screenWidth * 0.04,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.8),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.black),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            Positioned(
                              top: screenHeight * 0.06,
                              right: screenWidth * 0.04,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white.withOpacity(0.8),
                                    child: Icon(Icons.share, color: Colors.black),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditDeal(dealId: dealDetails!['deal_id']), // Pass dealId
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(0.8),
                                      child: Icon(Icons.edit, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),


                            // ✅ Status Banner
                            Positioned(
                              bottom: screenHeight * 0.02,
                              left: screenWidth * 0.04,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03, vertical: screenHeight * 0.005),
                                decoration: BoxDecoration(
                                  color: getStatusColor(dealDetails!['deal_status']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  dealDetails!['deal_status'].toUpperCase(),
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: screenHeight * 0.02),

                        /// ✅ DEAL INFORMATION SECTION
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Deal ID
                              Text(
                                "Deal ID: ${dealDetails!['deal_id'].split("_")[1]}",
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.hintTextColor,
                                  fontSize: screenWidth * 0.03
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.005),

                              // ✅ Deal Title
                              Text(
                                dealDetails!['deal_title'],
                                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.005),

                              // ✅ Pricing Row
                              Row(
                                children: [
                                  Text(
                                    "\$${dealDetails!['wah_price']}",
                                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "\$${dealDetails!['regular_price']}",
                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "${dealDetails!['discount_value']}% OFF",
                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.01),

                              // ✅ Coupon Info & Rating (Conditionally displayed)
                              Row(
                                children: [
                                  if (dealDetails!.containsKey('totalCouponsGenerated'))
                                    Text(
                                      "${dealDetails!['coupon_remaining_count']} Coupons Left",
                                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                                    ),
                                  SizedBox(width: screenWidth * 0.02),
                                  if (dealDetails!.containsKey('rating'))
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: AppTheme.primaryColor, size: screenWidth * 0.04),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          dealDetails!['rating'].toString(),
                                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ✅ Social Media Icons
                              Row(
                                children: [
                                  Image.asset('assets/insta.png', width: screenWidth * 0.05),
                                  SizedBox(width: screenWidth * 0.02),
                                  Image.asset('assets/facebook.png', width: screenWidth * 0.05),
                                  SizedBox(width: screenWidth * 0.02),
                                  Image.asset('assets/web.png', width: screenWidth * 0.05),
                                ],


                              ),
                              SizedBox(height: screenHeight * 0.03),

                                /// ✅ DEAL PERFORMANCE SECTION
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                     _buildPerformanceCard('Expiry', formatDate(dealDetails!['available_to']), 'assets/expiry.png', screenHeight, screenWidth),
                                    _buildPerformanceCard('Generated', dealDetails!['totalCouponsGenerated'].toString(), 'assets/published.png', screenHeight, screenWidth),
                                    _buildPerformanceCard('Redeemed', dealDetails!['totalCouponsRedeemed'].toString(), 'assets/published.png', screenHeight, screenWidth),
                                    _buildPerformanceCard('Revenue', "\$${dealDetails!['totalRevenueGenerated']}", 'assets/revenue.png', screenHeight, screenWidth),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.04),
                                // ✅ DEAL ACTION BUTTONS (Shown only if the deal is Active or Paused)
                                if (dealDetails!['deal_status'].toLowerCase() == "active" || 
                                    dealDetails!['deal_status'].toLowerCase() == "paused")
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 🔴 Deactivate Button
                                        Expanded(
                                          child: SizedBox(
                                            height: screenHeight * 0.06, // Ensuring same height for both buttons
                                            child: OutlinedButton(
                                              onPressed: handleDeactivate,
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.red, width: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                "Deactivate",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: screenWidth * 0.05),

                                        // 🟡 Pause/Resume Button
                                        Expanded(
                                          child: SizedBox(
                                            height: screenHeight * 0.06, // Ensuring same height for both buttons
                                            child: ElevatedButton(
                                              onPressed: handlePauseResume, // ✅ Calls pause handler
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                dealDetails!['deal_status'].toLowerCase() == "active" ? "Pause" : "Resume",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.04),
                             /// ✅ Coupons Generated By Section
                              if (dealDetails != null &&
                                  dealDetails!.containsKey('customerDetails') &&
                                  dealDetails!['customerDetails'] != null &&
                                  dealDetails!['customerDetails'].isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// ✅ Heading & Filter Icon in the Same Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Coupons Generated by",
                                            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth*0.04
                                            ),
                                          ),
                                          Icon(Icons.filter_alt_outlined, color: Colors.black), // Filter Icon
                                        ],
                                      ),

                                      SizedBox(height: screenHeight * 0.02),

                                      /// ✅ Customer List Container (Max 3 Customers)
                                      Container(
                                        padding: EdgeInsets.all(screenWidth * 0.04),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 5,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: getGroupedCustomers().take(3).map((customer) {
                                            return _buildCustomerTile(customer, screenWidth, screenHeight);
                                          }).toList(),
                                        ),
                                      ),

                                      SizedBox(height: screenHeight * 0.02),

                                      /// ✅ View All Customers Link (Only if more than 3 exist)
                                      if (getGroupedCustomers().length > 3)
                                        InkWell(
                                          onTap: () {
                                            // TODO: Navigate to full customer list screen
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "View All ${dealDetails!['totalCouponsGenerated']} generated customers",
                                                style: const TextStyle(
                                                  color: AppTheme.secondaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryColor, size: 14),
                                            ],
                                          ),
                                        ),

                                      SizedBox(height: screenHeight * 0.02),
                                    ],
                                  ),
                                ),

                                // Combined Deal Description and Terms
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Deal Description
                                      Text(
                                        "Deal Description",
                                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.04),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        dealDetails!["deal_description"],
                                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                                      ),
                                      const Divider(
                                        thickness: 0.1,
                                        height: 32,
                                      ),
                                      // Deal Terms and Conditions
                                      Text(
                                        "Deal Terms and Conditions",
                                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.04),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        dealDetails!["terms_and_conditions"],
                                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),

                                // 📌 Reviews & Ratings Section
                                if (!_isFetchingReviews && _reviewsData != null)
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ✅ Header
                                      Padding(
                                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                                        child: Text(
                                          "Ratings & Reviews (${_reviewsData!['totalReviewCount']})",
                                          style: AppTheme.lightTheme.textTheme.titleLarge,
                                        ),
                                      ),
                                      Divider(
                                        thickness: screenHeight * 0.001,
                                        color: Colors.black.withOpacity(0.2),
                                      ),

                                      // ✅ Overall Rating
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                        child: Row(
                                          children: [
                                            Text(
                                              "${_reviewsData!['totalRating']}/5",
                                              style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Overall Rating", style: AppTheme.lightTheme.textTheme.titleMedium),
                                                Text(
                                                  "${_reviewsData!['totalReviewCount']} Ratings",
                                                  style: AppTheme.lightTheme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ✅ Handle case when there are no reviews
                                      if (_reviewsData!['customerReviews'] == null || _reviewsData!['customerReviews'].isEmpty)
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                          child: Center(
                                            child: Text(
                                              "No reviews yet.",
                                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        // ✅ Display Customer Reviews
                                        Column(
                                          children: List.generate(_reviewsData!['customerReviews'].length, (index) {
                                            var review = _reviewsData!['customerReviews'][index];

                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // ✅ Review Title
                                                  Text(
                                                    review['customerName'],
                                                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(height: screenHeight * 0.005),

                                                  // ✅ Star Rating
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (starIndex) => Icon(
                                                        Icons.star,
                                                        color: starIndex < (review['customerRating'])
                                                            ? AppTheme.lightTheme.colorScheme.primary
                                                            : Colors.grey,
                                                        size: screenWidth * 0.06,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: screenHeight * 0.01),

                                                  // ✅ Review Content
                                                  Text(
                                                    review['customerReview'] ?? "No review message",
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                                                  ),
                                                  SizedBox(height: screenHeight * 0.02),

                                                  // ✅ Reviewer Info
                                                  Text(
                                                    "${review['customerName']}, ${review['createdAt']}",
                                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(height: screenHeight * 0.02),

                                                  // ✅ Vendor Reply Section
                                                  if (review['vendorReplay'] != null && review['vendorReplay'].isNotEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                                                      child: Text(
                                                        "Vendor Reply: ${review['vendorReplay']}",
                                                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                                          fontStyle: FontStyle.italic,
                                                          color: AppTheme.lightTheme.colorScheme.onBackground,
                                                        ),
                                                      ),
                                                    ),

                                                  // ✅ Reply Button
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _selectedReviewId = review['reviewId'];
                                                        _replyController.text = review['vendorReplay'] ?? "";
                                                      });
                                                    },
                                                    child: Text(
                                                      review['vendorReplay'] != null && review['vendorReplay'].isNotEmpty
                                                          ? "Edit Reply"
                                                          : "Reply",
                                                      style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
                                                    ),
                                                  ),

                                                  // ✅ Vendor Reply Input Field
                                                  if (_selectedReviewId == review['reviewId'])
                                                    Column(
                                                      children: [
                                                        TextField(
                                                          controller: _replyController,
                                                          maxLines: 3,
                                                          decoration: InputDecoration(
                                                            hintText: "Write your reply...",
                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                          ),
                                                        ),
                                                        SizedBox(height: screenHeight * 0.01),

                                                        // ✅ Submit Reply Button
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            await _submitVendorReply(review['reviewId']);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                                                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                            minimumSize: Size(double.infinity, screenHeight * 0.06),
                                                          ),
                                                          child: Text("Submit Reply"),
                                                        ),
                                                      ],
                                                    ),
                                                  Divider(color: Colors.black.withOpacity(0.2), thickness: screenHeight * 0.001),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                    ],
                                  ),
                                ),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  /// ✅ CUSTOMER TILE WIDGET
  // Widget _buildCustomerTile(Map<String, dynamic>? customer, double screenWidth, double screenHeight) {
  //   if (customer == null) {
  //     return SizedBox(); // If the customer object is null, return an empty widget
  //   }

  //   bool isRedeemed = customer['status'] == 'redeemed';
  //   String name = customer['name'] ?? "Unknown";
  //   String formattedDate = customer['date'] ?? "N/A";
  //   int couponCount = customer['coupon_count'] ?? 1;

  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
  //     // padding: EdgeInsets.all(screenWidth * 0.04),
  //     // decoration: BoxDecoration(
  //     //   color: Colors.white,
  //     //   borderRadius: BorderRadius.circular(12),
  //     //   boxShadow: [
  //     //     BoxShadow(
  //     //       color: Colors.grey.shade200,
  //     //       blurRadius: 5,
  //     //       spreadRadius: 2,
  //     //     ),
  //     //   ],
  //     // ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         /// ✅ Status Indicator (Active = Red, Redeemed = Green)
  //         Container(
  //           width: screenWidth * 0.02,
  //           height: screenHeight * 0.06,
  //           decoration: BoxDecoration(
  //             color: isRedeemed ? Colors.green : Colors.red,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),

  //         SizedBox(width: screenWidth * 0.04), // Spacing

  //         /// ✅ Customer Details
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 name,
  //                 style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               SizedBox(height: screenHeight * 0.002),
  //               Text(
  //                 "$formattedDate ${couponCount > 1 ? '($couponCount coupons)' : ''}",
  //                 style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
  //                   color: AppTheme.hintTextColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         /// ✅ Schedule and Chat Icons (Only show Schedule if `enable_scheduling` is true)
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             if (dealDetails?['enable_scheduling'] == true)
  //               Padding(
  //                 padding: EdgeInsets.only(right: screenWidth * 0.02),
  //                 child: Image.asset('assets/schedule.png', width: screenWidth * 0.06),
  //               ),
  //             Image.asset('assets/chat_color.png', width: screenWidth * 0.06),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

 /// ✅ CUSTOMER TILE WIDGET
  Widget _buildCustomerTile(Map<String, dynamic>? customer, double screenWidth, double screenHeight) {
    if (customer == null) {
      return SizedBox(); // If the customer object is null, return an empty widget
    }

    bool isRedeemed = customer['status'] == 'redeemed';
    String name = customer['name'] ?? "Unknown";
    String formattedDate = customer['date'] ?? "N/A";
    int couponCount = customer['coupon_count'] ?? 1;
    String customerId = customer['customer_id'] ?? ""; // ✅ Extract customer_id

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ✅ Status Indicator (Active = Red, Redeemed = Green)
          Container(
            width: screenWidth * 0.02,
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              color: isRedeemed ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          SizedBox(width: screenWidth * 0.04), // Spacing

          /// ✅ Customer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.002),
                Text(
                  "$formattedDate ${couponCount > 1 ? '($couponCount coupons)' : ''}",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.hintTextColor,
                  ),
                ),
              ],
            ),
          ),

          /// ✅ Schedule and Chat Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (dealDetails?['enable_scheduling'] == true)
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.02),
                  child: GestureDetector(
                    onTap: () {
                      if (customerId.isNotEmpty && dealDetails!['vendor_id'].isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleAppointmentPage(
                              vendorId: dealDetails!['vendor_id'],
                              customerId: customerId,
                              dealId: dealDetails!['deal_id'],
                              initiatedBy: "vendor",
                              vendorAcceptance: true,
                              customerName: name,
                            ),
                          ),
                        );
                      } else {
                        print("❌ Vendor ID or Customer ID is missing!");
                      }
                    },
                    child: Image.asset(
                      'assets/schedule.png',
                      width: screenWidth * 0.06,
                    ),
                  ),
                ),

              /// ✅ Chat Icon (Navigates to Chat Room)
              GestureDetector(
                onTap: () {
                  if (customerId.isNotEmpty) {
                    navigateToChatRoomForCustomer(customerId, name);
                  } else {
                    print("❌ Customer ID missing!");
                  }
                },
                child: Image.asset(
                  'assets/chat_color.png',
                  width: screenWidth * 0.06,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

   /// ✅ PERFORMANCE CARD WIDGET
  Widget _buildPerformanceCard(String title, String value, String asset, double screenHeight, double screenWidth) {
    return Column(
      children: [
        Image.asset(asset, width: screenWidth * 0.08, height: screenHeight * 0.08),
        // SizedBox(height: screenHeight * 0.001),
        Text(title, style: AppTheme.lightTheme.textTheme.bodyMedium),
        SizedBox(height: screenHeight * 0.01),
        Text(value, style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03)),
      ],
    );
  }
}
