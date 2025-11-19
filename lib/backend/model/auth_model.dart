class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final UserRole role;
  final bool isEmailVerified;
  final List<String>? managedHostels;
  final String? bio;
  final String? location;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
    this.role = UserRole.student,
    this.isEmailVerified = false,
    this.managedHostels,
    this.bio,
    this.location,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle role conversion safely
    UserRole userRole;
    try {
      userRole = UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'student'),
      );
    } catch (e) {
      userRole = UserRole.student; // Default to student if role is invalid
    }

    return UserModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'],
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.parse(map['lastLogin'])
          : null,
      role: userRole,
      isEmailVerified: map['isEmailVerified'] ?? false,
      managedHostels: map['managedHostels'] != null 
          ? List<String>.from(map['managedHostels'])
          : null,
      bio: map['bio'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'role': role.name,
      'isEmailVerified': isEmailVerified,
      'managedHostels': managedHostels,
      'bio': bio,
      'location': location,
    };
  }

  // Helper getters
  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
  bool get isHostelOwner => role == UserRole.hostelOwner;
  
  String get roleDisplayName => role.displayName;
  
 UserModel copyWith({
  String? fullName,
  String? email,
  String? phone,
  String? bio,
  String? location,
  String? profileImage,
}) {
  return UserModel(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    profileImage: profileImage ?? this.profileImage,
    role: role,
    isEmailVerified: isEmailVerified,
    createdAt: createdAt,
    lastLogin: lastLogin,
  );
}
}

enum UserRole {
  student('Student'),
  admin('Admin'),
  hostelOwner('Hostel Owner');

  const UserRole(this.displayName);
  final String displayName;
}