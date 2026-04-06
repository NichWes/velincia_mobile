import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    final token = data['token'];
    final userJson = data['user'];

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    if (userJson == null) {
      throw Exception('Data user tidak ditemukan');
    }

    return {
      'token': token,
      'user': UserModel.fromJson(userJson),
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String? companyName,
    String? address,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'company_name': companyName,
        'address': address,
      },
    );

    final data = response.data;
    final token = data['token'];
    final userJson = data['user'];

    if (token == null) {
      throw Exception('Token tidak ditemukan setelah register');
    }

    if (userJson == null) {
      throw Exception('Data user tidak ditemukan setelah register');
    }

    return {
      'token': token,
      'user': UserModel.fromJson(userJson),
    };
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.dio.get(ApiEndpoints.me);
    final userJson = response.data['user'];

    if (userJson == null) {
      throw Exception('Data user tidak ditemukan');
    }

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await _apiClient.dio.post(ApiEndpoints.logout);
  }
}
