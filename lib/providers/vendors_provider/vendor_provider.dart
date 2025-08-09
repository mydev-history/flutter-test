import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart';

class VendorProvider with ChangeNotifier {
  VendorData? _vendorData;

  // Getter for vendor data
  VendorData? get vendorData => _vendorData;

  // Setter for vendor data
  void setVendorData(VendorData data) {
    _vendorData = data;
    notifyListeners(); // Notify listeners about the update
  }

  // Clear vendor data (e.g., on logout)
  void clearVendorData() {
    _vendorData = null;
    notifyListeners();
  }
}
