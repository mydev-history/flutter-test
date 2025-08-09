import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:wah_frontend_flutter/screens/vendors/vendor_home.dart';

class VendorOtpScreen extends StatefulWidget {
  final String phoneNumber;

  VendorOtpScreen({required this.phoneNumber});

  @override
  _VendorOtpScreenState createState() => _VendorOtpScreenState();
}

class _VendorOtpScreenState extends State<VendorOtpScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  int remainingTime = 60; // Timer countdown in seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void moveToNextField(int index) {
    if (index < focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus(); // Remove focus if it's the last field
    }
  }

  void moveToPreviousField(int index) {
    if (index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  /// Retrieves the OTP entered by the user
  String getOtp() {
    return controllers.map((controller) => controller.text).join();
  }

  Future<void> verifyOtp() async {
  final otp = getOtp();
  if (otp.length == 6) {
    try {
      await _supabase.auth.verifyOTP(
        phone: '+${widget.phoneNumber}',
        token: otp,
        type: OtpType.sms,
      );

      // Navigate to CustomerHome if OTP is valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorHome(mobilePhone: widget.phoneNumber),
        ),
      );
    } on AuthException catch (e) {
      // Show error for invalid OTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP: ${e.message}')),
      );
    } catch (e) {
      // Show other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter the complete OTP')),
    );
  }
}



  /// Resends OTP
  Future<void> resendOtp() async {
    try {
      await _supabase.auth.signInWithOtp(phone: '+${widget.phoneNumber}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP has been resent successfully')),
      );
      setState(() {
        remainingTime = 60; // Reset timer
        startTimer();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Hero Section
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/hero_bubble.png',
                    width: screenWidth,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.1),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/Logo.png',
                          height: screenHeight * 0.15,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "Enter 6 digit verification code sent\nto your phone number",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.045,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),

            // OTP Input Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onBackground,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          moveToNextField(index);
                        } else if (value.isEmpty) {
                          moveToPreviousField(index);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Timer and Resend Code
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatTime(remainingTime),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (remainingTime == 0) {
                        resendOtp();
                      }
                    },
                    child: Text(
                      "Resend Code",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Verify OTP Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: verifyOtp, // Call the OTP verification method
                  child: Text(
                    "Verify OTP",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
