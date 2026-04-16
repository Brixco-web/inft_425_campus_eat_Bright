enum UserRole {
  student,
  admin,
  vip,
  guest
}

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final double walletBalance;
  final String? photoUrl;
  final String? studentId;
  final String? faculty;

  UserModel({
    required this.uid,
    required this.email,
    this.role = UserRole.student,
    this.walletBalance = 0.0,
    this.photoUrl,
    this.studentId,
    this.faculty,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'],
      studentId: data['studentId'],
      faculty: data['faculty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.name,
      'walletBalance': walletBalance,
      'photoUrl': photoUrl,
      'studentId': studentId,
      'faculty': faculty,
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'vip':
        return UserRole.vip;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.student;
    }
  }
}

