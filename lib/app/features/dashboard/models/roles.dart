
class roles {
  final String id;
  final String roleName;

  const roles({
    required this.id,
    required this.roleName,
  });

  factory roles.fromJson(Map<String, dynamic> json) {
    return roles(
      id: json['id'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleName': roleName,
    };
  }
  @override
  String toString() {
    return 'id: $id, roleName: $roleName';
  }
}
