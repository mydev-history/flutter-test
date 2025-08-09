// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/screens/customer_login.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_otp_screen.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_registration.dart';
import 'package:wah_frontend_flutter/services/auth_service.dart';

class VendorLogin extends StatelessWidget {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;
  String? completePhoneNumber;

  VendorLogin({super.key});

  Future<void> validatePhoneNumberAndGenerateOtp(BuildContext context) async {
    if (completePhoneNumber != null && completePhoneNumber!.isNotEmpty) {
      try {
        String responseMessage = await _authService.isPhoneNumberUnique(completePhoneNumber!);

        if (responseMessage == "Valid Phone and Vendor Approved") {
          await _supabase.auth.signInWithOtp(
            phone: '+$completePhoneNumber',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorOtpScreen(phoneNumber: completePhoneNumber!),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorRegistration(mobilePhone: completePhoneNumber!),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorRegistration(mobilePhone: completePhoneNumber!),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
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
                          "Login to Your Account",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: screenWidth * 0.07),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),

            // Phone Number Input Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter Phone Number",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // IntlPhoneField Widget
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onBackground),
                      ),
                      counter: const SizedBox(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.fingerprint),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Biometric authentication is not yet implemented.')),
                          );
                        },
                      ),
                    ),
                    initialCountryCode: 'US',
                    onChanged: (phone) {
                      completePhoneNumber = phone.completeNumber.replaceFirst('+', '');
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Continue with Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Continue with ",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email login is not yet implemented.')),
                          );
                        },
                        child: Text(
                          "Email",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Send OTP Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => validatePhoneNumberAndGenerateOtp(context),
                  child: Text(
                    "Send OTP",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Continue as Vendor
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerLogin()),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login as ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold
                          ),
                    ),
                    Text(
                      "Customer",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
