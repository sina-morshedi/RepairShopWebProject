part of 'backend_services.dart';

class InventoryTransactionApi {
  // گرفتن لیست کل تراکنش‌ها
  Future<ApiResponse<List<InventoryTransactionResponseDTO>>> getAllTransactions() async {
    final String backendUrl = ApiEndpoints.inventoryTransactionList;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryTransactionResponseDTO> transactions =
        dataList.map((e) => InventoryTransactionResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: transactions,
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

  Future<ApiResponse<List<InventoryTransactionResponseDTO>>> getTransactionsPaged({
    required int page,
    required int size,
  }) async {
    final String backendUrl = '${ApiEndpoints.inventoryTransactionPaged}?page=$page&size=$size';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryTransactionResponseDTO> transactions =
        dataList.map((e) => InventoryTransactionResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: transactions,
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

  Future<ApiResponse<List<InventoryTransactionResponseDTO>>> getTransactionsByDateRange({
    required String startDate, // فرمت: yyyy-MM-ddTHH:mm:ss
    required String endDate,
    required int page,
    required int size,
  }) async {
    final String backendUrl =
        '${ApiEndpoints.inventoryTransactionDateRange}?startDate=$startDate&endDate=$endDate&page=$page&size=$size';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryTransactionResponseDTO> transactions =
        dataList.map((e) => InventoryTransactionResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: transactions,
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


  // گرفتن تراکنش با شناسه
  Future<ApiResponse<InventoryTransactionResponseDTO>> getTransactionById(String id) async {
    final String backendUrl = '${ApiEndpoints.inventoryTransactionGetById}/$id';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final InventoryTransactionResponseDTO transaction =
        InventoryTransactionResponseDTO.fromJson(data);

        return ApiResponse(
          status: 'success',
          data: transaction,
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

  // افزودن تراکنش جدید
  Future<ApiResponse<InventoryTransactionResponseDTO>> addTransaction(InventoryTransactionRequestDTO dto) async {
    final String backendUrl = ApiEndpoints.inventoryTransactionAdd;

    print("dto");
    print(dto);
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dto.toJson()),
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

  // حذف تراکنش بر اساس ID
  Future<ApiResponse<String>> deleteTransaction(String id) async {
    final String backendUrl = '${ApiEndpoints.inventoryTransactionDelete}/$id';

    try {
      final response = await http.delete(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: 'success',
          message: 'İşlem başarıyla silindi.',
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

  // جستجوی تراکنش‌ها بر اساس نوع (type)
  Future<ApiResponse<List<InventoryTransactionResponseDTO>>> searchTransactionsByType(TransactionType type) async {
    final String typeStr = transactionTypeToString(type) ?? '';
    final String backendUrl = '${ApiEndpoints.inventoryTransactionSearchByType}?type=$typeStr';

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);
        final List<InventoryTransactionResponseDTO> transactions =
        dataList.map((e) => InventoryTransactionResponseDTO.fromJson(e)).toList();

        return ApiResponse(
          status: 'success',
          data: transactions,
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
