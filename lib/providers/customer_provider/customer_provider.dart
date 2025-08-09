import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/customer_data.dart';

class CustomerProvider with ChangeNotifier {
  CustomerData? _customerData;

  // Getter for customer data
  CustomerData? get customerData => _customerData;

  // Setter for customer data
  void setCustomerData(CustomerData data) {
    print("inside provider");
    _customerData = data;
    notifyListeners(); // Notify listeners about the update
  }

  // Clear customer data (e.g., on logout)
  void clearCustomerData() {
    _customerData = null;
    notifyListeners();
  }
}
