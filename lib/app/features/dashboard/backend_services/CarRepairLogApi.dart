part of 'backend_services.dart';

class CarRepairLogApi {
  // Fetch all logs: returns a list of ResponseDTO
  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getAllLogs() async {
    final String backendUrl = ApiEndpoints.carRepairLogGetAll;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Fetch logs by license plate (assuming the response is a list of ResponseDTO)
  Future<ApiResponse<List<CarRepairLogResponseDTO>>> getLogsByLicensePlate(String plate) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogGetByLicensePlate}/$plate';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<CarRepairLogResponseDTO> logs =
        dataList.map((e) => CarRepairLogResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: logs,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Create a new log: sends RequestDTO, receives ResponseDTO
  Future<ApiResponse<CarRepairLogResponseDTO>> createLog(CarRepairLogRequestDTO request) async {
    final String backendUrl = ApiEndpoints.carRepairLogCreate;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final createdLog = CarRepairLogResponseDTO.fromJson(data);
        return ApiResponse(
          status: 'success',
          data: createdLog,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Update a log: sends RequestDTO, receives ResponseDTO
  Future<ApiResponse<CarRepairLogResponseDTO>> updateLog(String id, CarRepairLogRequestDTO request) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogUpdate}/$id';

    try {
      final response = await http.put(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedLog = CarRepairLogResponseDTO.fromJson(data);

        return ApiResponse(
          status: 'success',
          data: updatedLog,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 'error',
        message: 'Exception occurred: $e',
      );
    }
  }

  // Delete a log by ID
  Future<ApiResponse<String>> deleteLog(String id) async {
    final String backendUrl = '${ApiEndpoints.carRepairLogDelete}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: response.body,
        );
      } else {
        return ApiResponse(
          status: 'error',
          message: response.body,
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
