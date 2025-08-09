class BannerData {
  final String bannerId;
  final String title;
  final String bannerImageUrl;
  final String type;
  final String referenceTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerData({
    required this.bannerId,
    required this.title,
    required this.bannerImageUrl,
    required this.type,
    required this.referenceTo,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create an instance from a JSON object
  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      bannerId: json['banner_id'],
      title: json['title'],
      bannerImageUrl: json['banner_image_url'],
      type: json['type'],
      referenceTo: json['reference_to'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'banner_id': bannerId,
      'title': title,
      'banner_image_url': bannerImageUrl,
      'type': type,
      'reference_to': referenceTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}