class PropertyImageModel {
  final int id;
  final String imageUrl;
  final String? thumbnailUrl;
  final bool isPrimary;
  final int sortOrder;

  const PropertyImageModel({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.isPrimary = false,
    this.sortOrder = 0,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'],
      imageUrl: json['image_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
