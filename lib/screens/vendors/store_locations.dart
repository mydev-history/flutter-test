// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wah_frontend_flutter/components/vendor_header.dart';
// import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
// import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
// import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
// import 'package:wah_frontend_flutter/screens/vendors/addEdit_store.dart';
// import 'package:wah_frontend_flutter/services/vendor_service.dart';

// class StoreLocations extends StatelessWidget {
//   const StoreLocations({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final VendorData? vendorData = Provider.of<VendorProvider>(context).vendorData;
//     final List<StoreLocation> storeLocations = vendorData?.storeLocations ?? [];

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           VendorHeader(
//             businessName: vendorData?.businessName ?? "Vendor",
//             onNotificationTap: () {
//               print("Notification tapped");
//             },
//           ),

//           // Add Store Button with Image + Text
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddEditStore(vendorId: vendorData!.vendorId),
//                   ),
//                 );
//               },
//               child: Row(
//                 children: [
//                   Image.asset(
//                     "assets/addDeal.png", // Ensure this image exists in assets
//                     width: screenWidth * 0.05,
//                     height: screenHeight * 0.05,
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   Text(
//                     "Add Store",
//                     style: theme.textTheme.headline6,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           Expanded(
//             child: ListView.separated(
//               physics: const BouncingScrollPhysics(),
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
//               itemCount: storeLocations.length,
//               separatorBuilder: (context, index) => const Divider(
//                 color: Colors.black12, // Light divider color
//                 thickness: 0.8,
//               ),
//               itemBuilder: (context, index) {
//                 final location = storeLocations[index];
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: screenHeight * 0.015,
//                     horizontal: screenWidth * 0.04,
//                   ),
//                   leading: Icon(
//                     Icons.store,
//                     size: screenWidth * 0.08,
//                     color: Colors.black,
//                   ),
//                   title: Text(
//                     location.address,
//                     style: theme.textTheme.titleMedium,
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${location.city}, ${location.state}",
//                         style: theme.textTheme.bodySmall,
//                       ),
//                       Text(
//                         "Manager: ${location.storeManager}",
//                         style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   // Trailing row with delete and arrow icons.
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Delete icon button.
//                       IconButton(
//                         icon: Icon(
//                           Icons.delete,
//                           size: screenWidth * 0.05,
//                           color: Colors.red,
//                         ),
//                         onPressed: () async {
//                           // Show a confirmation dialog before deletion.
//                           bool? confirmDelete = await showDialog<bool>(
//                             context: context,
//                             builder: (context) {
//                               return AlertDialog(
//                                 title: const Text('Delete Store'),
//                                 content: const Text(
//                                     'Are you sure you want to delete this store location?'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(false),
//                                     child: const Text('Cancel'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(true),
//                                     child: const Text(
//                                       'Delete',
//                                       style: TextStyle(color: Colors.red),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );

//                           if (confirmDelete != null && confirmDelete) {
//                             try {
//                               final vendorService = VendorService();
//                               bool success = await vendorService.deleteStoreLocation(
//                                   vendorData!.vendorId, location.locationId);
//                               if (success) {
//                                 // Update provider state by removing the deleted store.
//                                 final vendorProvider = Provider.of<VendorProvider>(
//                                     context,
//                                     listen: false);
//                                 List<StoreLocation> updatedLocations =
//                                     List.from(vendorData.storeLocations);
//                                 updatedLocations.removeWhere(
//                                     (loc) => loc.locationId == location.locationId);

//                                 // Create updated vendor data with new list of store locations.
//                                 final updatedVendorData = VendorData(
//                                   vendorId: vendorData.vendorId,
//                                   businessName: vendorData.businessName,
//                                   businessLogo: vendorData.businessLogo,
//                                   contactName: vendorData.contactName,
//                                   vendorEmail: vendorData.vendorEmail,
//                                   licenseNumber: vendorData.licenseNumber,
//                                   categoryId: vendorData.categoryId,
//                                   facebookLink: vendorData.facebookLink,
//                                   websiteLink: vendorData.websiteLink,
//                                   instaLink: vendorData.instaLink,
//                                   approvedStatus: vendorData.approvedStatus,
//                                   emailVerified: vendorData.emailVerified,
//                                   vendorTrail: vendorData.vendorTrail,
//                                   mobilePhone: vendorData.mobilePhone,
//                                   storeLocations: updatedLocations,
//                                   walletBalance: vendorData.walletBalance,
//                                   totalDeals: vendorData.totalDeals,
//                                   totalPublishedCoupons: vendorData.totalPublishedCoupons,
//                                   totalRedeemedCoupons: vendorData.totalRedeemedCoupons,
//                                   totalRevenueGenerated: vendorData.totalRevenueGenerated,
//                                 );
//                                 vendorProvider.setVendorData(updatedVendorData);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text('Store location deleted successfully')),
//                                 );
//                               }
//                             } catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Error deleting store location: $e')),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                       SizedBox(width: screenWidth * 0.02),
//                       // Arrow forward icon.
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         size: screenWidth * 0.05,
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddEditStore(
//                           vendorId: vendorData!.vendorId, // Pass Vendor ID
//                           storeLocation: location, // Pass selected store data
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: VendorNavbar(
//         currentIndex: 4,
//         context: context,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/components/vendor_header.dart';
import 'package:wah_frontend_flutter/components/vendor_navbar.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
import 'package:wah_frontend_flutter/screens/vendors/addEdit_store.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:wah_frontend_flutter/components/popUp.dart'; // Ensure PopUp is imported

class StoreLocations extends StatelessWidget {
  const StoreLocations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final VendorData? vendorData = Provider.of<VendorProvider>(context).vendorData;
    final List<StoreLocation> storeLocations = vendorData?.storeLocations ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          VendorHeader(
            businessName: vendorData?.businessName ?? "Vendor",
            onNotificationTap: () {
              print("Notification tapped");
            },
          ),

          // Add Store Button with Image + Text
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditStore(vendorId: vendorData!.vendorId),
                  ),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/addDeal.png", // Ensure this image exists in assets
                    width: screenWidth * 0.05,
                    height: screenHeight * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    "Add Store",
                    style: theme.textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              itemCount: storeLocations.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black12,
                thickness: 0.8,
              ),
              itemBuilder: (context, index) {
                final location = storeLocations[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                    horizontal: screenWidth * 0.04,
                  ),
                  leading: Icon(
                    Icons.store,
                    size: screenWidth * 0.08,
                    color: Colors.black,
                  ),
                  title: Text(
                    location.address,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${location.city}, ${location.state}",
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        "Manager: ${location.storeManager}",
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delete icon that calls handleDeleteStore on tap.
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: screenWidth * 0.05,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (vendorData != null) {
                            handleDeleteStore(context, vendorData, location);
                          }
                        },
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.05,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditStore(
                          vendorId: vendorData!.vendorId,
                          storeLocation: location,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: VendorNavbar(
        currentIndex: 4,
        context: context,
      ),
    );
  }
  
  /// Function to handle deletion of a store location using the PopUp component.
  Future<void> handleDeleteStore(
      BuildContext context, VendorData vendorData, StoreLocation location) async {
    // Use part of the location ID as the confirmation code or fallback to "DELETE".
    String confirmationCode = location.locationId.split("_").length > 1
        ? location.locationId.split("_")[1]
        : "DELETE";

    // Show the confirmation popup.
    bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      builder: (context) {
        return PopUp(
          message: "Type '$confirmationCode' to confirm deletion of this store.",
          icon: "assets/close.png", // Use an appropriate icon for deletion.
          isCancel: true,
          mainButtonText: "Delete",
          isConfirmationRequired: true,
          confirmationText: confirmationCode,
        );
      },
    );

    // If the user confirmed, proceed with deletion.
    if (confirmed != null && confirmed == true) {
      try {
        final vendorService = VendorService();
        bool success = await vendorService.deleteStoreLocation(
            vendorData.vendorId, location.locationId);
        if (success) {
          // Update provider state: remove the deleted store location.
          final vendorProvider =
              Provider.of<VendorProvider>(context, listen: false);
          List<StoreLocation> updatedLocations =
              List.from(vendorData.storeLocations);
          updatedLocations.removeWhere(
              (loc) => loc.locationId == location.locationId);

          final updatedVendorData = VendorData(
            vendorId: vendorData.vendorId,
            businessName: vendorData.businessName,
            businessLogo: vendorData.businessLogo,
            contactName: vendorData.contactName,
            vendorEmail: vendorData.vendorEmail,
            licenseNumber: vendorData.licenseNumber,
            categoryId: vendorData.categoryId,
            facebookLink: vendorData.facebookLink,
            websiteLink: vendorData.websiteLink,
            instaLink: vendorData.instaLink,
            approvedStatus: vendorData.approvedStatus,
            emailVerified: vendorData.emailVerified,
            vendorTrail: vendorData.vendorTrail,
            mobilePhone: vendorData.mobilePhone,
            storeLocations: updatedLocations,
            walletBalance: vendorData.walletBalance,
            totalDeals: vendorData.totalDeals,
            totalPublishedCoupons: vendorData.totalPublishedCoupons,
            totalRedeemedCoupons: vendorData.totalRedeemedCoupons,
            totalRevenueGenerated: vendorData.totalRevenueGenerated,
          );
          vendorProvider.setVendorData(updatedVendorData);

          // Show success popup.
          await showModalBottomSheet(
            context: context,
            builder: (context) {
              return const PopUp(
                message: "Store deleted successfully",
                icon: "assets/success.png",
                isCancel: false,
                mainButtonText: "Close",
              );
            },
          );
        } else {
          // Show failure popup.
          await showModalBottomSheet(
            context: context,
            builder: (context) {
              return const PopUp(
                message: "Failed to delete store.",
                icon: "assets/close.png",
                isCancel: false,
                mainButtonText: "Close",
              );
            },
          );
        }
      } catch (e) {
        // Show error popup.
        await showModalBottomSheet(
          context: context,
          builder: (context) {
            return PopUp(
              message: "Error deleting store: $e",
              icon: "assets/close.png",
              isCancel: false,
              mainButtonText: "Close",
            );
          },
        );
      }
    }
  }
}