class permissions {
  final String permissionId;
  final String permissionName;

  const permissions({
    required this.permissionId,
    required this.permissionName,
  });

  factory permissions.fromJson(Map<String, dynamic> json) {
    return permissions(
      permissionId: json['permissionId'] ?? '',
      permissionName: json['permissionName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permissionId': permissionId,
      'permissionName': permissionName,
    };
  }

  @override
  String toString() {
    return 'permissionId: $permissionId, permissionName: $permissionName';
  }
}
