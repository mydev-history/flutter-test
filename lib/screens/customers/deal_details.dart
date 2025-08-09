import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // For accessing DealsProvider
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/components/deal_card.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/coupons_data.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/deals_data.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/coupons_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/deals_provider.dart';
import 'package:wah_frontend_flutter/screens/chat_room.dart';
import 'package:wah_frontend_flutter/screens/customers/Customer_payment.dart';
import 'package:wah_frontend_flutter/screens/schedule_appointment.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';

class DealDetailsPage extends StatefulWidget {
  final DealData deal;
  final CouponData? coupon;

  const DealDetailsPage({super.key, required this.deal, this.coupon});

  @override
  _DealDetailsPageState createState() => _DealDetailsPageState();
}

class _DealDetailsPageState extends State<DealDetailsPage> {
  int _currentImageIndex = 0;
  bool _isLoading = false;
  bool _isFetchingReviews = true;
  bool _isEditing = false;
  CouponData? _generatedCoupon;
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final CustomerService _customerService = CustomerService();
  bool _isSubmitting = false;


 // Review Data
  Map<String, dynamic>? _reviewsData;


   @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isFetchingReviews = true);
    try {
      final response = await _customerService.getCustomerReviews(
        Provider.of<CustomerProvider>(context, listen: false).customerData?.customerId ?? '',
        widget.deal.dealId,
      );
      setState(() => _reviewsData = response);
      _rating = _reviewsData!['customerRating'];
      print(_rating);
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      setState(() => _isFetchingReviews = false);
    }
  }

 Future<void> _generateCoupon(String customerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _customerService.generateCoupon(customerId, widget.deal.dealId);
      print(response['coupon']);
      setState(() {
        _generatedCoupon = CouponData.fromJson(response['coupon']);
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate coupon. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelCoupon(String qrCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _customerService.cancelCoupon(qrCode);
      print(response['message']);

      // Remove the coupon from provider state
      Provider.of<CouponsProvider>(context, listen: false).removeCoupon(qrCode);

      setState(() {
        _generatedCoupon = null;
      });

      // Show success popup
      _showSuccessPopup(context);
    } catch (e) {
      print(e);
      // Show failure popup
      _showFailurePopup(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

//   Future<void> _showGenerateCouponPopup(BuildContext context, String customerId) async {
//   bool? isProceed = await showModalBottomSheet<bool>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) {
//       return const PopUp(
//         message: "Would you like to generate the coupon?",
//         icon: "assets/discount_icon.png", // Provide the actual asset path
//         isCancel: true, mainButtonText: 'Generate',
//       );
//     },
//   );

//   // If user clicks "Generate", proceed with the logic
//   if (isProceed == true) {
//     _generateCoupon(customerId);
//   }
// }

Future<void> _showGenerateCouponPopup(BuildContext context, String customerId) async {
  bool? isProceed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const PopUp(
        message: "Would you like to generate the coupon?",
        icon: "assets/discount_icon.png", // Provide the actual asset path
        isCancel: true, 
        mainButtonText: 'Generate',
      );
    },
  );

  // If user clicks "Generate", proceed with the logic
  if (isProceed == true) {
    // await _generateCoupon(customerId);

    // Navigate to the customer payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerPaymentPage(deal: widget.deal, customerId: customerId,),
      ),
    );
  }
}


Future<void> _showSuccessPopup(BuildContext context) async {
  bool? isClosed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const PopUp(
        message: "Coupon successfully cancelled, wallet balance updated.",
        icon: "assets/success.png",
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );

  // Navigate back to the previous screen if user closes the popup
  if (isClosed == true) {
    Navigator.pop(context);
  }
}


Future<void> _showFailurePopup(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const PopUp(
        message: "Error Canceling the coupon, please try again later",
        icon: "assets/close.png", // Provide the actual success icon path
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );
}

Future<void> navigateToChatRoom(BuildContext context) async {
  final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
  final customerId = customerProvider.customerData?.customerId ?? '';
  final vendorId = widget.deal.vendorId;
  final dealId = widget.deal.dealId;

  if (customerId.isEmpty || vendorId.isEmpty) {
    print("❌ Missing Customer or Vendor ID");
    return;
  }

  print("🟢 Checking for existing chat session: Customer: $customerId, Vendor: $vendorId, Deal: $dealId");

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
        .maybeSingle(); // ✅ Return a single row safely

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
          participantName: widget.deal.businessName ?? "Vendor",
          participantAvatar: widget.deal.businessLogo,
          receiver_id: vendorId,
          sender_id: customerId,
          dealId: dealId, // Pass deal ID to create a session if needed
        ),
      ),
    );
  } catch (error) {
    print("❌ Error checking chat session: $error");
  }
}



 Future<void> _showCancelCouponPopup(BuildContext context, String qrCode) async {
  bool? isProceed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const PopUp(
        message: "Would you like to cancel the coupon?",
        icon: "assets/close.png", // Provide the actual asset path
        isCancel: true,
        mainButtonText: "Cancel Coupon", // Updated for dynamic text
      );
    },
  );

  // If user clicks "Cancel Coupon", proceed with API call
  if (isProceed == true) {
    await _cancelCoupon(qrCode);
  }
}

Future<void> _submitReview(String customerId) async {
    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating and write a review")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _customerService.submitReview(
        customerId,
        widget.deal.dealId,
        _rating,
        _reviewController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Review submitted successfully!")),
      );

      // Clear rating and review after submission
      setState(() {
        _rating = 0;
        _reviewController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review. Please try again.")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.deal.images;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final CouponData? coupon = widget.coupon ?? _generatedCoupon;

    // Fetch and sort similar deals
    final dealsProvider = Provider.of<DealsProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customerId = customerProvider.customerData?.customerId ?? '';
    final customerName = customerProvider.customerData?.firstName ?? '';
    
    final similarDeals = dealsProvider.deals
    .where((deal) => deal.dealId != widget.deal.dealId) // Exclude the current deal
    .toList()
  ..sort((a, b) {
    if (a.vendorId == widget.deal.vendorId) return -1;
    if (a.categoryId == widget.deal.categoryId) return 0;
    return 1;
  });


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top Image Carousel with Dots Below
          Stack(
            children: [
              CarouselSlider(
                items: images
                    .map((image) => Image.network(
                          image,
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                        ))
                    .toList(),
                options: CarouselOptions(
                  height: screenHeight * 0.35,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
              ),
              Positioned(
                top: screenHeight * 0.05,
                left: screenWidth * 0.04,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.05,
                right: screenWidth * 0.04,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: Image.asset('assets/heart.png', width: 24, height: 24),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: Image.asset('assets/share.png', width: 24, height: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                width: screenWidth * 0.02,
                height: screenWidth * 0.02,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Scrollable Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deal Title and Business Name with Deal ID
                    Text(
                      '${widget.deal.businessName ?? "N/A"} (Deal ID: ${widget.deal.dealId.split("_")[1]})',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      widget.deal.dealTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Price, Rating, and Coupons Left
                    Row(
                      children: [
                        Text(
                          '\$${widget.deal.wahPrice}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onBackground,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          '\$${widget.deal.regularPrice}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          '${((widget.deal.discountValue / widget.deal.regularPrice) * 100).toInt()}% OFF',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Social Media Icons
                    Row(
                      children: [
                        Image.asset('assets/insta.png', width: screenWidth * 0.06, height: screenWidth * 0.06),
                        SizedBox(width: screenWidth * 0.02),
                        Image.asset('assets/facebook.png', width: screenWidth * 0.06, height: screenWidth * 0.06),
                        SizedBox(width: screenWidth * 0.02),
                        Image.asset('assets/web.png', width: screenWidth * 0.06, height: screenWidth * 0.06),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Location Icon and Address
                    Row(
                      children: [
                        Icon(Icons.location_on, color: theme.colorScheme.primary),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            '${widget.deal.address ?? ""}, ${widget.deal.street ?? ""}, ${widget.deal.city ?? ""} \n ${widget.deal.state ?? ""}, ${widget.deal.country ?? ""}, ${widget.deal.zipcode}',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // Expiry, Chat, and Phone Icons
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/phone.png', width: screenWidth * 0.08, height: screenWidth * 0.08),
                          SizedBox(height: screenHeight * 0.005),
                          Text("Phone", style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              navigateToChatRoom(context);
                            },
                            child: SvgPicture.asset('assets/Messages.svg', width: screenWidth * 0.08, height: screenWidth * 0.08),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text("Chat", style: theme.textTheme.bodySmall),
                        ],
                      ),

                      // ✅ Conditional Scheduling Icon with Navigation
                      if (widget.deal.enableScheduling == true && coupon != null)
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (customerId.isNotEmpty && widget.deal.vendorId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleAppointmentPage(
                                        vendorId: widget.deal.vendorId,
                                        customerId: customerId,
                                        dealId: widget.deal.dealId,
                                        initiatedBy: "customer",
                                        vendorAcceptance: false,
                                        customerName: customerName,
                                      ),
                                    ),
                                  );
                                } else {
                                  print("❌ Vendor ID or Customer ID is missing!");
                                }
                              },
                              child: Image.asset('assets/schedule.png', width: screenWidth * 0.08, height: screenWidth * 0.08),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text("Schedule", style: theme.textTheme.bodySmall),
                          ],
                        ),

                      Column(
                        children: [
                          Image.asset('assets/expiry.png', width: screenWidth * 0.08, height: screenWidth * 0.08),
                          SizedBox(height: screenHeight * 0.005),
                          Text("07-Feb-2025", style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),


                    SizedBox(height: screenHeight * 0.03),

                    // ✅ Coupon Container (Displays when coupon is generated)
                   if (coupon != null)
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                      ),
                      child: Column(
                        children: [
                          // QR Code and Redeem Steps
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Redeem steps", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text("1. Contact Vendor and schedule your appointment"),
                                    Text("2. Get your coupon scanned by vendor during checkout"),
                                    Text("3. Pay ${widget.deal.wahPrice} directly to the vendor as per deal terms"),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: screenHeight * 0.15,
                                color: Colors.black.withOpacity(0.3),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    QrImageView(
                                      data: coupon.qrCode,
                                      size: screenWidth * 0.2,
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      coupon.qrCode,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // Customer Rating & Review Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rate your experience", style: theme.textTheme.titleLarge),
                              SizedBox(height: screenHeight * 0.02),

                              // Star Rating Selection
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      Icons.star,
                                      color: (_rating ?? 0) > index ? theme.colorScheme.primary : Colors.grey,
                                      size: screenWidth * 0.08,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _rating = (index + 1);
                                        _isEditing = _reviewsData != null && _reviewsData!['reviewId'] != null;
                                      });
                                    },
                                  );
                                }),
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Handling Review Display and Input Field
                              if (_reviewsData == null || _reviewsData!['reviewId'] == null)
                                TextField(
                                  controller: _reviewController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: "Share your experience...",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                              else if (_isEditing)
                                TextField(
                                  controller: _reviewController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: "Update your experience...",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _reviewsData!['customerReview'] ?? "",
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    if (_reviewsData!['vendorReplay'] != null && _reviewsData!['vendorReplay']!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                                        child: Text(
                                          "${widget.deal.businessName} : ${_reviewsData!['vendorReplay']}",
                                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground),
                                        ),
                                      ),
                                  ],
                                ),

                              SizedBox(height: screenHeight * 0.02),

                              // Edit and Delete Buttons (Only if Review Exists)
                              if (_reviewsData != null && _reviewsData!['reviewId'] != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Edit Button
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _reviewController.text = _reviewsData!['customerReview'] ?? "";
                                          _rating = (_reviewsData!['customerRating']);
                                          _isEditing = true;
                                        });
                                      },
                                      child: Text("Edit", style: TextStyle(color: theme.colorScheme.primary)),
                                    ),

                                    // Delete Button
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await _customerService.deleteReview(_reviewsData!['reviewId']);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Review deleted successfully!")),
                                          );
                                          setState(() {
                                            _reviewsData = null;
                                            _rating = 0;
                                            _reviewController.clear();
                                            _isEditing = false;
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Failed to delete review.")),
                                          );
                                        }
                                      },
                                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              SizedBox(height: screenHeight * 0.02),

                              // Submit or Update Review Button
                              ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (_rating == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please select a rating")),
                                          );
                                          return;
                                        }

                                        setState(() => _isSubmitting = true);

                                        try {
                                          final response = (_reviewsData != null && _reviewsData!['reviewId'] != null)
                                              ? await _customerService.editReview(
                                                  _reviewsData!['reviewId'],
                                                  _rating,
                                                  feedback: _reviewController.text,
                                                )
                                              : await _customerService.submitReview(
                                                  Provider.of<CustomerProvider>(context, listen: false).customerData?.customerId ?? '',
                                                  widget.deal.dealId,
                                                  _rating,
                                                  _reviewController.text,
                                                );

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(response['message'] ?? "Review updated successfully!")),
                                          );

                                          setState(() {
                                            _rating = 0;
                                            _reviewController.clear();
                                            _isEditing = false;
                                            _fetchReviews(); // Refresh Reviews After Submission
                                          });
                                        } catch (e) {
                                          print(e);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Failed to submit review. Please try again.")),
                                          );
                                        } finally {
                                          setState(() => _isSubmitting = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  minimumSize: Size(double.infinity, screenHeight * 0.07),
                                ),
                                child: Text(
                                  (_reviewsData != null && _reviewsData!['reviewId'] != null) ? "Update Review" : "Add Review",
                                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                     // ✅ Buttons
                    coupon == null
                        ? ElevatedButton(
                           onPressed: _isLoading ? null : () => _showGenerateCouponPopup(context, customerId),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: Size(double.infinity, screenHeight * 0.07),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.black)
                                : Text("Generate Coupon",
                                 style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: FontWeight.bold ),),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Cancel Button
                              OutlinedButton(
                                onPressed: () => _showCancelCouponPopup(context, coupon.qrCode),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  "Cancel",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Re Order Button
                              ElevatedButton(
                                onPressed: () => _showGenerateCouponPopup(context, customerId),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                                child: Text(
                                  "Re Order",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                    SizedBox(height: screenHeight * 0.02),

                    // Combined Deal Description and Terms
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
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
                            style: theme.textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.04),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            widget.deal.dealDescription,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Divider(
                            thickness: 0.1,
                            height: 32,
                          ),
                          // Deal Terms and Conditions
                          Text(
                            "Deal Terms and Conditions",
                            style: theme.textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.04),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            widget.deal.termsAndConditions,
                            style: theme.textTheme.bodyMedium,
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
                              // Header
                              Padding(
                                padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                                child: Text(
                                  "Ratings & Reviews (${_reviewsData!['totalReviews']})",
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              Divider(
                                thickness: screenHeight * 0.001, // Controls the thickness
                                color: Colors.black.withOpacity(0.2), // Sets the color with opacity
                              ),


                              // Overall Rating
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                child: Row(
                                  children: [
                                    Text(
                                      "${_reviewsData!['totalRating']}/5",
                                      style: theme.textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Overall Rating",
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          "${_reviewsData!['totalReviews']} Ratings",
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              

                              // Latest Review
                              if (_reviewsData!['customerReview'].isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      // Review Title
                                      Text(
                                        _reviewsData!['customerName'],
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      // Star Rating
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            Icons.star,
                                            color: index < (_reviewsData!['customerRating'])
                                                ? theme.colorScheme.primary
                                                : Colors.grey,
                                            size: screenWidth * 0.06,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      

                                      // Review Content
                                      Text(
                                        _reviewsData!['customerReview'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      SizedBox(height: screenHeight * 0.02),

                                      // Review Images (Optional)
                                      // Row(
                                      //   children: [
                                      //     Image.asset('assets/review1.png', width: screenWidth * 0.15),
                                      //     SizedBox(width: screenWidth * 0.02),
                                      //     Image.asset('assets/review2.png', width: screenWidth * 0.15),
                                      //     SizedBox(width: screenWidth * 0.02),
                                      //     Image.asset('assets/review3.png', width: screenWidth * 0.15),
                                      //   ],
                                      // ),
                                      SizedBox(height: screenHeight * 0.02),

                                      // Reviewer Info
                                      Text(
                                        "${_reviewsData!['customerName']}, ${_reviewsData!['createdAt']}",
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              Divider(
                                thickness: screenHeight * 0.001, // Controls the thickness
                                color: Colors.black.withOpacity(0.2), // Sets the color with opacity
                              ),

                              // View All Reviews Link
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implement Navigation to Full Reviews Page
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "View All Reviews",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.03),
                      
                    // Similar Deals Section
                    Text(
                      "Similar Deals",
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.04),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(
                      height: screenHeight * 0.30, // Adjust height for cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarDeals.length,
                        itemBuilder: (context, index) {
                          final deal = similarDeals[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the DealDetailsPage with the new deal
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DealDetailsPage(deal: deal),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: screenWidth * 0.03),
                              child: DealCard(
                                imageUrl: deal.images.first,
                                dealTitle: deal.dealTitle,
                                businessName: deal.businessName ?? '',
                                wahPrice: deal.wahPrice,
                                regularPrice: deal.regularPrice,
                                discount: (deal.discountValue / deal.regularPrice) * 100,
                                isTrending: deal.isTrending ?? false,
                                isFavorite: false,
                                rating: deal.rating,
                                reviews: deal.reviews, 
                                dealId: deal.dealId,
                                customerId: customerId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
