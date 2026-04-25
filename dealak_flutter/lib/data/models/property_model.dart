import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/models/property_image_model.dart';
import 'package:dealak_flutter/data/models/property_feature_model.dart';

class PropertyModel {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String propertyType;
  final String status;
  final String listingType;
  final double price;
  final String currency;
  final double? areaSqm;
  final int? bedrooms;
  final int? bathrooms;
  final int? floors;
  final int? yearBuilt;
  final String? address;
  final String city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final bool isFeatured;
  final bool isNegotiable;
  final int viewCount;
  final double averageRating;
  final UserModel? owner;
  final UserModel? agent;
  final List<PropertyImageModel> images;
  final List<PropertyFeatureModel> features;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.propertyType,
    required this.status,
    required this.listingType,
    required this.price,
    this.currency = 'SYP',
    this.areaSqm,
    this.bedrooms,
    this.bathrooms,
    this.floors,
    this.yearBuilt,
    this.address,
    required this.city,
    this.district,
    this.latitude,
    this.longitude,
    this.isFeatured = false,
    this.isNegotiable = true,
    this.viewCount = 0,
    this.averageRating = 0,
    this.owner,
    this.agent,
    this.images = const [],
    this.features = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      propertyType: json['property_type'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      listingType: json['listing_type'] ?? 'SALE',
      price: (json['price'] is num ? json['price'] : num.tryParse('${json['price']}') ?? 0).toDouble(),
      currency: json['currency'] ?? 'SYP',
      areaSqm: json['area_sqm'] is num ? json['area_sqm'].toDouble() : (json['area_sqm'] != null ? num.tryParse('${json['area_sqm']}')?.toDouble() : null),
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] : (json['bedrooms'] != null ? int.tryParse('${json['bedrooms']}') : null),
      bathrooms: json['bathrooms'] is int ? json['bathrooms'] : (json['bathrooms'] != null ? int.tryParse('${json['bathrooms']}') : null),
      floors: json['floors'] is int ? json['floors'] : (json['floors'] != null ? int.tryParse('${json['floors']}') : null),
      yearBuilt: json['year_built'] is int ? json['year_built'] : (json['year_built'] != null ? int.tryParse('${json['year_built']}') : null),
      address: json['address'],
      city: json['city'] ?? '',
      district: json['district'],
      latitude: json['latitude'] is num ? json['latitude'].toDouble() : (json['latitude'] != null ? num.tryParse('${json['latitude']}')?.toDouble() : null),
      longitude: json['longitude'] is num ? json['longitude'].toDouble() : (json['longitude'] != null ? num.tryParse('${json['longitude']}')?.toDouble() : null),
      isFeatured: json['is_featured'] == true,
      isNegotiable: json['is_negotiable'] == true,
      viewCount: json['view_count'] is int ? json['view_count'] : (int.tryParse('${json['view_count']}') ?? 0),
      averageRating: (json['average_rating'] is num ? json['average_rating'] : num.tryParse('${json['average_rating']}') ?? 0).toDouble(),
      owner: json['owner'] != null ? UserModel.fromJson(json['owner'] as Map<String, dynamic>) : null,
      agent: json['agent'] != null ? UserModel.fromJson(json['agent'] as Map<String, dynamic>) : null,
      images: json['images'] is List ? (json['images'] as List).map((e) => PropertyImageModel.fromJson(e as Map<String, dynamic>)).toList() : [],
      features: json['features'] is List ? (json['features'] as List).map((e) => PropertyFeatureModel.fromJson(e as Map<String, dynamic>)).toList() : [],
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse('${json['updated_at']}') : null,
    );
  }
}
