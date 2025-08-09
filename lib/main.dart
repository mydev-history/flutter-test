// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wah_frontend_flutter/config/supabase_config.dart';
import 'package:wah_frontend_flutter/providers/app_provider/banner_provider.dart';
import 'package:wah_frontend_flutter/providers/app_provider/categories_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/coupons_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/deals_provider.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/screens/splash_screen.dart';
import 'package:wah_frontend_flutter/screens/customer_login.dart'; // Import the CustomerLogin screen
import 'package:provider/provider.dart'; // Import Provider for state management
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env"); // Load the .env file
  await SupabaseConfig.initialize(); // Initialize Supabase

  // ✅ Initialize Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY_DEV'] ?? ''; // Load key from .env
  // Stripe.merchantIdentifier = 'merchant.com.YOUR-APP-ID'; // (For Apple Pay, replace with actual ID)
  await Stripe.instance.applySettings(); // Apply Stripe settings

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()), // Register CustomerProvider
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => DealsProvider()),
        ChangeNotifierProvider(create: (_) => CouponsProvider()),
      ],
      child: MaterialApp(
        title: 'Wah! Smart Deals',
        theme: AppTheme.lightTheme, // Apply light theme
        darkTheme: AppTheme.darkTheme, // Apply dark theme
        themeMode: ThemeMode.system, // Automatically switch based on system settings
        home: SplashScreenWrapper(), // Load the splash screen
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();

    // Timer to show the splash screen for 3 seconds
    Timer(const Duration(seconds: 3), () {
      // Navigate to the CustomerLogin screen after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomerLogin()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Display the SplashScreen
  }
}
