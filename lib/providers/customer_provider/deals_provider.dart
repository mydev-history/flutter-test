import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/deals_data.dart';

class DealsProvider with ChangeNotifier {
  List<DealData> _deals = [];

  List<DealData> get deals => _deals;

  void setDeals(List<DealData> dealsList) {
    _deals = dealsList;
    notifyListeners();
  }

  void clearDeals() {
    _deals = [];
    notifyListeners();
  }
}
