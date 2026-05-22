class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String className;
  final String role;
  final bool blocked;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.className,
    required this.role,
    required this.blocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'idNumber': idNumber,
      'className': className,
      'role': role,
      'blocked': blocked,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      idNumber: map['idNumber'] ?? '',
      className: map['className'] ?? '',
      role: map['role'] ?? '',
      blocked: map['blocked'] ?? false,
    );
  }
}