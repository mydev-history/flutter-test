import 'package:flutter/material.dart';
import 'package:wah_frontend_flutter/modals/app_modals/banner_data.dart';

class BannerProvider with ChangeNotifier {
  List<BannerData> _banners = [];

  // Getter for banners
  List<BannerData> get banners => _banners;

  // Setter for banners
  void setBanners(List<BannerData> bannersList) {
    _banners = bannersList;
    notifyListeners(); // Notify listeners about the update
  }

  // Add a banner
  void addBanner(BannerData banner) {
    _banners.add(banner);
    notifyListeners();
  }

  // Remove a banner
  void removeBanner(String bannerId) {
    _banners.removeWhere((banner) => banner.bannerId == bannerId);
    notifyListeners();
  }

  // Clear all banners
  void clearBanners() {
    _banners = [];
    notifyListeners();
  }
}
