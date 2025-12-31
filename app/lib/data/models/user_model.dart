// lib/data/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String doctorPhno;
  final String role; // 'primary' or 'family'
  final String license;
  final String? deliveryDate;
  final String age;
  final String dateOfBirth;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.doctorPhno,
    required this.role,
    required this.license,
    this.deliveryDate,
    this.age = "",
    this.dateOfBirth = "",
  });

  factory UserModel.fromMap(dynamic raw) {
    if (raw is List && raw.isNotEmpty && raw.first is Map) raw = raw.first;
    if (raw is! Map) {
      return UserModel(
        uid: '',
        name: '',
        email: '',
        phoneNumber: '',
        doctorPhno: '',
        role: 'primary',
        license: '',
      );
    }

    final map = Map<String, dynamic>.from(raw);

    // try several key variants to handle different DB field names
    String phone() => (map['phoneNumber'] ?? map['phone_number'] ?? '').toString();
    String dob() => (map['dateOfBirth'] ?? map['date_of_birth'] ?? '').toString();
    dynamic del = map['deliveryDate'] ?? map['delivery_date'] ?? map['delivery'];

    if (del is List && del.isNotEmpty) del = del.first.toString();

    return UserModel(
      uid: map['uid']?.toString() ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phoneNumber: phone(),
      doctorPhno: (map['doctorPhno'] ?? map['doctor_phno'] ?? '').toString(),
      role: map['role']?.toString() ?? 'primary',
      license: map['license']?.toString() ?? '',
      deliveryDate: del?.toString(),
      age: map['age']?.toString() ?? '',
      dateOfBirth: dob(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'doctorPhno': doctorPhno,
      'role': role,
      'license': license,
      'deliveryDate': deliveryDate,
      'age': age,
      'dateOfBirth': dateOfBirth,
    };
  }
}
