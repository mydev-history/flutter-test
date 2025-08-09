import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/customer_modals/coupons_data.dart';

class CouponsProvider with ChangeNotifier {
  List<CouponData> _coupons = [];

  List<CouponData> get coupons => _coupons;

  void setCoupons(List<CouponData> couponsList) {
    _coupons = couponsList;
    notifyListeners();
  }

    void removeCoupon(String qrCode) {
    _coupons.removeWhere((coupon) => coupon.qrCode == qrCode);
    notifyListeners();
  }

  void clearCoupons() {
    _coupons = [];
    notifyListeners();
  }
}
