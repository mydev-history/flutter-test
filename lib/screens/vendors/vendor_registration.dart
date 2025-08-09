import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wah_frontend_flutter/screens/vendors/vendor_otp_screen.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendorRegistration extends StatefulWidget {
  final String mobilePhone;

  VendorRegistration({required this.mobilePhone, super.key});

  @override
  _VendorRegistrationState createState() => _VendorRegistrationState();
}

class _VendorRegistrationState extends State<VendorRegistration> {
  final GlobalKey<FormState> _step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step4Key = GlobalKey<FormState>();
    final SupabaseClient _supabase = Supabase.instance.client;
  
  final Map<String, dynamic> _formData = {
    'business_name': '',
    'business_logo': null,
    'category_id': null,
    'contact_name': '',
    'email': '',
    'license_number': '',
    'address': '',
    'aptNumber': '',
    'zipcode': '',
    'city': '',
    'state': '',
    'country': '',
    'instagram_link': '',
    'facebook_link': '',
    'website_link': '',
  };

  File? _selectedImage;
  final VendorService _vendorService = VendorService();
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  bool showStep1 = true;
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;
  bool showStep5 = false;

   // TextEditingControllers for auto-populating fields
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

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

          _formData['city'] = cityController.text;
          _formData['state'] = stateController.text;
          _formData['country'] = countryController.text;
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

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching categories: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _formData['business_logo'] = _selectedImage!.path;
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

  void _goToStep3() {
    if (_step2Key.currentState!.validate()) {
      _step2Key.currentState!.save();
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            showStep2 = false;
            showStep3 = true;
          });
        }
      });
    }
  }

  void _goToStep4() {
    if (_step3Key.currentState!.validate()) {
      _step3Key.currentState!.save();
      setState(() {
        showStep3 = false;
        showStep4 = true;
      });
    }
  }

  void _goToStep5() {
    if (_step4Key.currentState!.validate()) {
      _step4Key.currentState!.save();
      setState(() {
        showStep4 = false;
        showStep5 = true;
      });
    }
  }

  // Function to register vendor and send OTP
  Future<void> _registerVendor() async {
    final Map<String, dynamic> vendorData = {
      'business_name': _formData['business_name'],
      'business_logo': _formData['business_logo'], // Assuming it's a URL or base64 string
      'contact_name': _formData['contact_name'],
      'vendor_email': _formData['email'],
      'license_number': _formData['license_number'],
      'category_id': _formData['category_id'],
      'facebook_link': _formData['facebook_link'],
      'website_link': _formData['website_link'],
      'insta_link': _formData['instagram_link'],
      'mobile_phone': widget.mobilePhone,
      'storeLocation': {
        'store_manager': _formData['contact_name'],
        'mobile_phone': widget.mobilePhone,
        'store_email': _formData['email'],
        'address': _formData['address'],
        'street': _formData['aptNumber'],
        'city': _formData['city'],
        'state': _formData['state'],
        'country': _formData['country'],
        'zipcode': _formData['zipcode'],
        'active': true,
      },
    };

    try {
      bool isVendorRegistered = await _vendorService.addVendor(vendorData);
      if (isVendorRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor registered successfully! Sending OTP...')),
        );

        // Trigger OTP using Supabase
        await _supabase.auth.signInWithOtp(phone: '+${widget.mobilePhone}');

        // Navigate to the OTP screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VendorOtpScreen(phoneNumber: widget.mobilePhone),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
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
            decoration: InputDecoration(
              labelText: 'Business Name',
              hintText: 'Enter your business name',
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['business_name'] = value ?? '',
            validator: (value) =>
                value!.isEmpty ? 'Business Name is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.upload,
                      color: Theme.of(context).inputDecorationTheme.hintStyle!.color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Business Logo',
                      style: TextStyle(
                        color: Theme.of(context).inputDecorationTheme.hintStyle!.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_upward, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            value: _selectedCategoryId,
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['category_id'],
                child: Text(category['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
                _formData['category_id'] = value;
              });
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep2,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Contact Name',
              hintText: 'Enter contact name',
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['contact_name'] = value ?? '',
            validator: (value) =>
                value!.isEmpty ? 'Contact Name is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter email',
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['email'] = value ?? '',
            validator: (value) =>
                value!.isEmpty ? 'Email is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'License Number',
              hintText: 'Enter license number',
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['license_number'] = value ?? '',
            validator: (value) =>
                value!.isEmpty ? 'License Number is required' : null,
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep3,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['address'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Address is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Apt No/ Suite No',
              hintText: 'Enter apartment or suite number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['aptNumber'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Zipcode',
              hintText: 'Enter zipcode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length == 5) _fetchLocationDetails(value);
              _formData['zipcode'] = value;
            },
            validator: (value) => value!.isEmpty ? 'Zipcode is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            controller: cityController,
            decoration: const InputDecoration(labelText: 'City'),
            readOnly: true,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            controller: stateController,
            decoration: const InputDecoration(labelText: 'State'),
            readOnly: true,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            controller: countryController,
            decoration: const InputDecoration(labelText: 'Country'),
            readOnly: true,
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // onPressed: _completeRegistration,
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed:_goToStep4 ,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Instagram Link',
              hintText: 'Enter Instagram profile link',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['instagram_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Facebook Link',
              hintText: 'Enter Facebook profile link',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['facebook_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Website Link',
              hintText: 'Enter Website link',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
                ),
              ),
            ),
            onSaved: (value) => _formData['website_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep5,
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm(double screenHeight, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Details:',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text('Business Name: ${_formData['business_name']}'),
        Text('Category: ${_categories.firstWhere((c) => c['category_id'] == _formData['category_id'], orElse: () => {'name': 'Not Selected'})['name']}'),
        Text('Contact Name: ${_formData['contact_name']}'),
        Text('Email: ${_formData['email']}'),
        Text('License Number: ${_formData['license_number']}'),
        Text('Address: ${_formData['address']}'),
        Text('City: ${_formData['city']}'),
        Text('State: ${_formData['state']}'),
        Text('Country: ${_formData['country']}'),
        Text('Instagram Link: ${_formData['instagram_link']}'),
        Text('Facebook Link: ${_formData['facebook_link']}'),
        Text('Website Link: ${_formData['website_link']}'),
        if (_formData['business_logo'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.file(
              File(_formData['business_logo']),
              height: 100,
            ),
          ),
        SizedBox(height: screenHeight * 0.03),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _registerVendor,
            style: Theme.of(context).elevatedButtonTheme.style,
            child: const Text(
              'Register',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
              showStep1 ? 'Register as a Vendor\nStep 1'
                  : showStep2
                      ? 'Step 2'
                      : showStep3
                          ? 'Step 3'
                          : showStep4
                              ? 'Step 4'
                              : 'Review and Register',
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
                              : _buildReviewForm(screenHeight, screenWidth),
            ),
          ],
        ),
      ),
    );
  }
}
