import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wah_frontend_flutter/providers/vendors_provider/vendor_provider.dart';
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class VendorEdit extends StatefulWidget {
  const VendorEdit({Key? key}) : super(key: key);

  @override
  _VendorEditState createState() => _VendorEditState();
}

class _VendorEditState extends State<VendorEdit> {
  final GlobalKey<FormState> _step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step4Key = GlobalKey<FormState>();

  final VendorService _vendorService = VendorService();

  final Map<String, dynamic> _formData = {
    'business_name': '',
    'business_logo': null,
    'contact_name': '',
    'vendor_email': '',
    'license_number': '',
    'category_id': null,
    'facebook_link': '',
    'website_link': '',
    'instagram_link': '',
  };

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  File? _selectedImage;

  bool showStep1 = true;
  bool showStep2 = false;
  bool showStep4 = false;
  bool showReview = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _fetchCategories();
  }

  void _initializeFormData() {
    final vendorData = Provider.of<VendorProvider>(context, listen: false).vendorData;
    if (vendorData != null) {
      _formData['business_name'] = vendorData.businessName;
      _formData['business_logo'] = vendorData.businessLogo;
      _formData['contact_name'] = vendorData.contactName;
      _formData['vendor_email'] = vendorData.vendorEmail;
      _formData['license_number'] = vendorData.licenseNumber;
      _formData['category_id'] = vendorData.categoryId;
      _formData['facebook_link'] = vendorData.facebookLink;
      _formData['website_link'] = vendorData.websiteLink;
      _formData['instagram_link'] = vendorData.instaLink;
      _selectedCategoryId = vendorData.categoryId;
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _vendorService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
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
      setState(() {
        showStep1 = false;
        showStep2 = true;
        showStep4 = false;
        showReview = false;
      });
    }
  }

  void _goToStep4() {
    if (_step2Key.currentState!.validate()) {
      _step2Key.currentState!.save();
      setState(() {
        showStep1 = false;
        showStep2 = false;
        showStep4 = true;
        showReview = false;
      });
    }
  }

  void _goToReview() {
    if (_step4Key.currentState!.validate()) {
      _step4Key.currentState!.save();
      setState(() {
        showStep1 = false;
        showStep2 = false;
        showStep4 = false;
        showReview = true;
      });
    }
  }

  Future<void> _updateVendorDetails() async {
    final updatedData = {
      'vendor_id': Provider.of<VendorProvider>(context, listen: false).vendorData?.vendorId,
      'business_name': _formData['business_name'],
      'contact_name': _formData['contact_name'],
      'vendor_email': _formData['vendor_email'],
      'category_id': _selectedCategoryId,
      'facebook_link': _formData['facebook_link'],
      'website_link': _formData['website_link'],
      'insta_link': _formData['instagram_link'],
    };

    try {
      print("inside try");
      bool isUpdated = await _vendorService.updateVendorDetails(updatedData);
      if (isUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor details updated successfully!')),
        );
        Navigator.pop(context, true); // Navigate back with success
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vendor details: $e')),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
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
            initialValue: _formData['business_name'],
            decoration: const InputDecoration(labelText: 'Business Name'),
            onSaved: (value) => _formData['business_name'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Business Name is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.upload, color: Colors.grey),
                  ),
                  Expanded(
                    child: Text(
                      _selectedImage == null
                          ? 'Upload Business Logo'
                          : 'Logo Selected',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'Select Category'),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['category_id'],
                child: Text(category['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep2,
              child: const Text('Next'),
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
            initialValue: _formData['contact_name'],
            decoration: const InputDecoration(labelText: 'Contact Name'),
            onSaved: (value) => _formData['contact_name'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Contact Name is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['vendor_email'],
            decoration: const InputDecoration(labelText: 'Email'),
            onSaved: (value) => _formData['vendor_email'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Email is required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['license_number'],
            decoration: const InputDecoration(labelText: 'License Number (View Only)'),
            readOnly: true,
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep4,
              child: const Text('Next'),
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
            initialValue: _formData['facebook_link'],
            decoration: const InputDecoration(labelText: 'Facebook Link'),
            onSaved: (value) => _formData['facebook_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['website_link'],
            decoration: const InputDecoration(labelText: 'Website Link'),
            onSaved: (value) => _formData['website_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['instagram_link'],
            decoration: const InputDecoration(labelText: 'Instagram Link'),
            onSaved: (value) => _formData['instagram_link'] = value ?? '',
          ),
          SizedBox(height: screenHeight * 0.03),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToReview,
              child: const Text('Next'),
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
        Text('Email: ${_formData['vendor_email']}'),
        Text('License Number: ${_formData['license_number']}'),
        Text('Facebook Link: ${_formData['facebook_link']}'),
        Text('Website Link: ${_formData['website_link']}'),
        Text('Instagram Link: ${_formData['instagram_link']}'),
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
            onPressed: _updateVendorDetails,
            child: const Text('Save Changes'),
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
      appBar: AppBar(
        title: const Text('Edit Vendor Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              showStep1
                  ? 'Edit Vendor Details\nStep 1'
                  : showStep2
                      ? 'Step 2'
                      : showStep4
                          ? 'Step 4'
                          : 'Review and Save Changes',
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
