import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for screen size adjustments
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Background color for the splash screen
      body: Stack(
        children: [
          // Hero Bubble at the top
          Positioned(
            top: 0, // Start from the top
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/hero_bubble.png', // Use the hero_bubble.png image
              width: screenWidth, // Adjust to fit screen width
              fit: BoxFit.cover, // Ensure the image covers the width properly
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero Image
                Image.asset(
                  'assets/Hero.png', // Add this asset to your project
                  height: screenHeight * 0.4, // Responsive height
                ),
                SizedBox(height: screenHeight * 0.02),
                // Logo
                Image.asset(
                  'assets/Logo.png', // Add this asset to your project
                  height: screenHeight * 0.15, // Responsive height
                ),
                SizedBox(height: screenHeight * 0.02),
                // Text below logo
                Text(
                  'Get Pre Negotiated Bulk\nDiscounted Deals 30%-70%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
