class UserModel {
  final int id;
  final String name;
  final String role;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.permissions,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []), // ✅ FIX
    );
  }
}