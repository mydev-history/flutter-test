// storeLocations_provider.dart
import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/vendors_modals/vendor_data.dart'; // Importing from vendor_data.dart
import 'package:wah_frontend_flutter/services/vendor_service.dart';

class StoreLocationsProvider with ChangeNotifier {
  List<StoreLocation> _storeLocations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StoreLocation> get storeLocations => _storeLocations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final VendorService _vendorService = VendorService();

  Future<void> fetchStoreLocations(String vendorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _storeLocations = await _vendorService.getStoreLocations(vendorId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
