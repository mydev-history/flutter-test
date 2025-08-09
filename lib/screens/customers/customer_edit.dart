import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wah_frontend_flutter/modals/customer_modals/customer_data.dart';
import 'package:wah_frontend_flutter/providers/customer_provider/customer_provider.dart';
import 'package:wah_frontend_flutter/services/customer_service.dart';

class CustomerEdit extends StatefulWidget {
  const CustomerEdit({Key? key}) : super(key: key);

  @override
  _CustomerEditState createState() => _CustomerEditState();
}

class _CustomerEditState extends State<CustomerEdit> {
  final CustomerService _customerService = CustomerService();

  final Map<String, dynamic> _formData = {
    'first_name': '',
    'last_name': '',
    'email_id': '',
    'community': '',
    'address': '',
    'zipcode': '',
    'city': '',
    'state': '',
    'country': '',
  };

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  bool showStep1 = true;
  bool showStep2 = false;

  // TextEditingControllers for auto-populating fields
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Pre-fill data from provider
    final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;
    if (customerData != null) {
      _formData['first_name'] = customerData.firstName;
      _formData['last_name'] = customerData.lastName;
      _formData['email_id'] = customerData.emailId;
      _formData['community'] = customerData.community;
      _formData['address'] = customerData.address;
      _formData['zipcode'] = customerData.city;
      cityController.text = customerData.city;
      stateController.text = customerData.state;
      countryController.text = customerData.country;
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

  void _goToStep2() {
    if (_step1Key.currentState!.validate()) {
      _step1Key.currentState!.save();
      setState(() {
        showStep1 = false;
        showStep2 = true;
      });
    }
  }

  void _goToStep3() {
    if (_step2Key.currentState!.validate()) {
      _step2Key.currentState!.save();
      setState(() {
        showStep2 = false;
      });
    }
  }

  Future<void> _updateCustomer() async {
    final customerData = Provider.of<CustomerProvider>(context, listen: false).customerData;

    if (customerData != null) {
      try {
        bool isUpdated = await _customerService.editCustomer(
          customerData.customerId,
          _formData,
        );

        if (isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
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
            initialValue: _formData['first_name'],
            decoration: const InputDecoration(labelText: 'First Name'),
            onSaved: (value) => _formData['first_name'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['last_name'],
            decoration: const InputDecoration(labelText: 'Last Name'),
            onSaved: (value) => _formData['last_name'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['email_id'],
            decoration: const InputDecoration(labelText: 'Email'),
            onSaved: (value) => _formData['email_id'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            initialValue: _formData['community'],
            decoration: const InputDecoration(labelText: 'Community'),
            onSaved: (value) => _formData['community'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToStep2,
                child:  Text(
                            "Next", 
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
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
            initialValue: _formData['address'],
            decoration: const InputDecoration(labelText: 'Address'),
            onSaved: (value) => _formData['address'] = value ?? '',
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: screenHeight * 0.02),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Zip Code'),
            onChanged: (value) {
              if (value.length == 5) _fetchLocationDetails(value);
              _formData['zipcode'] = value;
            },
            validator: (value) => value!.isEmpty ? 'Required' : null,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToStep3,
                child:  Text("Next", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Review(double screenHeight, double screenWidth) {
    return Column(
      children: [
        ..._formData.entries.map((entry) => Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${entry.key}:'),
                  Text('${entry.value}'),
                ],
              ),
            )),
        SizedBox(height: screenHeight * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateCustomer,
              child:  Text("Update", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              showStep1
                  ? 'Edit Customer Details\nStep 1'
                  : showStep2
                      ? 'Edit Customer Details\nStep 2'
                      : 'Review and Confirm',
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
                      : _buildStep3Review(screenHeight, screenWidth),
            ),
          ],
        ),
      ),
    );
  }
}
