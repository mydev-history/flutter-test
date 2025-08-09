class CategoryData {
  final String categoryId;
  final String name;
  final String? image;
  final String? description;
  final String status;

  CategoryData({
    required this.categoryId,
    required this.name,
    this.image,
    this.description,
    required this.status,
  });

  // Factory constructor to create an instance from API response
  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      description: json['description'],
      status: json['status'] ?? '',
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'image': image,
      'description': description,
      'status': status,
    };
  }
}
