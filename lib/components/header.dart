// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
// import 'package:wah_frontend_flutter/screens/customers/customer_notifications.dart';

// class Header extends StatelessWidget {
//   final String cityName;
//   final String pageTitle;
//   final VoidCallback onNotificationTap;
//   final double topPadding; // Top padding parameter

//   const Header({
//     Key? key,
//     required this.cityName,
//     required this.pageTitle,
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
//     final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
//     if (customerData == null) throw Exception('Customer data is not available.');

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
//               cityName,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     fontWeight: FontWeight.w900,
//                     decoration: TextDecoration.underline,
//                   ),
//             ),
//           ),

//           // Center: Logo and Page Title
//           Align(
//             alignment: Alignment.center,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Custom Logo
//                 Image.asset(
//                   'assets/wah_logo.png', // Replace with your actual logo path
//                   height: headerHeight * 0.5, // Adjust logo height
//                 ),
//                 SizedBox(width: screenWidth * 0.02), // Spacing between logo and text
//                 Text(
//                   pageTitle,
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.w900,
//                       ),
//                 ),
//               ],
//             ),
//           ),

//           // Right: Notification Icon
//           Align(
//             alignment: Alignment.topCenter,
//             child: IconButton(
//               icon: Icon(
//                 Icons.notifications_none,
//                 color: Theme.of(context).colorScheme.onBackground,
//                 size: headerHeight * 0.35, // Adjust icon size
//               ),
//               onPressed: () {
//                 // ✅ Navigate to the CustomerNotifications page
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CustomerNotifications(customerId: customerData.customerId),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/screens/customers/customer_notifications.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';

class Header extends StatefulWidget {
  final String cityName;
  final String pageTitle;
  final double topPadding;

  const Header({
    Key? key,
    required this.cityName,
    required this.pageTitle,
    this.topPadding = 0.2,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int unreadCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotifications();
  }

  /// ✅ Fetch unread notifications count from API
  Future<void> _fetchUnreadNotifications() async {
    final customerData =
        Provider.of<CustomerProvider>(context, listen: false).customerData;
    if (customerData == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final int count =
          await CustomerService().getUnreadNotificationsCount(customerData.customerId);
      setState(() {
        unreadCount = count;
      });
    } catch (e) {
      print("Error fetching unread notifications: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.08;

    final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
    if (customerData == null) throw Exception('Customer data is not available.');

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
          // ✅ Left: City Name
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.cityName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),

          // ✅ Center: Logo and Page Title
          Align(
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/wah_logo.png',
                  height: headerHeight * 0.5,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  widget.pageTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),

          // ✅ Right: Notification Icon with Red Badge
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerNotifications(customerId: customerData.customerId),
                      ),
                    ).then((_) {
                      // Refresh unread notifications count when returning from notifications page
                      _fetchUnreadNotifications();
                    });
                  },
                ),
                // ✅ Red Badge for unread notifications count
                if (unreadCount > 0)
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
                        unreadCount.toString(),
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
