enum UserRole { client, admin }

class UserEntity {
  final String id;
  final String email;
  final String? name;
  final String? documentNumber;
  final String? phone;
  final String? token;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.documentNumber,
    this.phone,
    this.token,
    this.role = UserRole.client,
  });

  bool get isAdmin => role == UserRole.admin;
}
