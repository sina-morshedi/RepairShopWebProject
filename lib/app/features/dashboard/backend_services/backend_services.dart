part of dashboard;

class backend_services {
  Future<List<_users>> fetchAllProfile({BuildContext? context}) async {
    final String backendUrl = ApiEndpoints.getAllProfile;

    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.map((e) => _users.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          return [_users.fromJson(data)];
        } else {
          return [];
        }
      } else {
        final data = jsonDecode(response.body);
        String error = data['error'] ?? 'Fetch failed';
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}