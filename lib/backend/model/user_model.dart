class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "admin" or "user"
  final String? studentId;
  final String? phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'],
      email: map['email'],
      role: map['role'],
      studentId: map['studentId'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "role": role,
      "studentId": studentId,
      "phone": phone,
    };
  }
}
