// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class Navbar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const Navbar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final selectedColor = theme.colorScheme.primary;
//     final unselectedColor = theme.colorScheme.onBackground;

//     // Dynamically scale text size based on screen width
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double textSize = screenWidth * 0.03; // Text size scales to 3% of screen width

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.08,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, -1),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(
//             iconPath: 'assets/home.svg',
//             label: 'Home',
//             isSelected: currentIndex == 0,
//             selectedColor: selectedColor,
//             unselectedColor: unselectedColor,
//             textSize: textSize,
//             textStyle: theme.textTheme.bodySmall,
//             onTap: () => onTap(0),
//           ),
//           _buildNavItem(
//             iconPath: 'assets/my-stuff.svg',
//             label: 'My Stuff',
//             isSelected: currentIndex == 2,
//             selectedColor: selectedColor,
//             unselectedColor: unselectedColor,
//             textSize: textSize,
//             textStyle: theme.textTheme.bodySmall,
//             onTap: () => onTap(2),
//           ),
//           _buildNavItem(
//             iconPath: 'assets/wallet.svg',
//             label: 'Wallet',
//             isSelected: currentIndex == 1,
//             selectedColor: selectedColor,
//             unselectedColor: unselectedColor,
//             textSize: textSize,
//             textStyle: theme.textTheme.bodySmall,
//             onTap: () => onTap(1),
//           ),
//           _buildNavItem(
//             iconPath: 'assets/chat.svg',
//             label: 'Chat',
//             isSelected: currentIndex == 3,
//             selectedColor: selectedColor,
//             unselectedColor: unselectedColor,
//             textSize: textSize,
//             textStyle: theme.textTheme.bodySmall,
//             onTap: () => onTap(3),
//           ),
//           _buildNavItem(
//             iconPath: 'assets/profile.svg',
//             label: 'Profile',
//             isSelected: currentIndex == 4,
//             selectedColor: selectedColor,
//             unselectedColor: unselectedColor,
//             textSize: textSize,
//             textStyle: theme.textTheme.bodySmall,
//             onTap: () => onTap(4),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required String iconPath,
//     required String label,
//     required bool isSelected,
//     required Color selectedColor,
//     required Color unselectedColor,
//     required double textSize,
//     required TextStyle? textStyle,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(
//             iconPath,
//             height: 24,
//             color: isSelected ? selectedColor : unselectedColor,
//             placeholderBuilder: (context) => const Icon(Icons.error),
//           ),
//           const SizedBox(height: 4), // Space between icon and label
//           Text(
//             label,
//             style: textStyle?.copyWith(
//               fontSize: textSize,
//               fontWeight: FontWeight.w800,
//               color: isSelected ? selectedColor : unselectedColor,
//             ),
//           ),
//           const SizedBox(height: 4), // Space between label and active indicator
//           if (isSelected)
//             Container(
//               height: 4,
//               width: 30, // Wider bar for active tab
//               decoration: BoxDecoration(
//                 color: selectedColor,
//                 borderRadius: BorderRadius.circular(2), // Rounded corners
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/screens/chat.dart';
import 'package:wah_frontend_flutter/screens/customer_home.dart';
import 'package:wah_frontend_flutter/screens/customers/customer_profile.dart';
import 'package:wah_frontend_flutter/screens/customers/my_stuff.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const Navbar({
    Key? key,
    required this.currentIndex,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onBackground;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textSize = screenWidth * 0.03;

    // Fetch customer data safely
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customerData = customerProvider.customerData;

    // Ensure mobilePhone is not null before using it
    final String mobilePhone = customerData?.mobilePhone.replaceFirst('+', '') ?? "";

    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            iconPath: 'assets/home.svg',
            label: 'Home',
            index: 0,
            destination: CustomerHome(mobilePhone: mobilePhone),
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/my-stuff.svg',
            label: 'My Stuff',
            index: 1,
            destination: const MyStuff(),
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/wallet.svg',
            label: 'Wallet',
            index: 2,
            destination: const Text(""), 
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/chat.svg',
            label: 'Chat',
            index: 3,
            destination: const ChatScreen(), 
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/profile.svg',
            label: 'Profile',
            index: 4,
            destination: const CustomerProfile(), 
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconPath,
    required String label,
    required int index,
    required Widget destination,
    required Color selectedColor,
    required Color unselectedColor,
    required double textSize,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 24,
            color: isSelected ? selectedColor : unselectedColor,
            placeholderBuilder: (context) => const Icon(Icons.error),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w800,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 4,
              width: 30,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
