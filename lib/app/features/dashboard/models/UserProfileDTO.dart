import 'roles.dart';
import 'permissions.dart';

class UserProfile {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final roles role;
  final permissions permission;

  UserProfile({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permission,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: roles.fromJson(json['role'] ?? {}),
      permission: permissions.fromJson(json['permission'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toJson(),
      'permission': permission.toJson(),
    };
  }
  @override
  String toString() {
    return 'UserProfile(userId: $userId,'
        'username: $username, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'role: ${role.toString()}, '
        'permission: ${permission.toString()})';
  }

}
