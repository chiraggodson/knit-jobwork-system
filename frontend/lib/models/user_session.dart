class UserSession {
  final String role;
  final List<String> permissions;

  // 🔥 ACTIVE SESSION (GLOBAL)
  static UserSession? current;

  UserSession({
    required this.role,
    required this.permissions,
  });

  bool has(String permission) {
    return permissions.contains("ALL") || permissions.contains(permission);
  }

  // 🔥 CHECKS
  static bool get isLoggedIn => current != null;

  static bool hasPermission(String permission) {
    return current?.has(permission) ?? false;
  }

  static bool get isAdmin {
    return current?.role == "admin";
  }

  // 🔥 DEV MODE SESSION (AUTO ADMIN)
  static void initDevSession() {
    current = UserSession(
      role: "admin",
      permissions: ["ALL"], // full access
    );
  }

  // 🔥 CLEAR SESSION
  static void clear() {
    current = null;
  }
}