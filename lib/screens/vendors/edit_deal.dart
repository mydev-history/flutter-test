import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:wah_frontend_flutter/services/app_service.dart';
import 'package:intl/intl.dart';

class EditDeal extends StatefulWidget {
  final String dealId;

  const EditDeal({Key? key, required this.dealId}) : super(key: key);

  @override
  _EditDealState createState() => _EditDealState();
}

class _EditDealState extends State<EditDeal> {
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

  Map<String, dynamic> _dealData = {
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
    'terms_and_conditions': '',
    'agreed_to_terms': true
  };
  
  get _updateDeal => null;

  @override
  void initState() {
    super.initState();
    _fetchDealDetails();
  }

  Future<void> _fetchDealDetails() async {
    try {
      final dealDetails = await _vendorService.getDealDetail(widget.dealId);
      setState(() {
        _dealData = {
          'deal_title': dealDetails['deal_title'],
          'deal_description': dealDetails['deal_description'],
          'store_location_id': dealDetails['store_location_id'],
          'deal_images': dealDetails['images'],
          'discount_type': dealDetails['discount_type'],
          'regular_price': dealDetails['regular_price'].toString(),
          'discount_value': dealDetails['discount_value'].toString(),
          'wah_price': dealDetails['wah_price'].toString(),
          'coupon_count': dealDetails['coupon_count'],
          'category_id': dealDetails['category_id'],
          'start_date': dealDetails['available_from'],
          'end_date': dealDetails['available_to'],
          'enable_feedback': dealDetails['enable_feedback'],
          'enable_scheduling': dealDetails['enable_scheduling'],
          'terms_and_conditions': dealDetails['terms_and_conditions'],
          'agreed_to_terms': true
        };
      });
    } catch (e) {
      print("Error fetching deal details: $e");
    }
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

  Future<void> _submitEditDeal() async {
    if (!_step4Key.currentState!.validate()) {
      return;
    }

    _step4Key.currentState!.save();

    final Map<String, dynamic> dealPayload = {
      "deal_id": widget.dealId,
      "deal_title": _dealData['deal_title'],
      "deal_description": _dealData['deal_description'],
      "coupon_count": _dealData['coupon_count'],
      "category_id": _dealData['category_id'],
      "available_from": _dealData['start_date'],
      "available_to": _dealData['end_date'],
      "terms_and_conditions": _dealData['terms_and_conditions']
    };

    try {
      bool success = await _vendorService.updateDeal(dealPayload);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating deal: $e')),
      );
    }
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
          // SizedBox(height: screenHeight * 0.03),
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
              // _calculateWahPrice(); // Recalculate Wah Price
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
              // _calculateWahPrice(); // Auto-update Wah Price
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
              // _calculateWahPrice(); // Auto-update Wah Price
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
            onPressed: _dealData['agreed_to_terms'] ? _updateDeal : null,
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
                  ? 'Edit the Deal\nStep 1'
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
                          : _buildStep4Form(screenHeight, screenWidth),
            ),
          ],
        ),
      ),
    );
  }
}
