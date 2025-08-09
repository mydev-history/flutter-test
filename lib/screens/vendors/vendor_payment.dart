// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:provider/provider.dart';
// import 'package:wah_frontend_flutter/components/header.dart';
// import 'package:wah_frontend_flutter/components/popUp.dart';
// import 'package:wah_frontend_flutter/components/vendor_header.dart';
// import 'package:wah_frontend_flutter/config/theme.dart';
// import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
// import 'package:wah_frontend_flutter/services/vendor_service.dart';

// class VendorPaymentPage extends StatefulWidget {
//   final String vendorId;
//   final double wahFee;
//   final double taxes;
//   final double totalPrice;
//   final int couponsCount;
//   final double forcastedRevenue;
//   final String dealImage;

//   const VendorPaymentPage({
//     Key? key,
//     required this.vendorId,
//     required this.wahFee,
//     required this.taxes,
//     required this.totalPrice,
//     required this.couponsCount,
//     required this.dealImage,
//     required this.forcastedRevenue,
//   }) : super(key: key);

//   @override
//   _VendorPaymentPageState createState() => _VendorPaymentPageState();
// }

// class _VendorPaymentPageState extends State<VendorPaymentPage> {
//   final VendorService _vendorService = VendorService();
//   String? _transactionId;
//   String? _paymentStatus;

//   Future<void> _startPayment() async {
//     try {
//       final paymentIntentResponse = await _vendorService.createPaymentIntent(widget.totalPrice);
//       print("Payment Intent Response: $paymentIntentResponse");

//       final String? clientSecret = paymentIntentResponse['client_secret'] as String?;
//       final String? paymentIntentId = paymentIntentResponse['id'] as String?;

//       if (clientSecret == null || clientSecret.isEmpty) {
//         throw Exception("client_secret is null or empty");
//       }
//       if (paymentIntentId == null || paymentIntentId.isEmpty) {
//         throw Exception("Payment Intent ID is null or empty");
//       }

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           merchantDisplayName: "Wah! Smart Deals",
//         ),
//       );

//       await Stripe.instance.presentPaymentSheet();

//       final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
//       setState(() {
//         _transactionId = paymentIntent.id;
//         _paymentStatus = paymentIntent.status.toString().split('.').last;
//       });

//       if (_paymentStatus == "Succeeded") {
//         Navigator.pop(context, {'success': true, 'transactionId': _transactionId});
//       } else {
//         _showFailurePopup();
//       }
//     } catch (error) {
//       print("Payment Error: $error");
//       _showFailurePopup();
//     }
//   }

//   Future<void> _showFailurePopup() async {
//     await showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return const PopUp(
//           message: "Payment Failed. Please try again later",
//           icon: "assets/close.png",
//           isCancel: false,
//           mainButtonText: "Close",
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;
//       final vendorData = Provider.of<VendorProvider>(context).vendorData;

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: Column(
//         children: [
//            VendorHeader(
//           businessName: vendorData?.businessName ?? "Loading...",
//           onNotificationTap: () {},
//         ),
//           SizedBox(height: screenHeight * 0.03),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Payment Summary", style: Theme.of(context).textTheme.titleLarge),
//                     SizedBox(height: screenHeight * 0.02),
//                     Container(
//                       padding: EdgeInsets.all(screenWidth * 0.04),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
//                       ),
//                       child: Column(
//                         children: [
//                           _buildPriceRow("Wah! Fee", widget.wahFee),
//                           Divider(thickness: 0.2, height: screenHeight * 0.03),
//                           _buildPriceRow("Taxes", widget.taxes),
//                           Divider(thickness: 0.2, height: screenHeight * 0.03),
//                           _buildPriceRow("Total", widget.totalPrice, highlight: true),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.04),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _startPayment,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryColor,
//                           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           minimumSize: Size(double.infinity, screenHeight * 0.07),
//                         ),
//                         child: Text("Proceed to Payment", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, double amount, {bool highlight = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
//           Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: highlight ? Colors.blue : Colors.black)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/components/vendor_header.dart';
import 'package:wah_frontend_flutter/config/theme.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorPaymentPage extends StatefulWidget {
  final String vendorId;
  final double wahFee;
  final double taxes;
  final double totalPrice;
  final int couponsCount;
  final double forcastedRevenue;
  final String dealImage;
  final String dealTitle;
  final String dealPrice;
  final String discountValue;
  final String regularPrice;

  const VendorPaymentPage({
    Key? key,
    required this.vendorId,
    required this.wahFee,
    required this.taxes,
    required this.totalPrice,
    required this.couponsCount,
    required this.dealImage,
    required this.forcastedRevenue,
    required this.dealPrice,
    required this.dealTitle,
    required this.discountValue,
    required this.regularPrice
  }) : super(key: key);

  @override
  _VendorPaymentPageState createState() => _VendorPaymentPageState();
}

class _VendorPaymentPageState extends State<VendorPaymentPage> {
  final VendorService _vendorService = VendorService();
  String? _transactionId;
  String? _paymentStatus;

  Future<void> _startPayment() async {
    try {
      final paymentIntentResponse =
          await _vendorService.createPaymentIntent(widget.totalPrice);

      final String? clientSecret =
          paymentIntentResponse['client_secret'] as String?;
      final String? paymentIntentId = paymentIntentResponse['id'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception("client_secret is null or empty");
      }
      if (paymentIntentId == null || paymentIntentId.isEmpty) {
        throw Exception("Payment Intent ID is null or empty");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Wah! Smart Deals",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final paymentIntent =
          await Stripe.instance.retrievePaymentIntent(clientSecret);

      setState(() {
        _transactionId = paymentIntent.id;
        _paymentStatus = paymentIntent.status.toString().split('.').last;
      });

      if (_paymentStatus == "Succeeded") {
        Navigator.pop(context, {'success': true, 'transactionId': _transactionId});
      } else {
        _showFailurePopup();
      }
    } catch (error) {
      print("Payment Error: $error");
      _showFailurePopup();
    }
  }

  Future<void> _showFailurePopup() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const PopUp(
          message: "Payment Failed. Please try again later",
          icon: "assets/close.png",
          isCancel: false,
          mainButtonText: "Close",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final vendorData = Provider.of<VendorProvider>(context).vendorData;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          VendorHeader(
            businessName: vendorData?.businessName ?? "Loading...",
            onNotificationTap: () {},
          ),
          SizedBox(height: screenHeight * 0.03),

          /// 🔹 **Deal Details Section**
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 **Deal Image & Title**
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg",
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.25,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: screenWidth*0.12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.dealTitle, // 🔹 Dummy Deal Title
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            vendorData?.businessName ?? "Vendor Name",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                "\$${widget.dealPrice}",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "\$${widget.regularPrice}",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${widget.discountValue}%",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.orange),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                /// 🔹 **Deal Summary**
                _buildSummaryCard([
                  _buildSummaryRow("Coupons Count", widget.couponsCount.toString()),
                  _buildSummaryRow("Wah! Deal Price", "\$${widget.dealPrice}"),
                  _buildSummaryRow("Forecasted Revenue", "\$${widget.forcastedRevenue.toStringAsFixed(2)}"),
                ]),

                SizedBox(height: screenHeight * 0.03),

                /// 🔹 **Payment Summary**
                _buildSummaryCard([
                  _buildSummaryRow("Wah! Fee", "\$${widget.wahFee.toStringAsFixed(2)}"),
                  _buildSummaryRow("Taxes", "\$${widget.taxes.toStringAsFixed(2)}"),
                  _buildSummaryRow("Total", "\$${widget.totalPrice.toStringAsFixed(2)}", highlight: true),
                ]),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          /// 🔹 **Proceed to Payment Button**
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: Size(double.infinity, screenHeight * 0.07),
                ),
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Reusable Summary Card**
  Widget _buildSummaryCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(children: children),
    );
  }

  /// 🔹 **Reusable Summary Row**
  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.normal)),
          Text(value, style: TextStyle(color: highlight ? Colors.blue : Colors.black, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
