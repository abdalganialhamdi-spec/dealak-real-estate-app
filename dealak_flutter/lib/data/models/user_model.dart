class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final bool isVerified;
  final int? propertiesCount;
  final int? reviewsCount;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.isVerified = false,
    this.propertiesCount,
    this.reviewsCount,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      role: json['role'] ?? 'BUYER',
      avatarUrl: json['avatar_url']?.toString(),
      bio: json['bio']?.toString(),
      isVerified: json['is_verified'] == true,
      propertiesCount: json['properties_count'] is int ? json['properties_count'] : (json['properties_count'] != null ? int.tryParse('${json['properties_count']}') : null),
      reviewsCount: json['reviews_count'] is int ? json['reviews_count'] : (json['reviews_count'] != null ? int.tryParse('${json['reviews_count']}') : null),
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'role': role,
    'bio': bio,
  };
}
