class ApiEndpoints {
  static const String _baseUrl = "https://fastapi-java-backend-production.up.railway.app";

  static const String login = "$_baseUrl/users/login";
  static const String register = "$_baseUrl/register";
  static const String getProfile = "$_baseUrl/user/profile";
  static const String getAllProfile = "$_baseUrl/users/all";
  static const String countAllMembers = "$_baseUrl/users/count";

  static const String getAllRoles = "$_baseUrl/roles/all";
  static const String insertRole = "$_baseUrl/roles";
  static const String updateRole = "$_baseUrl/roles/updateRole";
  static const String deleteRole = "$_baseUrl/roles/deleteRole";

  static const String getAllPermissions = "$_baseUrl/permissions/all";
  static const String registerUser = "$_baseUrl/auth/register";
  static const String registerCar = "$_baseUrl/cars/insertCarInfo";
  static const String getCarInfo = "$_baseUrl/cars/getCarInfo";
  static const String updateCarInfo = "$_baseUrl/cars/updateCarInfo";
  static const String insertTaskStatus = "$_baseUrl/task_status";
  static const String getAllTaskStatus = "$_baseUrl/task_status/all";
  static const String updateTaskStatus = "$_baseUrl/task_status/updateTaskStatus";
  static const String deleteTaskStatus = "$_baseUrl/task_status/deleteTaskStatus";
}

class ApiResponse<T> {
  final String status;
  final T? data;
  final String? message;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(Object?)? fromJsonT]) {
    return ApiResponse<T>(
      status: json['status'] ?? 'error',
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['idOrMessage'] ?? '',
    );
  }
}



class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
