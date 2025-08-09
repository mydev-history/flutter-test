class VendorDeal {
  final String dealId;
  final String dealTitle;
  final double regularPrice;
  final double discountValue;
  final double wahPrice;
  final String dealStatus;
  final List<String> dealImages;

  VendorDeal({
    required this.dealId,
    required this.dealTitle,
    required this.regularPrice,
    required this.discountValue,
    required this.wahPrice,
    required this.dealStatus,
    required this.dealImages,
  });

  factory VendorDeal.fromJson(Map<String, dynamic> json) {
    return VendorDeal(
      dealId: json['deal_id'] ?? '',
      dealTitle: json['deal_title'] ?? '',
      regularPrice: (json['regular_price'] ?? 0).toDouble(),
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      wahPrice: (json['wah_price'] ?? 0).toDouble(),
      dealStatus: json['deal_status'] ?? '',
      dealImages: List<String>.from(json['dealImages'] ?? []),
    );
  }
}
