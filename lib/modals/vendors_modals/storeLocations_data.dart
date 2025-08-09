// storeLocations_data.dart
class StoreLocation {
  final String locationId;
  final String storeManager;
  final String mobilePhone;
  final String storeEmail;
  final String address;
  final String city;
  final String state;
  final String country;
  final int zipcode;
  final bool active;

  StoreLocation({
    required this.locationId,
    required this.storeManager,
    required this.mobilePhone,
    required this.storeEmail,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.active,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      locationId: json['location_id'] ?? '',
      storeManager: json['store_manager'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      storeEmail: json['store_email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      active: json['active'] ?? false,
    );
  }
}
