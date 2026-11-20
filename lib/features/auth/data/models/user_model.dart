import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.documentNumber,
    super.phone,
    super.token,
    super.role = UserRole.client,
    super.transactionalPin = '1234',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String?;
    final role = roleStr == 'admin' ? UserRole.admin : UserRole.client;
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      documentNumber: json['documentNumber'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
      role: role,
      transactionalPin: json['transactionalPin'] as String? ?? '1234',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'documentNumber': documentNumber,
      'phone': phone,
      'token': token,
      'role': role == UserRole.admin ? 'admin' : 'client',
      'transactionalPin': transactionalPin,
    };
  }
}
