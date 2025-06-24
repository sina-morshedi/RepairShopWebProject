
class roles {
  final String roleId;
  final String roleName;

  const roles({
    required this.roleId,
    required this.roleName,
  });

  factory roles.fromJson(Map<String, dynamic> json) {
    return roles(
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
    };
  }
  @override
  String toString() {
    return 'id: $roleId, roleName: $roleName';
  }
}
