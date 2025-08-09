
// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:wah_frontend_flutter/components/popUp.dart';
// import 'package:wah_frontend_flutter/services/vendor_service.dart';
// import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AddEditStore extends StatefulWidget {
//   final String vendorId;
//   final StoreLocation? storeLocation;

//   const AddEditStore({Key? key, required this.vendorId, this.storeLocation}) : super(key: key);

//   @override
//   _AddEditStoreState createState() => _AddEditStoreState();
// }

// class _AddEditStoreState extends State<AddEditStore> {
//   final _formKey = GlobalKey<FormState>();
//   final VendorService _vendorService = VendorService();

//   TextEditingController managerController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController streetController = TextEditingController();
//   TextEditingController zipController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController stateController = TextEditingController();
//   TextEditingController countryController = TextEditingController();

//   bool isActive = true;
//   bool isEditMode = false;
//   String? completePhoneNumber;
  
//   @override
//   void initState() {
//     super.initState();
//     if (widget.storeLocation != null) {
//       isEditMode = true;
//       managerController.text = widget.storeLocation!.storeManager;
//       phoneController.text = widget.storeLocation!.mobilePhone;
//       emailController.text = widget.storeLocation!.storeEmail;
//       addressController.text = widget.storeLocation!.address;
//       streetController.text = widget.storeLocation!.street;
//       zipController.text = widget.storeLocation!.zipcode.toString();
//       cityController.text = widget.storeLocation!.city;
//       stateController.text = widget.storeLocation!.state;
//       countryController.text = widget.storeLocation!.country;
//       isActive = widget.storeLocation!.active;
//     }
//   }

//   Future<void> _fetchLocationDetails(String zipCode) async {
//     final String url = 'https://api.zippopotam.us/us/$zipCode';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final locationData = jsonDecode(response.body);
//         setState(() {
//           cityController.text = locationData['places'][0]['place name'];
//           stateController.text = locationData['places'][0]['state'];
//           countryController.text = locationData['country'];
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid Zip Code')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching location details: $e')),
//       );
//     }
//   }

//   Future<void> _showSuccessPopup(BuildContext context, String message) async {
//       bool? isClosed = await showModalBottomSheet<bool>(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) {
//           return  PopUp(
//             message: message,
//             icon: "assets/success.png",
//             isCancel: false,
//             mainButtonText: "Close",
//           );
//         },
//       );

//       // Navigate back to the previous screen if user closes the popup
//       if (isClosed == true) {
//         Navigator.pop(context);
//       }
//     }


//     Future<void> _showFailurePopup(BuildContext context, String message) async {
//       await showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) {
//           return  PopUp(
//             message: message,
//             icon: "assets/close.png", // Provide the actual success icon path
//             isCancel: false,
//             mainButtonText: "Close",
//           );
//         },
//       );
//     }

//   Future<void> _saveStoreLocation() async {
//     if (!_formKey.currentState!.validate()) return;

//     Map<String, dynamic> storeData = {
//       "vendor_id": widget.vendorId,
//       "store_manager": managerController.text,
//       "mobile_phone": completePhoneNumber ?? phoneController.text,
//       "store_email": emailController.text,
//       "address": addressController.text,
//       "street": streetController.text,
//       "city": cityController.text,
//       "state": stateController.text,
//       "country": countryController.text,
//       "zipcode": zipController.text,
//       "active": isActive
//     };

//     try {
//       if (isEditMode) {
//         storeData["location_id"] = widget.storeLocation!.locationId;
//         await _vendorService.editStoreLocation(storeData);
//       } else {
//         await _vendorService.addStoreLocation(storeData);
//       }
//       String message = isEditMode ? "Store updated successfully" : "Store added successfully";
//       _showSuccessPopup(context, message);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(isEditMode ? "Store updated successfully" : "Store added successfully")),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       String message = isEditMode ? "Store updated unsuccessfully" : "Store added unsuccessfully";
//       _showFailurePopup(context, message);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error saving store: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
    

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Bubble Design + Logo
//             Stack(
//               children: [
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: Image.asset(
//                     'assets/hero_bubble.png',
//                     width: screenWidth,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: screenHeight * 0.1),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           'assets/Logo.png',
//                           height: screenHeight * 0.15,
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//                         Text(
//                           isEditMode ? "Edit Store Location" : "Add New Store",
//                           style: theme.textTheme.titleLarge,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.03),

//             // Form Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     _buildTextField("Store Manager", managerController),
//                     _buildPhoneField(),
//                     _buildTextField("Store Email", emailController),
//                     _buildTextField("Address", addressController),
//                     _buildTextField("Apt No/ Suite No", streetController),
//                     _buildTextField("Zipcode", zipController, onChanged: (value) {
//                       if (value.length == 5) _fetchLocationDetails(value);
//                     }),
//                     _buildTextField("City", cityController, readOnly: true),
//                     _buildTextField("State", stateController, readOnly: true),
//                     _buildTextField("Country", countryController, readOnly: true),

//                     SizedBox(height: screenHeight * 0.03),

//                     // Save Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveStoreLocation,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                         ),
//                         child: const Text(
//                           "Next",
//                           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.03),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, Function(String)? onChanged}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextFormField(
//         controller: controller,
//         readOnly: readOnly,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         validator: (value) => value!.isEmpty ? "$label is required" : null,
//       ),
//     );
//   }

//   Widget _buildPhoneField() {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 15),
//     child: IntlPhoneField(
//       decoration: InputDecoration(
//         labelText: 'Manager Number',
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         counter: const SizedBox(),
//       ),
//       initialCountryCode: 'US',
//       initialValue: isEditMode ? widget.storeLocation?.mobilePhone : '',
//       onChanged: (phone) {
//         completePhoneNumber = phone.completeNumber.replaceFirst('+', '');
//       },
//       onCountryChanged: (country) {
//         // Optionally update country code logic if needed
//       },
//     ),
//   );
// }

// }


import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';
import 'package:provider/provider.dart'; // Added Provider import
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEditStore extends StatefulWidget {
  final String vendorId;
  final StoreLocation? storeLocation;

  const AddEditStore({Key? key, required this.vendorId, this.storeLocation})
      : super(key: key);

  @override
  _AddEditStoreState createState() => _AddEditStoreState();
}

class _AddEditStoreState extends State<AddEditStore> {
  final _formKey = GlobalKey<FormState>();
  final VendorService _vendorService = VendorService();

  TextEditingController managerController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController? streetController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  bool isActive = true;
  bool isEditMode = false;
  String? completePhoneNumber;

  @override
  void initState() {
    super.initState();
    if (widget.storeLocation != null) {
      isEditMode = true;
      managerController.text = widget.storeLocation!.storeManager;
      phoneController.text = widget.storeLocation!.mobilePhone;
      emailController.text = widget.storeLocation!.storeEmail;
      addressController.text = widget.storeLocation!.address;
      streetController?.text = widget.storeLocation!.street;
      zipController.text = widget.storeLocation!.zipcode.toString();
      cityController.text = widget.storeLocation!.city;
      stateController.text = widget.storeLocation!.state;
      countryController.text = widget.storeLocation!.country;
      isActive = widget.storeLocation!.active;
    }
  }

  Future<void> _fetchLocationDetails(String zipCode) async {
    final String url = 'https://api.zippopotam.us/us/$zipCode';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final locationData = jsonDecode(response.body);
        setState(() {
          cityController.text = locationData['places'][0]['place name'];
          stateController.text = locationData['places'][0]['state'];
          countryController.text = locationData['country'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Zip Code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location details: $e')),
      );
    }
  }

  Future<void> _showSuccessPopup(BuildContext context, String message) async {
    bool? isClosed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopUp(
          message: message,
          icon: "assets/success.png",
          isCancel: false,
          mainButtonText: "Close",
        );
      },
    );

    // Navigate back to the previous screen when the popup is closed.
    if (isClosed == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _showFailurePopup(BuildContext context, String message) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopUp(
          message: message,
          icon: "assets/close.png",
          isCancel: false,
          mainButtonText: "Close",
        );
      },
    );
  }

  Future<void> _saveStoreLocation() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> storeData = {
      "vendor_id": widget.vendorId,
      "store_manager": managerController.text,
      "mobile_phone": completePhoneNumber ?? phoneController.text,
      "store_email": emailController.text,
      "address": addressController.text,
      "street": streetController?.text,
      "city": cityController.text,
      "state": stateController.text,
      "country": countryController.text,
      "zipcode": zipController.text,
      "active": isActive,
    };

    try {
      dynamic response;
      if (isEditMode) {
        // When editing, include the location_id and call the edit API.
        storeData["location_id"] = widget.storeLocation!.locationId;
        response = await _vendorService.editStoreLocation(storeData);
      } else {
        // When adding, call the add API.
        response = await _vendorService.addStoreLocation(storeData);
      }

      // Update vendor provider state locally.
      final vendorProvider =
          Provider.of<VendorProvider>(context, listen: false);
      final currentVendorData = vendorProvider.vendorData;
      if (currentVendorData != null) {
        List<StoreLocation> updatedLocations =
            List.from(currentVendorData.storeLocations);

        // Determine the location ID.
        // For edit mode, use the existing ID.
        // For add mode, if the response is a bool (true), generate a temporary ID.
        String locationId = isEditMode
            ? widget.storeLocation!.locationId
            : (response is bool && response == true
                ? DateTime.now().millisecondsSinceEpoch.toString()
                : response['location_id']);

        // Create the new/updated store location.
        StoreLocation updatedStoreLocation = StoreLocation(
          vendorId: widget.vendorId,
          locationId: locationId,
          storeManager: managerController.text,
          mobilePhone: completePhoneNumber ?? phoneController.text,
          storeEmail: emailController.text,
          address: addressController.text,
          street: streetController!.text,
          city: cityController.text,
          state: stateController.text,
          country: countryController.text,
          zipcode: int.tryParse(zipController.text) ?? 0,
          active: isActive,
        );

        if (isEditMode) {
          // Replace the existing store location.
          int index = updatedLocations.indexWhere(
              (loc) => loc.locationId == widget.storeLocation!.locationId);
          if (index != -1) {
            updatedLocations[index] = updatedStoreLocation;
          }
        } else {
          // Add the new store location.
          updatedLocations.add(updatedStoreLocation);
        }

        // Create an updated VendorData with the new list of store locations.
        final updatedVendorData = VendorData(
          vendorId: currentVendorData.vendorId,
          businessName: currentVendorData.businessName,
          businessLogo: currentVendorData.businessLogo,
          contactName: currentVendorData.contactName,
          vendorEmail: currentVendorData.vendorEmail,
          licenseNumber: currentVendorData.licenseNumber,
          categoryId: currentVendorData.categoryId,
          facebookLink: currentVendorData.facebookLink,
          websiteLink: currentVendorData.websiteLink,
          instaLink: currentVendorData.instaLink,
          approvedStatus: currentVendorData.approvedStatus,
          emailVerified: currentVendorData.emailVerified,
          vendorTrail: currentVendorData.vendorTrail,
          mobilePhone: currentVendorData.mobilePhone,
          storeLocations: updatedLocations,
          walletBalance: currentVendorData.walletBalance,
          totalDeals: currentVendorData.totalDeals,
          totalPublishedCoupons: currentVendorData.totalPublishedCoupons,
          totalRedeemedCoupons: currentVendorData.totalRedeemedCoupons,
          totalRevenueGenerated: currentVendorData.totalRevenueGenerated,
        );
        vendorProvider.setVendorData(updatedVendorData);
      }

      String message =
          isEditMode ? "Store updated successfully" : "Store added successfully";
      await _showSuccessPopup(context, message);
    } catch (e) {
      String message =
          isEditMode ? "Store updated unsuccessfully" : "Store added unsuccessfully";
      await _showFailurePopup(context, message);
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving store: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bubble Design + Logo
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
                          isEditMode ? "Edit Store Location" : "Add New Store",
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),

            // Form Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Store Manager", managerController),
                    _buildPhoneField(),
                    _buildTextField("Store Email", emailController),
                    _buildTextField("Address", addressController),
                    // Mark Apt/Suite No as optional by setting isOptional: true.
                    _buildTextField("Apt No/ Suite No", streetController!, isOptional: true),
                    _buildTextField("Zipcode", zipController, onChanged: (value) {
                      if (value.length == 5) _fetchLocationDetails(value);
                    }),
                    _buildTextField("City", cityController, readOnly: true),
                    _buildTextField("State", stateController, readOnly: true),
                    _buildTextField("Country", countryController, readOnly: true),

                    SizedBox(height: screenHeight * 0.03),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStoreLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated _buildTextField accepts an optional isOptional flag.
  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, Function(String)? onChanged, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: IntlPhoneField(
        decoration: InputDecoration(
          labelText: 'Manager Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          counter: const SizedBox(),
        ),
        initialCountryCode: 'US',
        initialValue: isEditMode ? widget.storeLocation?.mobilePhone : '',
        onChanged: (phone) {
          completePhoneNumber = phone.completeNumber.replaceFirst('+', '');
        },
        onCountryChanged: (country) {
          // Optionally update country code logic if needed
        },
      ),
    );
  }
}
