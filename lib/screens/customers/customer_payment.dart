import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/config/theme.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/coupons_data.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/deals_data.dart';
import 'package:wah_frontend_flutter/components/header.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wah_frontend_flutter/screens/customers/deal_details.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';

class CustomerPaymentPage extends StatefulWidget {
  final DealData deal;
  final String customerId;

  const CustomerPaymentPage({Key? key, required this.deal, required this.customerId}) : super(key: key);

  @override
  _CustomerPaymentPageState createState() => _CustomerPaymentPageState();
}

class _CustomerPaymentPageState extends State<CustomerPaymentPage> {
  String? _transactionId;
  String? _paymentStatus;
  CouponData? _generatedCoupon;
  final CustomerService _customerService = CustomerService(); // Initialize CustomerService
  
Future<void> _startPayment(BuildContext context, double amount) async {
  try {
    setState(() {
    });

    final paymentIntentResponse = await _customerService.createPaymentIntent(amount);
    print("Payment Intent Response: $paymentIntentResponse");

    final String? clientSecret = paymentIntentResponse['client_secret'] as String?;
    final String? paymentIntentId = paymentIntentResponse['id'] as String?;

    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception("client_secret is null or empty");
    }

    if (paymentIntentId == null || paymentIntentId.isEmpty) {
      throw Exception("Payment Intent ID is null or empty");
    }

    // ✅ Initialize Stripe Payment Sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Wah! Smart Deals",
      ),
    );

    // ✅ Present the Payment Sheet
    await Stripe.instance.presentPaymentSheet();

    // ✅ Retrieve Payment Intent Details
    final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);

    // 🔹 Convert PaymentIntentsStatus to String
    setState(() {
      _transactionId = paymentIntent.id;
      _paymentStatus = paymentIntent.status.toString().split('.').last; // Convert enum to string
    });

    print("Transaction ID: $_transactionId");
    print("Payment Status: $_paymentStatus");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment successful! Generating coupon...")),
    );

    // ✅ Generate Coupon After Successful Payment
    final couponGenerated = await _generateCoupon(widget.customerId);

    if (couponGenerated) {
      // ✅ Insert Transaction in `Customer_Payment_Transactions`
      await _insertTransaction(
        transactionId: _transactionId!,
        customerId: widget.customerId, // Replace with actual customer ID
        couponId: _generatedCoupon?.couponId ?? "",
        transactionType: "Purchase",
        status: _paymentStatus!, // Now it will store the string status
      );

      // ✅ Show success popup
      await _showSuccessPopup(context);
    } else {
      await _showFailurePopup(context);
    }
  } catch (error) {
    print("Payment Error: $error");
    await _showFailurePopup(context);
  } finally {
    setState(() {
    });
  }
}


  /// **Generates Coupon After Payment**
  Future<bool> _generateCoupon(String customerId) async {
    setState(() {
    });

    try {
      final response = await _customerService.generateCoupon(customerId, widget.deal.dealId);
      print("Coupon Response: ${response['coupon']}");

      setState(() {
        _generatedCoupon = CouponData.fromJson(response['coupon']);
      });

      return true; // ✅ Coupon Generated Successfully
    } catch (e) {
      print("Coupon Generation Error: $e");
      return false; // ❌ Coupon Generation Failed
    } finally {
      setState(() {
      });
    }
  }

  /// **Inserts Transaction into `Customer_Payment_Transactions`**
  Future<void> _insertTransaction({
    required String transactionId,
    required String customerId,
    required String couponId,
    required String transactionType,
    required String status,
  }) async {
    try {
      final response = await _customerService.insertCustomerTransaction(
        transactionId: transactionId,
        customerId: customerId,
        couponId: couponId,
        transactionType: transactionType,
        status: status,
      );

      print("Transaction Inserted: $response");
    } catch (e) {
      print("Error inserting transaction: $e");
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
        message: "Coupon successfully generated.",
        icon: "assets/success.png",
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );

  // 🔹 If popup is closed, navigate to DealDetailsPage
  if (isClosed == true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DealDetailsPage(
          deal: widget.deal,
          coupon: _generatedCoupon!,
        ),
      ),
    );
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
        message: "Payment Failed, Please try again later",
        icon: "assets/close.png", // Provide the actual success icon path
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final double wahFee = widget.deal.wahPrice * 0.10;
    final double taxes = 0.50; // Assume fixed Stripe & other charges for now
    final double totalPrice = wahFee + taxes;
    final double dealPrice = widget.deal.wahPrice;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Header(
            cityName: "Frisco",
            pageTitle: "Payment",
          ),
          SizedBox(height: screenHeight * 0.03),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deal Details
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.deal.images.first,
                              width: screenWidth * 0.3,
                              height: screenHeight * 0.15,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.deal.dealTitle, style: Theme.of(context).textTheme.bodyLarge),
                                Text(widget.deal.businessName ?? "", style: Theme.of(context).textTheme.bodyMedium),
                                Row(
                                  children: [
                                    Text("\$${widget.deal.wahPrice.toStringAsFixed(2)}", style: Theme.of(context).textTheme.titleLarge),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text("\$${widget.deal.regularPrice.toStringAsFixed(2)}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text("${widget.deal.discountValue.toStringAsFixed(0)}%", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Text("Pay to the vendor during redemption", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: screenWidth*0.04)),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Wah! Deal Price", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.04)),
                          Text("\$${dealPrice.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.04)),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Column(
                        children: [
                          Text("Pay now to generate coupon", style: Theme.of(context).textTheme.titleLarge),
                          SizedBox(height: screenHeight * 0.02),
                          _buildPriceRow("Wah! Fee", wahFee),
                          Divider(
                            thickness: 0.2,
                            height: screenHeight *0.03,
                          ),
                          _buildPriceRow("Taxes", taxes),
                          Divider(
                            thickness: 0.2,
                            height: screenHeight *0.03,
                          ),
                          _buildPriceRow("Total", totalPrice, highlight: true),
                          SizedBox(height: screenHeight * 0.03),
                          ElevatedButton(
                      onPressed: () => _startPayment(context, totalPrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size(double.infinity, screenHeight * 0.07),
                      ),
                      // onPressed: () {  },
                      child: Text("Proceed to Payment", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Center(
                      child: RichText(
                        text: const TextSpan(
                          text: "Go Premium!",
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: " to avoid wah! fee",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
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

  Widget _buildPriceRow(String label, double amount, {bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
          Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: highlight ? Colors.blue : Colors.black)),
        ],
      ),
    );
  }
}
