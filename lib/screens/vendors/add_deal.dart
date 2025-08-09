import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:wah_frontend_flutter/components/popUp.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_payment.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';

 import 'package:intl/intl.dart'; // ✅ Import Date Formatting package

class AddDeal extends StatefulWidget {
  final String vendorId;

  const AddDeal({Key? key, required this.vendorId}) : super(key: key);

  @override
  _AddDealState createState() => _AddDealState();
}

class _AddDealState extends State<AddDeal> {
  final GlobalKey<FormState> _step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step4Key = GlobalKey<FormState>();

  final VendorService _vendorService = VendorService();
  final AppService _appService = AppService();

  bool showStep1 = true;
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;

  File? _selectedImage;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _storeLocations = [];
  List<Map<String, dynamic>> _discountTypes = [];
  String? _selectedCategory;
  String? _selectedStoreLocation;
  String? _selectedDiscountType;

  final Map<String, dynamic> _dealData = {
    'deal_title': '',
    'deal_description': '',
    'store_location_id': null,
    'deal_images': null,
    'discount_type': null,
    'regular_price': '',
    'discount_value': '',
    'wah_price': '',
    'coupon_count': 1,
    'category_id': null,
    'start_date': '',
    'end_date': '',
    'enable_feedback': false,
    'enable_scheduling': false,
    'terms_and_conditions': 'Deal Terms and Conditions',
    'agreed_to_terms': false
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchStoreLocations();
    _fetchDiscountTypes();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _vendorService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _fetchStoreLocations() async {
    try {
      final storeLocations = await _vendorService.fetchStoreLocations(widget.vendorId);
      if (mounted) {
        setState(() {
          _storeLocations = storeLocations;
        });
      }
    } catch (e) {
      print("Error fetching store locations: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _dealData['deal_images'] = _selectedImage!.path;
      });
    }
  }

  Future<void> _fetchDiscountTypes() async {
    try {
      final discountTypes = await _appService.fetchDiscountTypes();
      print(discountTypes);
      if (mounted) {
        setState(() {
          _discountTypes = discountTypes;
        });
      }
    } catch (e) {
      print("Error fetching discount types: $e");
    }
  }

  void _calculateWahPrice() {
  double regularPrice = double.tryParse(_dealData['regular_price'] ?? '0') ?? 0;
  double discountValue = double.tryParse(_dealData['discount_value'] ?? '0') ?? 0;
  double wahPrice = regularPrice;

  if (_selectedDiscountType != null) {
    String discountType = _discountTypes
        .firstWhere((type) => type['discount_type_id'] == _selectedDiscountType)['discount_type_name'];

    if (discountType == "percentage") {
      wahPrice = regularPrice - ((discountValue / 100) * regularPrice);
    } else if (discountType == "fixed") {
      wahPrice = regularPrice - discountValue;
    }
  }

  setState(() {
    _dealData['wah_price'] = wahPrice.toStringAsFixed(2);
  });
}

Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  DateTime initialDate = DateTime.now();
  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now().add(const Duration(days: 365));

  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (pickedDate != null) {
    setState(() {
      String formattedDate = DateFormat("yyyy-MM-dd'T'00:00:00'Z'").format(pickedDate.toUtc()); // ✅ Fix format

      if (isStartDate) {
        _dealData['start_date'] = formattedDate;
      } else {
        _dealData['end_date'] = formattedDate;
      }
    });
  }
}



  void _goToStep2() {
    if (_step1Key.currentState!.validate()) {
      _step1Key.currentState!.save();
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            showStep1 = false;
            showStep2 = true;
          });
        }
      });
    }
  }

  void _goToNextStep() {
    setState(() {
      if (showStep1 && _step1Key.currentState!.validate()) {
        _step1Key.currentState!.save();
        showStep1 = false;
        showStep2 = true;
      } else if (showStep2 && _step2Key.currentState!.validate()) {
        _step2Key.currentState!.save();
        showStep2 = false;
        showStep3 = true;
      } else if (showStep3 && _step3Key.currentState!.validate()) {
        _step3Key.currentState!.save();
        showStep3 = false;
        showStep4 = true;
      }
    });
  }

// Future<void> _submitDeal() async {
//   if (!_step4Key.currentState!.validate()) {
//     return; // ✅ Ensure all fields are validated before proceeding
//   }

//   _step4Key.currentState!.save(); // ✅ Save form values

//   if (!_dealData['agreed_to_terms']) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('You must agree to the terms and conditions')),
//     );
//     return;
//   }

//   // ✅ Calculate financials
//   double dealPrice = double.parse(_dealData['wah_price']);
//   int couponsCount = _dealData['coupon_count'];
//   double forecastedRevenue = dealPrice * couponsCount;
//   double wahFee = forecastedRevenue * 0.10; // 10% of forecasted revenue
//   double taxes = wahFee * 0.03; // 3% of Wah Fee
//   double totalPrice = wahFee + taxes; // Total amount to be paid

//   if (widget.vendorId.isEmpty || totalPrice <= 0) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Error: Vendor ID or total amount is missing.")),
//   );
//   return;
// }

// final transactionResult = await Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => VendorPaymentPage(
//       vendorId: widget.vendorId,
//       wahFee: wahFee,
//       taxes: taxes,
//       totalPrice: totalPrice,
//       couponsCount: couponsCount,
//       forcastedRevenue: forecastedRevenue,
//       dealImage: "https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg", 
//       dealPrice: _dealData['wah_price'],
//       dealTitle: _dealData['deal_title'],
//       discountValue: _dealData['discount_value'],
//       regularPrice: _dealData['regular_price'],
//     ),
//   ),
// );

//   if (transactionResult != null && transactionResult['success'] == true) {
//     // ✅ Payment successful, proceed with deal submission
//     String? transactionId = transactionResult['transactionId'];

//     DateTime parseDate(String dateString) {
//       return DateTime.parse(dateString);
//     }

//     String formatDateToUTC(DateTime date) {
//       return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(date.toUtc());
//     }

//     final Map<String, dynamic> dealPayload = {
//       "vendor_id": widget.vendorId,
//       "category_id": _dealData['category_id'],
//       "deal_title": _dealData['deal_title'],
//       "deal_description": _dealData['deal_description'],
//       "available_from": formatDateToUTC(parseDate(_dealData['start_date'])), 
//       "available_to": formatDateToUTC(parseDate(_dealData['end_date'])), 
//       "coupon_count": _dealData['coupon_count'],
//       "location_id": [_dealData['store_location_id']],
//       "discount_type_id": _dealData['discount_type'],
//       "regular_price": double.parse(_dealData['regular_price']),
//       "discount_value": double.parse(_dealData['discount_value']),
//       "deal_images": _dealData['deal_images'] ?? _dealData['deal_images'] ?? ["https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg", "https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg"],
//       "wah_price": dealPrice,
//       "coupon_expiry": formatDateToUTC(parseDate(_dealData['end_date'])), 
//       "terms_and_conditions": _dealData['terms_and_conditions'],
//       "transaction_id": transactionId, // ✅ Store transaction ID
//     };

//     try {
//       bool success = await _vendorService.addDeal(dealPayload);
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Deal created successfully!')),
//         );
//         Navigator.pop(context); // ✅ Navigate back after deal submission
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error creating deal: $e')),
//       );
//     }
//   } else {
//     // ❌ Payment Failed -> Show Popup
//     await _showPaymentFailurePopup();
//   }
// }

Future<void> _submitDeal() async {
  if (!_step4Key.currentState!.validate()) {
    return; // ✅ Ensure all fields are validated before proceeding
  }

  _step4Key.currentState!.save(); // ✅ Save form values

  if (!_dealData['agreed_to_terms']) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must agree to the terms and conditions')),
    );
    return;
  }

  // ✅ Calculate financials
  double dealPrice = double.parse(_dealData['wah_price']);
  int couponsCount = _dealData['coupon_count'];
  double forecastedRevenue = dealPrice * couponsCount;
  double wahFee = forecastedRevenue * 0.10; // 10% of forecasted revenue
  double taxes = wahFee * 0.03; // 3% of Wah Fee
  double totalPrice = wahFee + taxes; // Total amount to be paid

  if (widget.vendorId.isEmpty || totalPrice <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error: Vendor ID or total amount is missing.")),
    );
    return;
  }

  // ✅ Navigate to Vendor Payment Page
  final transactionResult = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VendorPaymentPage(
        vendorId: widget.vendorId,
        wahFee: wahFee,
        taxes: taxes,
        totalPrice: totalPrice,
        couponsCount: couponsCount,
        forcastedRevenue: forecastedRevenue,
        dealImage: "https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg",
        dealPrice: _dealData['wah_price'],
        dealTitle: _dealData['deal_title'],
        discountValue: _dealData['discount_value'],
        regularPrice: _dealData['regular_price'],
      ),
    ),
  );

  if (transactionResult != null && transactionResult['success'] == true) {
    // ✅ Payment successful, store transaction ID
    String? transactionId = transactionResult['transactionId'];

    DateTime parseDate(String dateString) {
      return DateTime.parse(dateString);
    }

    String formatDateToUTC(DateTime date) {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(date.toUtc());
    }

    final Map<String, dynamic> dealPayload = {
      "vendor_id": widget.vendorId,
      "category_id": _dealData['category_id'],
      "deal_title": _dealData['deal_title'],
      "deal_description": _dealData['deal_description'],
      "available_from": formatDateToUTC(parseDate(_dealData['start_date'])),
      "available_to": formatDateToUTC(parseDate(_dealData['end_date'])),
      "coupon_count": _dealData['coupon_count'],
      "location_id": [_dealData['store_location_id']],
      "discount_type_id": _dealData['discount_type'],
      "regular_price": double.parse(_dealData['regular_price']),
      "discount_value": double.parse(_dealData['discount_value']),
      "deal_images": _dealData['deal_images'] ?? [
        "https://jcjqmhkgkjfmvfmlgzen.supabase.co/storage/v1/object/public/business_logos/business_logos/1726363478796.jpg"
      ],
      "wah_price": dealPrice,
      "coupon_expiry": formatDateToUTC(parseDate(_dealData['end_date'])),
      "terms_and_conditions": _dealData['terms_and_conditions'],
      "transaction_id": transactionId, // ✅ Store transaction ID
    };

    try {
      // ✅ Insert the deal into the database
      final String dealResponseString = await _vendorService.addDeal(dealPayload);
     // ✅ Parse JSON Response
      final Map<String, dynamic> dealResponse = jsonDecode(dealResponseString);

      // ✅ Extract deal_id (It's always a String)
      String? dealId = dealResponse['data']?['deal_id'];

      if (dealId != null && dealId.isNotEmpty) {
        // ✅ Insert Vendor Transaction into Supabase
        final transactionResponse = await _vendorService.insertVendorTransaction(
          transactionId: transactionId!,
          vendorId: widget.vendorId,
          dealId: dealId, // ✅ Pass as String
          transactionType: "deal_payment",
          status: "completed",
          amount: wahFee + taxes
        );

        if (transactionResponse.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deal created successfully!')),
          );
          Navigator.pop(context); // ✅ Navigate back after successful transaction
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error inserting transaction record.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating deal.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    // ❌ Payment Failed -> Show Popup
    await _showPaymentFailurePopup();
  }
}

Future<void> _showPaymentFailurePopup() async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const PopUp(
        message: "Payment Failed. Please try again.",
        icon: "assets/close.png",
        isCancel: false,
        mainButtonText: "Close",
      );
    },
  );
}

  Widget _buildHeader(String title, double screenHeight, double screenWidth) {
    return Stack(
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
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildStep1Form(double screenHeight, double screenWidth) {
    return Form(
      key: _step1Key,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Deal Title'),
            onSaved: (value) => _dealData['deal_title'] = value!,
            validator: (value) => value!.isEmpty ? 'Deal Title is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Deal Description'),
            maxLines: 3,
            onSaved: (value) => _dealData['deal_description'] = value!,
            validator: (value) => value!.isEmpty ? 'Deal Description is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Store Locations'),
            value: _selectedStoreLocation,
            items: _storeLocations.map((location) {
              return DropdownMenuItem<String>(
                value: location['location_id'],
                child: Text(location['address']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreLocation = value;
                _dealData['store_location_id'] = value;
              });
            },
            validator: (value) => value == null ? 'Please select a store location' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedImage == null ? 'Upload Images' : 'Image Selected',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Icon(Icons.upload),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildStep2Form(double screenHeight, double screenWidth) {
  return Form(
    key: _step2Key,
    child: Column(
      children: [
        // Discount Type Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Discount Type'),
          value: _selectedDiscountType,
          items: _discountTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type['discount_type_id'],
              child: Text(type['discount_type_name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDiscountType = value;
              _dealData['discount_type'] = value;
              _calculateWahPrice(); // Recalculate Wah Price
            });
          },
          validator: (value) => value == null ? 'Please select a discount type' : null,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Regular Price
        TextFormField(
          decoration: const InputDecoration(labelText: 'Regular Price'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _dealData['regular_price'] = value;
              _calculateWahPrice(); // Auto-update Wah Price
            });
          },
          validator: (value) {
            double price = double.tryParse(value ?? '0') ?? 0;
            return price > 0 ? null : 'Enter a valid Regular Price';
          },
        ),
        SizedBox(height: screenHeight * 0.02),

        // Discount Value
        TextFormField(
          decoration: const InputDecoration(labelText: 'Discount Value'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _dealData['discount_value'] = value;
              _calculateWahPrice(); // Auto-update Wah Price
            });
          },
          validator: (value) {
            double discount = double.tryParse(value ?? '0') ?? 0;
            return discount > 0 ? null : 'Enter a valid Discount Value';
          },
        ),
        SizedBox(height: screenHeight * 0.02),

        // Wah! Price (Auto Calculated)
        TextFormField(
          decoration: const InputDecoration(labelText: 'Wah! Price'),
          keyboardType: TextInputType.number,
          initialValue: _dealData['wah_price'],
          readOnly: true,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Coupon Count (1 - 25)
        TextFormField(
          decoration: const InputDecoration(labelText: 'Coupon Count'),
          keyboardType: TextInputType.number,
          initialValue: '1',
          onChanged: (value) {
            int count = int.tryParse(value) ?? 1;
            if (count > 25) count = 25; // Maximum 25
            setState(() {
              _dealData['coupon_count'] = count;
            });
          },
          validator: (value) {
            int count = int.tryParse(value ?? '0') ?? 0;
            return (count > 0 && count <= 25) ? null : 'Enter a value between 1 and 25';
          },
        ),
        SizedBox(height: screenHeight * 0.03),

        // Next Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStep3Form(double screenHeight, double screenWidth) {
  return Form(
    key: _step3Key,
    child: Column(
      children: [
        // Category Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Category'),
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['category_id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _dealData['category_id'] = value;
            });
          },
          validator: (value) => value == null ? 'Please select a category' : null,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Start Date Picker
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Start Date',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, true),
            ),
          ),
          readOnly: true,
          controller: TextEditingController(text: _dealData['start_date']),
          validator: (value) => value!.isEmpty ? 'Select a start date' : null,
        ),
        SizedBox(height: screenHeight * 0.02),

        // End Date Picker
        TextFormField(
          decoration: InputDecoration(
            labelText: 'End Date',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, false),
            ),
          ),
          readOnly: true,
          controller: TextEditingController(text: _dealData['end_date']),
          validator: (value) => value!.isEmpty ? 'Select an end date' : null,
        ),
        SizedBox(height: screenHeight * 0.02),

        // Enable Feedbacks Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable Feedbacks', style: TextStyle(fontSize: 16)),
            Switch(
              value: _dealData['enable_feedback'],
              onChanged: (value) {
                setState(() {
                  _dealData['enable_feedback'] = value;
                });
              },
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Enable Scheduling Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable Scheduling', style: TextStyle(fontSize: 16)),
            Switch(
              value: _dealData['enable_scheduling'],
              onChanged: (value) {
                setState(() {
                  _dealData['enable_scheduling'] = value;
                });
              },
            ),
          ],
        ),
        // SizedBox(height: screenHeight * 0.02),
        SizedBox(height: screenHeight * 0.03),

        // Next Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStep4Form(double screenHeight, double screenWidth) {
  return Form(
    key: _step4Key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Terms and Conditions Text Field
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Deal Terms and Condition',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onSaved: (value) => _dealData['terms_and_conditions'] = "Deal Terms and conditions",
          validator: (value) => value!.isEmpty ? 'Please enter deal terms and conditions' : null,
        ),
        SizedBox(height: screenHeight * 0.03),

        // Terms and Conditions Agreement Checkbox
        Row(
          children: [
            Checkbox(
              value: _dealData['agreed_to_terms'],
              onChanged: (value) {
                setState(() {
                  _dealData['agreed_to_terms'] = value!;
                });
              },
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'Upon continuing, you agree to ',
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'Wah! Terms and Conditions',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.03),

        // Create Deal Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _dealData['agreed_to_terms'] ? _submitDeal : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            ),
            child: const Text(
              'Create Deal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
}





  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              showStep1
                  ? 'Create a Deal\nStep 1'
                  : showStep2
                      ? 'Step 2'
                      : showStep3
                          ? 'Step 3'
                          : 'Step 4',
              screenHeight,
              screenWidth,
            ),
            SizedBox(height: screenHeight * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: showStep1
                  ? _buildStep1Form(screenHeight, screenWidth)
                  : showStep2
                      ? _buildStep2Form(screenHeight, screenWidth)
                      : showStep3
                          ? _buildStep3Form(screenHeight, screenWidth)
                          : showStep4
                              ? _buildStep4Form(screenHeight, screenWidth)
                              : Container(),
            ),

          ],
        ),
      ),
    );
  }
}
