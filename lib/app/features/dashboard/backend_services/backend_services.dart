library backend_service;

import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/RolesDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CustomerDTO.dart';

import '../models/users.dart';
import '../models/roles.dart';
import '../models/permissions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ApiEndpoints.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfo.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/FilterRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UpdateUserDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarProblemReportRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarRepairLogResponseDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarRepairLogRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusCountDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryItemDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryChangeRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryTransactionResponseDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryTransactionRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/InventoryTransactionType.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusUserRequestDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:get_storage/get_storage.dart';
import 'backend_utils.dart';

part 'TaskStatusApi.dart';
part 'RoleApi.dart';
part 'UsersApi.dart';
part 'CarProblemReportApi.dart';
part 'CarRepairLogApi.dart';
part 'CustomerApi.dart';
part 'InventoryApi.dart';
part 'InventoryTransactionApi.dart';

class backend_services {
  Future<ApiResponse<List<UserProfileDTO>>> fetchAllProfile() async {
    final String backendUrl = ApiEndpoints.getAllProfile;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<UserProfileDTO> logs = decodedList
            .map((jsonItem) => UserProfileDTO.fromJson(jsonItem))
            .toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<ApiResponse<List<permissions>>> fetchAllPermissions() async {
    final String backendUrl = ApiEndpoints.getAllPermissions;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<permissions> logs = decodedList
            .map((jsonItem) => permissions.fromJson(jsonItem))
            .toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<ApiResponse<List<roles>>> fetchAllRoles() async {
    final String backendUrl = ApiEndpoints.getAllRoles;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> decodedList = jsonDecode(response.body);

        final List<roles> logs = decodedList
            .map((jsonItem) => roles.fromJson(jsonItem))
            .toList();

        return ApiResponse(status: 'success', data: logs);
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Unexpected status code: ${response.statusCode}\nBody: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<int> countAllMembers({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.countAllMembers;

    try {
      final response = await http.get(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
      );

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

  Future<ApiResponse<CarInfoDTO>> getCarInfoByLicensePlate(String licensePlate) async {
    final uri = Uri.parse('${ApiEndpoints.getCarInfo}/$licensePlate');

    try {
      final response = await http.get(
        uri,
        headers: BackendUtils.buildHeader(),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<CarInfoDTO>(
          status: jsonData['status'] ?? 'success',
          data: CarInfoDTO.fromJson(jsonData),
          message: jsonData['idOrMessage'] ?? '',
        );
      } else {
        return ApiResponse(
          status: jsonData['status'] ?? 'error',
          message: jsonData['idOrMessage'] ?? 'Bilinmeyen hata',
        );
      }
    } catch (e) {
      return ApiResponse(status: "error", message: "Sunucuya erişilemedi: $e");
    }
  }

  Future<ApiResponse<void>> updateCarInfoByLicensePlate(String licensePlate, CarInfo updatedCar) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.updateCarInfo}/$licensePlate'),
      headers: BackendUtils.buildHeader(),
      body: jsonEncode(updatedCar.toJson()),
    );

    try {
      final jsonData = jsonDecode(response.body);

      return ApiResponse<void>(
        status: jsonData['status'] ?? (response.statusCode == 200 ? 'success' : 'error'),
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
        headers: BackendUtils.buildHeader(),
        body: jsonEncode(carInfo.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<ApiResponse> insertTaskStatus(TaskStatusDTO taskStatus) async {
    final String url = ApiEndpoints.insertTaskStatus;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: BackendUtils.buildHeader(),
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
          return ApiResponse(status: 'error', message: '${response.body}');
        }
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }

  Future<ApiResponse<String>> registerUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String roleId,
    required String roleName,
    required String permissionId,
    required String permissionName,
  }) async {
    final String backendUrl = ApiEndpoints.registerUser;

    final body = jsonEncode({
      "username": username,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "roleId": roleId,
      "roleName": roleName,
      "permissionId": permissionId,
      "permissionName": permissionName,
    });

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: BackendUtils.buildHeader(),
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse(status: 'success', message: response.body);
      } else {
        return ApiResponse(status: 'error', message: response.body);
      }
    } catch (e) {
      return ApiResponse(status: 'error', message: 'Exception occurred: $e');
    }
  }
}
