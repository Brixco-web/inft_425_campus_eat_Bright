enum UserRole {
  student,
  admin,
  vip,
  guest
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final double walletBalance;
  final String? photoUrl;
  final String? studentId;
  final String? faculty;
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = UserRole.student,
    this.walletBalance = 0.0,
    this.photoUrl,
    this.studentId,
    this.faculty,
    this.phoneNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: _parseRole(data['role']),
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'],
      studentId: data['studentId'],
      faculty: data['faculty'],
      phoneNumber: data['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'walletBalance': walletBalance,
      'photoUrl': photoUrl,
      'studentId': studentId,
      'faculty': faculty,
      'phoneNumber': phoneNumber,
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

