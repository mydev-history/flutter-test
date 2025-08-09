import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/vendor_header.dart';
import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final TextEditingController _qrCodeController = TextEditingController();
  final VendorService _vendorService = VendorService();
  bool _isLoading = false;

  Future<void> _redeemCoupon() async {
    if (_qrCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a QR code')),
      );
      return;
    }

    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final vendorId = vendorProvider.vendorData?.vendorId ?? '';

    if (vendorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor ID is missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _vendorService.validateQrCode(
        qrCode: _qrCodeController.text,
        vendorId: vendorId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon redeemed successfully!')),
        );
        _qrCodeController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error redeeming coupon: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          VendorHeader(
            businessName: "Anu Attires",
            onNotificationTap: () {
              print("Notification tapped");
            },
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _qrCodeController,
                      decoration: InputDecoration(
                        labelText: "Enter QR Code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _redeemCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Redeem',
                                style: TextStyle(fontWeight: FontWeight.bold),
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

      // Bottom Navigation Bar
      bottomNavigationBar: VendorNavbar(
        currentIndex: 2, // Profile Tab
        context: context,
      ),
    );
  }
}
