class WorkerModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String avatarUrl;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int totalReviews;
  final double hourlyRate;
  final double distanceKm;
  final String experience;
  final bool isAvailable;
  final bool isVerified;
  final String bio;

  WorkerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.categoryId,
    required this.categoryName,
    required this.rating,
    required this.totalReviews,
    required this.hourlyRate,
    required this.distanceKm,
    required this.experience,
    this.isAvailable = true,
    this.isVerified = true,
    required this.bio,
  });

  WorkerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? avatarUrl,
    String? categoryId,
    String? categoryName,
    double? rating,
    int? totalReviews,
    double? hourlyRate,
    double? distanceKm,
    String? experience,
    bool? isAvailable,
    bool? isVerified,
    String? bio,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      distanceKm: distanceKm ?? this.distanceKm,
      experience: experience ?? this.experience,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'rating': rating,
      'totalReviews': totalReviews,
      'hourlyRate': hourlyRate,
      'distanceKm': distanceKm,
      'experience': experience,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'bio': bio,
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Service Partner',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? 'cat_plumbing',
      categoryName: map['categoryName']?.toString() ?? 'Plumbing',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 5.0,
      totalReviews: (map['totalReviews'] is num) ? (map['totalReviews'] as num).toInt() : 0,
      hourlyRate: (map['hourlyRate'] is num) ? (map['hourlyRate'] as num).toDouble() : 249.0,
      distanceKm: (map['distanceKm'] is num) ? (map['distanceKm'] as num).toDouble() : 1.0,
      experience: map['experience']?.toString() ?? 'Verified Professional',
      isAvailable: map['isAvailable'] == true,
      isVerified: map['isVerified'] != false,
      bio: map['bio']?.toString() ?? '',
    );
  }
}

