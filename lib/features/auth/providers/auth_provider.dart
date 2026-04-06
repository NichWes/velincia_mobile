import 'package:flutter/material.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();

  bool isLoading = false;
  UserModel? user;

  bool get isLoggedIn => user != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.login(
        email: email,
        password: password,
      );

      final token = result['token'] as String;
      final loggedInUser = result['user'] as UserModel;

      await _storageService.saveToken(token);
      user = loggedInUser;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String? companyName,
    String? address,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        companyName: companyName,
        address: address,
      );

      final token = result['token'] as String;
      final registeredUser = result['user'] as UserModel;

      await _storageService.saveToken(token);
      user = registeredUser;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _storageService.getToken();
      if (token == null) {
        user = null;
        return;
      }

      user = await _authService.getCurrentUser();
    } catch (_) {
      await _storageService.deleteToken();
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.logout();
    } catch (_) {
      // abaikan kalau token invalid
    } finally {
      await _storageService.deleteToken();
      user = null;
      isLoading = false;
      notifyListeners();
    }
  }
}
