library backend_service;

import 'package:flutter/material.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/SettingStatusDTO.dart';
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
import 'package:repair_shop_web/app/features/dashboard/models/InventorySaleLogDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:get_storage/get_storage.dart';
import 'backend_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'TaskStatusApi.dart';
part 'RoleApi.dart';
part 'UsersApi.dart';
part 'CarProblemReportApi.dart';
part 'CarRepairLogApi.dart';
part 'CustomerApi.dart';
part 'InventoryApi.dart';
part 'InventoryTransactionApi.dart';
part 'SettingStatusApi.dart';
part 'CarInfoApi.dart';
part 'InventorySaleLogApi.dart';

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
