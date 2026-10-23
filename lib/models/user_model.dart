enum UserRole { customer, provider, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final UserRole role;
  final bool isBlocked;
  final DateTime createdAt;
  final String password;
  final String? address;
  final List<String> savedAddresses;
  final String? serviceCategory;
  final double? hourlyRate;
  final String? adminPasscode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    this.isBlocked = false,
    required this.createdAt,
    this.password = 'password123',
    this.address,
    this.savedAddresses = const [],
    this.serviceCategory,
    this.hourlyRate,
    this.adminPasscode,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isBlocked,
    DateTime? createdAt,
    String? password,
    String? address,
    List<String>? savedAddresses,
    String? serviceCategory,
    double? hourlyRate,
    String? adminPasscode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      password: password ?? this.password,
      address: address ?? this.address,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      adminPasscode: adminPasscode ?? this.adminPasscode,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? defaultPassword}) {
    UserRole parsedRole = UserRole.customer;
    final rStr = (map['role'] ?? '').toString().toLowerCase().trim();
    if (rStr == 'admin' || rStr == 'userrole.admin') {
      parsedRole = UserRole.admin;
    } else if (rStr == 'provider' || rStr == 'worker' || rStr == 'userrole.provider') {
      parsedRole = UserRole.provider;
    } else {
      parsedRole = UserRole.customer;
    }

    final rawSaved = map['savedAddresses'];
    List<String> parsedSaved = [];
    if (rawSaved is List) {
      parsedSaved = rawSaved
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final singleAddr = map['address']?.toString().trim();
    if (singleAddr != null && singleAddr.isNotEmpty && !parsedSaved.contains(singleAddr)) {
      parsedSaved.insert(0, singleAddr);
    }

    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'ApnaExpert User',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      role: parsedRole,
      isBlocked: map['isBlocked'] == true,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      password: map['password']?.toString() ?? defaultPassword ?? 'password123',
      address: singleAddr,
      savedAddresses: parsedSaved,
      serviceCategory: map['serviceCategory']?.toString(),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble(),
      adminPasscode: map['adminPasscode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'password': password,
      'address': address,
      'savedAddresses': savedAddresses,
      'serviceCategory': serviceCategory,
      'hourlyRate': hourlyRate,
      'adminPasscode': adminPasscode,
    };
  }
}
