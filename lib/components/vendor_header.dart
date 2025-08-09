// import 'package:flutter/material.dart';

// class VendorHeader extends StatelessWidget {
//   final String businessName;
  
//   final VoidCallback onNotificationTap;
//   final double topPadding; // Top padding parameter

//   const VendorHeader({
//     Key? key,
//     required this.businessName,
//     required this.onNotificationTap,
//     this.topPadding = 0.2, // Default top padding set to 0
//   }) : super(key: key);


//   @override
//   Widget build(BuildContext context) {
//     // Get the device width and height using MediaQuery
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     // Header height adjustment based on device size
//     final double headerHeight = screenHeight * 0.08; // 8% of the screen height

//     return Container(
//       height: headerHeight,
//       padding: EdgeInsets.only(
//         top: screenHeight * 0.05, // Dynamic top padding
//         left: screenWidth * 0.1, // 1% of screen width for left padding
//         right: screenWidth * 0.1, // 1% of screen width for right padding
//       ),
//       color: Colors.transparent, // Transparent background
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Left: City Name
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               businessName,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     fontWeight: FontWeight.w900,
//                     decoration: TextDecoration.underline,
//                   ),
//             ),
//           ),

//           // // Center: Logo and Page Title
//           // Align(
//           //   alignment: Alignment.center,
//           //   child: Row(
//           //     crossAxisAlignment: CrossAxisAlignment.center,
//           //     children: [
//           //       // Custom Logo
//           //       Image.asset(
//           //         'assets/wah_logo.png', // Replace with your actual logo path
//           //         height: headerHeight * 0.5, // Adjust logo height
//           //       ),
//           //       SizedBox(width: screenWidth * 0.02), // Spacing between logo and text
//           //       Text(
//           //         pageTitle,
//           //         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//           //               fontWeight: FontWeight.w900,
//           //             ),
//           //       ),
//           //     ],
//           //   ),
//           // ),

//           // Right: Notification Icon
//           Align(
//             alignment: Alignment.topCenter,
//             child: IconButton(
//               icon: Icon(
//                 Icons.notifications_none,
//                 color: Theme.of(context).colorScheme.onBackground,
//                 size: headerHeight * 0.35, // Adjust icon size
//               ),
//               onPressed: onNotificationTap,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_notifications.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorHeader extends StatefulWidget {
  final String businessName;
  final VoidCallback onNotificationTap;
  final double topPadding;

  const VendorHeader({
    Key? key,
    required this.businessName,
    required this.onNotificationTap,
    this.topPadding = 0.2,
  }) : super(key: key);

  @override
  _VendorHeaderState createState() => _VendorHeaderState();
}

class _VendorHeaderState extends State<VendorHeader> {
  final VendorService _vendorService = VendorService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationCount();
  }

  /// ✅ Fetch unread notification count
  Future<void> _fetchUnreadNotificationCount() async {
    final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
    if (vendorData == null) return;

    final count = await _vendorService.getUnreadNotificationsCount(vendorData.vendorId);
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.08;

    return Container(
      height: headerHeight,
      padding: EdgeInsets.only(
        top: screenHeight * 0.05,
        left: screenWidth * 0.1,
        right: screenWidth * 0.1,
      ),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Left: Business Name
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.businessName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),

          // ✅ Right: Notification Icon with Badge
          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: headerHeight * 0.35,
                  ),
                  onPressed: () {
                    final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
                    if (vendorData == null) return;

                    // Navigate to VendorNotifications page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorNotifications(vendorId: vendorData.vendorId),
                      ),
                    ).then((_) {
                      // Refresh unread count after returning
                      _fetchUnreadNotificationCount();
                    });
                  },
                ),

                // ✅ Notification Badge (Show only if unread count > 0)
                if (_unreadCount > 0)
                  Positioned(
                    right: screenWidth * 0.05,
                    top: screenHeight * 0.005,
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: screenWidth * 0.001,
                        minHeight: screenHeight * 0.001,
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
