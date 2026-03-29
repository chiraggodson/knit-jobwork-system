class UserModel {
  final String name;
  final String role; // 'admin' or 'user'

  UserModel({
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}
