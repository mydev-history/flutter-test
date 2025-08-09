// class DealData {
//   final String vendorId;
//   final String dealId;
//   final String dealTitle;
//   final String dealDescription;
//   final double regularPrice;
//   final double discountValue;
//   final double wahPrice;
//   final String? dealSubTitle;
//   final String dealStatus;
//   final String termsAndConditions;
//   final List<String> images;
//   final List<String> locationId;
//   final String categoryId;
//   final String availableFrom;
//   final String availableTo;
//   final int couponCount;
//   final int couponRemainingCount;
//   final bool enableFeedback;
//   final bool enableScheduling;
//   final String? address;
//   final String? street;
//   final String? city;
//   final String? state;
//   final String? country;
//   final int? zipcode;
//   final bool? isTrending;
//   final double? rating;
//   final int? reviews;
//   final String? businessName;
//   final String? contactName;
//   final String? mobilePhone;
//   final String? businessLogo;
//   final String? vendorEmail;
//   final String? instaLink;
//   final String? facebookLink;
//   final String? websiteLink;

//   DealData({
//     required this.vendorId,
//     required this.dealId,
//     required this.dealTitle,
//     required this.dealDescription,
//     required this.regularPrice,
//     required this.discountValue,
//     required this.wahPrice,
//     required this.dealStatus,
//     required this.termsAndConditions,
//     required this.images,
//     required this.locationId,
//     required this.categoryId,
//     required this.availableFrom,
//     required this.availableTo,
//     required this.couponCount,
//     required this.couponRemainingCount,
//     required this.enableFeedback,
//     required this.enableScheduling,
//     required this.businessName,
//     required this.contactName,
//     required this.vendorEmail,
//     required this.mobilePhone,
//     this.instaLink,
//     this.facebookLink,
//     this.websiteLink,
//     this.businessLogo,
//     this.dealSubTitle,
//     this.address,
//     this.street,
//     this.city,
//     this.state,
//     this.country,
//     required this.zipcode,
//     this.isTrending,
//     this.rating,
//     this.reviews,
//   });

//   factory DealData.fromJson(Map<String, dynamic> json) {
//     return DealData(
//       vendorId: json['vendor_id'],
//       dealId: json['deal_id'],
//       dealTitle: json['deal_title'],
//       dealDescription: json['deal_description'],
//       regularPrice: json['regular_price'].toDouble(),
//       discountValue: json['discount_value'].toDouble(),
//       wahPrice: json['wah_price'].toDouble(),
//       dealStatus: json['deal_status'],
//       termsAndConditions: json['terms_and_conditions'],
//       images: List<String>.from(json['images'] ?? []),
//       locationId: List<String>.from(json['location_id']),
//       categoryId: json['category_id'],
//       availableFrom: json['available_from'],
//       availableTo: json['available_to'],
//       couponCount: json['coupon_count'],
//       couponRemainingCount: json['coupon_remaining_count'],
//       enableFeedback: json['enable_feedback'],
//       enableScheduling: json['enable_scheduling'],
//       dealSubTitle: json['deal_sub_title'],
//       address: json['address'],
//       street: json['street'],
//       city: json['city'],
//       state: json['state'],
//       country: json['country'],
//       zipcode: json['zipcode'],
//       isTrending: json['isTrending'],
//       rating: json['rating']?.toDouble(),
//       reviews: json['reviews'],
//       businessName: json['vendor']['business_name'],
//       contactName: json['vendor']['contact_name'],
//       mobilePhone: json['vendor']['mobile_phone'],
//       vendorEmail: json['vendor']['vendor_email'],
//       instaLink: json['vendor']['insta_link'],
//       facebookLink: json['vendor']['facebook_link'],
//       websiteLink: json['vendor']['website_link'],
//       businessLogo: json['vendor']['business_logo'],
//     );
//   }
// }

class DealData {
  final String vendorId;
  final String dealId;
  final String dealTitle;
  final String dealDescription;
  final double regularPrice;
  final double discountValue;
  final double wahPrice;
  final String? dealSubTitle;
  final String dealStatus;
  final String termsAndConditions;
  final List<String> images;
  final List<String> locationId;
  final String categoryId;
  final String availableFrom;
  final String availableTo;
  final int couponCount;
  final int couponRemainingCount;
  final bool enableFeedback;
  final bool enableScheduling;
  final String? address;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final int? zipcode;
  final bool? isTrending;
  final double? rating;
  final int? reviews;
  final String? businessName;
  final String? contactName;
  final String? mobilePhone;
  final String? businessLogo;
  final String? vendorEmail;
  final String? instaLink;
  final String? facebookLink;
  final String? websiteLink;
  final bool? isFavorite;
  final double? totalDealRating;


  DealData({
    required this.vendorId,
    required this.dealId,
    required this.dealTitle,
    required this.dealDescription,
    required this.regularPrice,
    required this.discountValue,
    required this.wahPrice,
    required this.dealStatus,
    required this.termsAndConditions,
    required this.images,
    required this.locationId,
    required this.categoryId,
    required this.availableFrom,
    required this.availableTo,
    required this.couponCount,
    required this.couponRemainingCount,
    required this.enableFeedback,
    required this.enableScheduling,
    this.businessName,
    this.contactName,
    this.vendorEmail,
    this.mobilePhone,
    this.instaLink,
    this.facebookLink,
    this.websiteLink,
    this.businessLogo,
    this.dealSubTitle,
    this.address,
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipcode,
    this.isTrending,
    this.rating,
    this.reviews,
    this.isFavorite,
    this.totalDealRating,
  });

  factory DealData.fromJson(Map<String, dynamic> json) {
    return DealData(
      vendorId: json['vendor_id'] ?? "",
      dealId: json['deal_id'] ?? "",
      dealTitle: json['deal_title'] ?? "No Title",
      dealDescription: json['deal_description'] ?? "",
      regularPrice: (json['regular_price'] ?? 0).toDouble(),
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      wahPrice: (json['wah_price'] ?? 0).toDouble(),
      dealStatus: json['deal_status'] ?? "Unknown",
      termsAndConditions: json['terms_and_conditions'] ?? "",
      images: List<String>.from(json['images'] ?? []),
      locationId: List<String>.from(json['location_id'] ?? []),
      categoryId: json['category_id'] ?? "",
      availableFrom: json['available_from'] ?? "",
      availableTo: json['available_to'] ?? "",
      couponCount: json['coupon_count'] ?? 0,
      couponRemainingCount: json['coupon_remaining_count'] ?? 0,
      enableFeedback: json['enable_feedback'] ?? false,
      enableScheduling: json['enable_scheduling'] ?? false,

      // Handling missing vendor details gracefully
      businessName: json['vendor']?['business_name'] ?? "Unknown Vendor",
      contactName: json['vendor']?['contact_name'] ?? "",
      vendorEmail: json['vendor']?['vendor_email'] ?? "",
      mobilePhone: json['vendor']?['mobile_phone'] ?? "",
      instaLink: json['vendor']?['insta_link'] ?? "",
      facebookLink: json['vendor']?['facebook_link'] ?? "",
      websiteLink: json['vendor']?['website_link'] ?? "",
      businessLogo: json['vendor']?['business_logo'] ?? "",
      
      address: json['address'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipcode: json['zipcode'],
      isTrending: json['isTrending'],
      rating: json['rating']?.toDouble(),
      reviews: json['reviews'],
      isFavorite: json['isFavorite'],
      totalDealRating: json['totalDealRating']?.toDouble(),

    );
  }
}