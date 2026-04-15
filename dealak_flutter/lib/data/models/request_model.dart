class PropertyRequestModel {
  final int id;
  final String? propertyType;
  final String? listingType;
  final String? city;
  final String? district;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? minBedrooms;
  final int? maxBedrooms;
  final String? notes;
  final String status;
  final DateTime? createdAt;

  const PropertyRequestModel({
    required this.id,
    this.propertyType,
    this.listingType,
    this.city,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minBedrooms,
    this.maxBedrooms,
    this.notes,
    this.status = 'ACTIVE',
    this.createdAt,
  });

  factory PropertyRequestModel.fromJson(Map<String, dynamic> json) {
    return PropertyRequestModel(
      id: json['id'],
      propertyType: json['property_type'],
      listingType: json['listing_type'],
      city: json['city'],
      district: json['district'],
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      minArea: json['min_area']?.toDouble(),
      maxArea: json['max_area']?.toDouble(),
      minBedrooms: json['min_bedrooms'],
      maxBedrooms: json['max_bedrooms'],
      notes: json['notes'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
