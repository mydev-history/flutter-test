import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/screens/vendors/chat_vendor.dart';
import 'package:wah_frontend_flutter/screens/vendors/scanner.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_home.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_profile.dart';

class VendorNavbar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const VendorNavbar({
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
    final vendorProvider = Provider.of<VendorProvider>(context);
    final vendorData = vendorProvider.vendorData;

    // Ensure mobilePhone is not null before using it
    final String mobilePhone = vendorData?.mobilePhone.replaceFirst('+', '') ?? "";

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
            destination: VendorHome(mobilePhone: mobilePhone),
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/wallet.svg',
            label: 'Wallet',
            index: 1,
            destination:  VendorHome(mobilePhone: mobilePhone),
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/scanner.svg',
            label: 'Scanner',
            index: 2,
            destination: const Scanner(), 
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/chat.svg',
            label: 'Chat',
            index: 3,
            destination: const VendorChatScreen(), 
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            textSize: textSize,
          ),
          _buildNavItem(
            context,
            iconPath: 'assets/profile.svg',
            label: 'Profile',
            index: 4,
            destination: const VendorProfile(), 
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
