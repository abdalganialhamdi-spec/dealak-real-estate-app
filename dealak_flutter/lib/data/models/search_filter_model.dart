class SearchFilterModel {
  String? query;
  String? propertyType;
  String? listingType;
  String? city;
  String? district;
  double? minPrice;
  double? maxPrice;
  double? minArea;
  double? maxArea;
  int? bedrooms;
  int? bathrooms;
  String sortBy;
  String sortDir;
  int perPage;

  SearchFilterModel({
    this.query,
    this.propertyType,
    this.listingType,
    this.city,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.bedrooms,
    this.bathrooms,
    this.sortBy = 'created_at',
    this.sortDir = 'desc',
    this.perPage = 20,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (query != null) params['q'] = query;
    if (propertyType != null) params['property_type'] = propertyType;
    if (listingType != null) params['listing_type'] = listingType;
    if (city != null) params['city'] = city;
    if (district != null) params['district'] = district;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (minArea != null) params['min_area'] = minArea;
    if (maxArea != null) params['max_area'] = maxArea;
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (bathrooms != null) params['bathrooms'] = bathrooms;
    params['sort_by'] = sortBy;
    params['sort_dir'] = sortDir;
    params['per_page'] = perPage;
    return params;
  }

  SearchFilterModel copyWith({
    String? query, String? propertyType, String? listingType, String? city,
    String? district, double? minPrice, double? maxPrice, double? minArea,
    double? maxArea, int? bedrooms, int? bathrooms, String? sortBy, String? sortDir,
  }) {
    return SearchFilterModel(
      query: query ?? this.query,
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      city: city ?? this.city,
      district: district ?? this.district,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      sortBy: sortBy ?? this.sortBy,
      sortDir: sortDir ?? this.sortDir,
    );
  }
}
