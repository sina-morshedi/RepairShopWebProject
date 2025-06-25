import 'package:flutter/material.dart';

import '../models/users.dart';
import '../models/roles.dart';
import '../models/permissions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfo.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';

class backend_services {
  Future<List<users>> fetchAllProfile({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllProfile;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => users.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [users.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<List<permissions>> fetchAllPermissions({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllPermissions;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => permissions.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [permissions.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<List<roles>> fetchAllRoles({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllRoles;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => roles.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [roles.fromJson(data)];
        } else {
          //TODO Return the appropriate error.
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        //TODO Return the appropriate error.
        return [];
      }
    } catch (e) {
      //TODO Return the appropriate error.
      return [];
    }
  }

  Future<int> countAllMembers({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.countAllMembers;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['count'] != null) {
          return data['count'] as int;
        } else {
          return -1;
        }
      } else {
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<ApiResponse<CarInfo>> getCarInfoByLicensePlate(String licensePlate) async {
    final uri = Uri.parse('${ApiEndpoints.getCarInfo}/$licensePlate');

    try {
      final response = await http.get(uri);

      final data = jsonDecode(response.body);
      final jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse<CarInfo>(
          status: jsonData['status'] ?? 'successful',
          data: CarInfo.fromJson(jsonData),
          message: jsonData['idOrMessage'] ?? '',
        );
      } else {
        return ApiResponse(
          status: data['status'] ?? 'error',
          message: data['idOrMessage'] ?? 'Bilinmeyen hata',
        );
      }
    } catch (e) {
      return ApiResponse(status: "error", message: "Sunucuya erişilemedi: $e");
    }
  }


  Future<ApiResponse<void>> updateCarInfoByLicensePlate(String licensePlate, CarInfo updatedCar) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.updateCarInfo}/$licensePlate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedCar.toJson()),
    );

    try {
      final jsonData = jsonDecode(response.body);

      return ApiResponse<void>(
        status: jsonData['status'] ?? (response.statusCode == 200 ? 'successful' : 'error'),
        message: jsonData['idOrMessage'] ?? '',
      );
    } catch (e) {
      return ApiResponse<void>(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }


  Future<ApiResponse> insertCarInfo(CarInfo carInfo) async {
    final String url = ApiEndpoints.registerCar;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(carInfo.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        // For non-200 status code, try to parse error message from body if any
        try {
          final data = jsonDecode(response.body);
          return ApiResponse(
            status: data['status'] ?? 'error',
            message: data['idOrMessage'] ?? 'Unknown error',
          );
        } catch (_) {
          return ApiResponse(
            status: 'error',
            message: 'Failed with status code ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  Future<ApiResponse> insertTaskStatus(TaskStatusDTO taskStatus) async {
    final String url = ApiEndpoints.insertTaskStatus;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskStatus.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        try {
          final data = jsonDecode(response.body);
          return ApiResponse(
            status: data['status'] ?? 'error',
            message: data['idOrMessage'] ?? 'Unknown error',
          );
        } catch (_) {
          return ApiResponse(
            status: 'error',
            message: 'Failed with status code ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }





  Future<String> registerUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String roleId,
    required String permissionId,
  }) async {
    final String backendUrl = ApiEndpoints.registerUser;

    final Map<String, dynamic> requestBody = {
      "username": username,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "roleId": roleId,
      "permissionId": permissionId,
    };

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );
      return response.body;

    } catch (e) {
      print("Error in registerUser: $e");
      return "Error in registerUser: $e";
    }
  }

}

class TaskStatusApi {
  // Get all task statuses
  Future<ApiResponse<List<TaskStatusDTO>>> getAllStatuses() async {
    final String url = ApiEndpoints.getAllTaskStatus;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<TaskStatusDTO> statuses =
        dataList.map((e) => TaskStatusDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: statuses,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Insert new task status
  Future<ApiResponse<TaskStatusDTO>> insertStatus(TaskStatusDTO status) async {
    final String url = "${ApiEndpoints.insertTaskStatus}/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(status.toJson()),
      );
      print("URL: $url");
      print("body: ${status.toJson()}");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: TaskStatusDTO.fromJson(data),
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Update existing task status by id
  Future<ApiResponse<TaskStatusDTO>> updateStatus(TaskStatusDTO status) async {
    if (status.id == null) {
      return ApiResponse(
        status: 'error',
        message: 'Missing ID for update',
      );
    }

    final String url = "${ApiEndpoints.updateTaskStatus}/${status.id}";
    print(url);
    print(status.toJson());
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(status.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          status: 'success',
          data: TaskStatusDTO.fromJson(data),
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }
  Future<ApiResponse<void>> deleteStatus(String id) async {
    final String url = "${ApiEndpoints.deleteTaskStatus}/$id"; // یا آدرس صحیح

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Error ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }
}
