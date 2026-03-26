class UserSession {
final String role;
final List<String> permissions;

UserSession({
required this.role,
required this.permissions,
});

bool has(String permission) {
return permissions.contains("ALL") || permissions.contains(permission);
}
}
