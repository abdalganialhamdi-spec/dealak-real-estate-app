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
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      propertyType: json['property_type'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      listingType: json['listing_type'] ?? 'SALE',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SYP',
      areaSqm: json['area_sqm']?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      floors: json['floors'],
      yearBuilt: json['year_built'],
      address: json['address'],
      city: json['city'] ?? '',
      district: json['district'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isFeatured: json['is_featured'] ?? false,
      isNegotiable: json['is_negotiable'] ?? true,
      viewCount: json['view_count'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
      agent: json['agent'] != null ? UserModel.fromJson(json['agent']) : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => PropertyImageModel.fromJson(e)).toList()
          : [],
      features: json['features'] != null
          ? (json['features'] as List).map((e) => PropertyFeatureModel.fromJson(e)).toList()
          : [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
