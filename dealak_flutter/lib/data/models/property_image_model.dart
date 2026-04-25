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
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      isPrimary: json['is_primary'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] : int.tryParse('${json['sort_order']}') ?? 0,
    );
  }
}
