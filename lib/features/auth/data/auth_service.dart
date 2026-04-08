import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

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

    debugPrint('LOGIN RESPONSE STATUS: ${response.statusCode}');
    debugPrint('LOGIN RESPONSE DATA: ${response.data}');

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
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
    String? companyName,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    if (phone != null && phone.isNotEmpty) payload['phone'] = phone;
    if (companyName != null && companyName.isNotEmpty) {
      payload['company_name'] = companyName;
    }
    if (address != null && address.isNotEmpty) payload['address'] = address;

    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: payload,
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
