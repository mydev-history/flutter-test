class VendorData {
  final String vendorId;
  final String businessName;
  final String businessLogo;
  final String contactName;
  final String vendorEmail;
  final String licenseNumber;
  final String categoryId;
  final String facebookLink;
  final String websiteLink;
  final String instaLink;
  final bool approvedStatus;
  final bool emailVerified;
  final bool vendorTrail;
  final String mobilePhone;
  final List<StoreLocation> storeLocations;
  final double walletBalance;
  final int totalDeals;
  final int totalPublishedCoupons;
  final int totalRedeemedCoupons;
  final double totalRevenueGenerated;
  VendorData({
    required this.vendorId,
    required this.businessName,
    required this.businessLogo,
    required this.contactName,
    required this.vendorEmail,
    required this.licenseNumber,
    required this.categoryId,
    required this.facebookLink,
    required this.websiteLink,
    required this.instaLink,
    required this.approvedStatus,
    required this.emailVerified,
    required this.vendorTrail,
    required this.mobilePhone,
    required this.storeLocations,
    required this.walletBalance,
    required this.totalDeals,
    required this.totalPublishedCoupons,
    required this.totalRedeemedCoupons,
    required this.totalRevenueGenerated
  });

  factory VendorData.fromJson(Map<String, dynamic> json) {
    return VendorData(
      vendorId: json['vendor']['vendor_id'] ?? '',
      businessName: json['vendor']['business_name'] ?? '',
      businessLogo: json['vendor']['business_logo'] ?? '',
      contactName: json['vendor']['contact_name'] ?? '',
      vendorEmail: json['vendor']['vendor_email'] ?? '',
      licenseNumber: json['vendor']['license_number'] ?? '',
      categoryId: json['vendor']['category_id'] ?? '',
      facebookLink: json['vendor']['facebook_link'] ?? '',
      websiteLink: json['vendor']['website_link'] ?? '',
      instaLink: json['vendor']['insta_link'] ?? '',
      approvedStatus: json['vendor']['approved_status'] ?? false,
      emailVerified: json['vendor']['email_verified'] ?? false,
      vendorTrail: json['vendor']['vendor_trail'] ?? false,
      mobilePhone: json['vendor']['mobile_phone'] ?? '',
      storeLocations: (json['storeLocations'] as List<dynamic>)
          .map((location) => StoreLocation.fromJson(location))
          .toList(),
      walletBalance: json['walletBalance']?.toDouble() ?? 0.0,
      totalDeals: json['totalDeals'] ?? 0.0,
      totalPublishedCoupons: json['totalPublishedCoupons'] ?? 0.0,
      totalRedeemedCoupons: json['totalRedeemedCoupons'] ?? 0.0,
      totalRevenueGenerated: json['totalRevenueGenerated']?.toDouble() ?? 0.0
    );
  }
}

class StoreLocation {
  final String vendorId;
  final String locationId;
  final String storeManager;
  final String mobilePhone;
  final String storeEmail;
  final String address;
  final String street;
  final String city;
  final String state;
  final String country;
  final int zipcode;
  final bool active;

  StoreLocation({
    required this.vendorId,
    required this.locationId,
    required this.storeManager,
    required this.mobilePhone,
    required this.storeEmail,
    required this.address,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.active,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      vendorId: json['vendor_id'] ?? '',
      locationId: json['location_id'] ?? '',
      storeManager: json['store_manager'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      storeEmail: json['store_email'] ?? '',
      address: json['address'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      active: json['active'] ?? false,
    );
  }
}
