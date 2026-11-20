enum UserRole { client, admin }

class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? documentNumber;
  final String? phone;
  final String? token;
  final UserRole role;
  final String transactionalPin;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.documentNumber,
    this.phone,
    this.token,
    this.role = UserRole.client,
    this.transactionalPin = '1234',
  });

  bool get isAdmin => role == UserRole.admin;
}
