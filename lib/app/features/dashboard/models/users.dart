part of dashboard;

class _users {
  final String username;
  final String firstName;
  final String lastName;
  final String roleName;
  final String permissionName;

  const _users({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.roleName,
    required this.permissionName,
  });

  factory _users.fromJson(Map<String, dynamic> json) {
    return _users(
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      roleName: json['roleName'] ?? '',
      permissionName: json['permissionName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'username: $username, firstName: $firstName, lastName: $lastName, roleName: $roleName, permissionName: $permissionName';
  }
}
