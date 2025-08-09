import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/header.dart';
import 'package:wah_frontend_flutter/components/navbar.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/customer_data.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/screens/customers/customer_appointment.dart';
import 'package:wah_frontend_flutter/screens/customers/customer_edit.dart'; // Import CustomerEdit.dart

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final customerData = Provider.of<CustomerProvider>(context).customerData;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Header(
            cityName: customerData?.city ?? " ",
            pageTitle: "Profile",
            // onNotificationTap: () {
            //   print("Notification tapped");
            // },
          ),

          // Profile Details Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image or Default Avatar
                CircleAvatar(
                  radius: screenWidth * 0.10,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: screenWidth * 0.12, color: theme.colorScheme.onBackground),
                ),
                SizedBox(width: screenWidth * 0.04),

                // Name & Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${customerData?.firstName ?? "Guest"}",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.002),
                    Text(
                      customerData?.emailId ?? "No Email Available",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Menu Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Section
                    _buildSectionHeader(context, "General"),
                    _buildProfileOption(context, "Edit Profile", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerEdit()),
                      );
                    }),
                     _buildProfileOption(context, "Scheduled Appointments", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  CustomerAppointments(customerId: customerData!.customerId)),
                      );
                    }),
                    _buildProfileOption(context, "Notifications"),
                    _buildProfileOption(context, "Podcast"),
                    _buildProfileOption(context, "Subscription"),

                    SizedBox(height: screenHeight * 0.02),

                    // Legal Section
                    _buildSectionHeader(context, "Legal"),
                    _buildProfileOption(context, "Terms of Use"),
                    _buildProfileOption(context, "Privacy Policy"),
                    _buildProfileOption(context, "Help"),
                    _buildProfileOption(context, "Logout"),

                    SizedBox(height: screenHeight * 0.02),

                    // Delete Account (Red Text)
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.06),
                      child: GestureDetector(
                        onTap: () {
                          print("Delete Account Clicked");
                        },
                        child: Text(
                          "Delete Account",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
      bottomNavigationBar: Navbar(
        currentIndex: 4, // Profile Tab
        context: context,
      ),
    );
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Profile Option Tile with Navigation Support
  Widget _buildProfileOption(BuildContext context, String title, [VoidCallback? onTap]) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap ??
          () {
            print("$title Clicked");
          },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: screenWidth * 0.05),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
