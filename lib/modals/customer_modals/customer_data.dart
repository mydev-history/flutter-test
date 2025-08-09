class CustomerData {
  final String customerId;
  final String firstName;
  final String lastName;
  final String mobilePhone;
  final String emailId;
  final String address;
  final String city;
  final String state;
  final String country;
  final String community;
  final String zipcode;
  final String referralId;
  final bool emailVerified;
  final bool customerStatus;
  final String aptNumber;



  CustomerData({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.mobilePhone,
    required this.emailId,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.community,
    required this.zipcode,
    required this.referralId,
    required this.aptNumber,
    required this.customerStatus,
    required this.emailVerified,
  });

  // Factory constructor to create an instance from API response
  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customerId: json['customer_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      emailId: json['email_id'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      community: json['community'] ?? '',
      zipcode : json['zipcode'] ?? '',
      referralId: json['referral_id'] ?? '',
      customerStatus: json['customer_status'] ?? '',
      emailVerified: json['email_verified'] ?? '',
      aptNumber: json['apt_number'] ?? ''

    );
  }
}
