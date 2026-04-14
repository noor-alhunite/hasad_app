enum UserRole { farmer, trader, factory }
enum UserStatus { pending, approved, rejected }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String phoneNumber;
  final String? profileImage;
  final String? location;
  final double? rating;
  final int? reviewCount;
  final UserStatus status;
  final DateTime createdAt;
  /// رقم الهوية بعد تسجيل الدخول عبر سند (محاكاة).
  final String? nationalId;
  /// true: وضع زائر — واجهة محدودة بدون مصادقة كاملة.
  final bool isGuest;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phoneNumber,
    this.profileImage,
    this.location,
    this.rating,
    this.reviewCount,
    this.status = UserStatus.approved,
    required this.createdAt,
    this.nationalId,
    this.isGuest = false,
  });

  String get roleDisplayName {
    switch (role) {
      case UserRole.farmer:
        return 'مزارع';
      case UserRole.trader:
        return 'تاجر';
      case UserRole.factory:
        return 'مصنع';
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phoneNumber,
    String? profileImage,
    String? location,
    double? rating,
    int? reviewCount,
    UserStatus? status,
    DateTime? createdAt,
    String? nationalId,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      nationalId: nationalId ?? this.nationalId,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
