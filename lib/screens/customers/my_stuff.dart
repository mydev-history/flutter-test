import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/header.dart';
import 'package:wah_frontend_flutter/components/navbar.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/coupons_data.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/coupons_provider.dart';
import 'package:wah_frontend_flutter/screens/customers/deal_details.dart';

class MyStuff extends StatefulWidget {
  const MyStuff({Key? key}) : super(key: key);

  @override
  _MyStuffState createState() => _MyStuffState();
}

class _MyStuffState extends State<MyStuff> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Header(
            cityName: "Frisco",
            pageTitle: "My Stuff",
            // onNotificationTap: () {
            //   print("Notification tapped");
            // },
          ),

          // Tab Bar - Now with INNER SHADOW instead of outer shadow
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.03,
            ),
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  // Inner shadow effect
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 0),
                    blurRadius: 0,
                    spreadRadius: 0.9,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    label: "Purchased",
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => _tabController.animateTo(0),
                    screenWidth: screenWidth,
                  ),
                  _buildTabButton(
                    label: "Redeemed",
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => _tabController.animateTo(1),
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
          ),

          // Small spacing before content
          SizedBox(height: screenHeight * 0.01),

          // Filter Button - Positioned Properly
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.05),
              child: IconButton(
                icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
                onPressed: () {
                  print("Filter button clicked");
                },
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponsList(context, "active"),
                _buildCouponsList(context, "redeemed"),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navbar
      bottomNavigationBar: Navbar(
        currentIndex: 1, // Active Tab
        context: context,
      ),
    );
  }

  /// Builds tab button with rounded background and INNER shadows
  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            // INNER shadow effect for selected tab
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(0, 0),
                      blurRadius: 2,
                    ),
                  ]
                : [],
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.onBackground : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

   /// Builds Coupons List Based on Status
  Widget _buildCouponsList(BuildContext context, String status) {
    return Consumer<CouponsProvider>(
      builder: (context, couponsProvider, child) {
        final coupons = couponsProvider.coupons.where((c) => c.status == status).toList();

        if (coupons.isEmpty) {
          return const Center(
            child: Text("No coupons available."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final coupon = coupons[index];
            return _buildCouponCard(context, coupon);
          },
        );
      },
    );
  }
  /// Builds the coupon card widget with proper spacing and background blending
   /// Builds the Coupon Card
  Widget _buildCouponCard(BuildContext context, CouponData coupon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final deal = coupon.dealDetails;

    return GestureDetector(
      onTap: () {
        if (deal != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DealDetailsPage(
                deal: deal,
                coupon: coupon,
              ),
            ),
          );
        } else {
          print("Deal details are missing for this coupon.");
        }
      },
    child: Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coupon Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: deal != null && deal.images.isNotEmpty
                ? Image.network(
                    coupon.dealDetails!.images.first,
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.15,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.12,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          SizedBox(width: screenWidth * 0.04),

          // Coupon Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deal Title
                Text(
                  coupon.dealDetails!.dealTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.005),

                // Vendor Name
                Text(
                  coupon.dealDetails!.businessName ?? "Unknown Vendor",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                SizedBox(height: screenHeight * 0.005),

                // Pricing
                Row(
                  children: [
                    Text(
                      "\$${coupon.dealDetails!.wahPrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "\$${coupon.dealDetails?.regularPrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black54,
                          ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "${((coupon.dealDetails!.discountValue / coupon.dealDetails!.regularPrice) * 100).toStringAsFixed(0)}% OFF",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                // Purchase & Expiry Date
                Text(
                  "Purchased: ${_formatDate(coupon.createdAt)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "Expires: ${_formatDate(coupon.dealDetails!.availableTo)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }


  /// Formats date strings
  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return "${date.day}-${_getMonthAbbreviation(date.month)}-${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  /// Returns month abbreviation
  String _getMonthAbbreviation(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
