import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String loginInput, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/login', {
        'login': loginInput.trim(),
        'username': loginInput.trim(),
        'email': loginInput.trim(),
        'password': password,
      });

      final Map<String, dynamic> resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        // Ambil token dari root 'token' atau 'data.token' dengan aman
        final String token =
            (resData['token'] ?? resData['data']?['token'])?.toString() ?? '';

        // Ambil data user dari root 'user' atau 'data.user'
        // KODE LAMA (ERROR)
// KODE BARU (FIX)
        final rawUser = resData['user'] ?? resData['data']?['user'];
        final userData = UserModel.fromJson(
          rawUser is Map<String, dynamic>
              ? rawUser
              : (rawUser is Map
                  ? Map<String, dynamic>.from(rawUser)
                  : <String, dynamic>{}),
        );

        // Proteksi Strict Role Kasir
        if (userData.role != 'kasir') {
          _errorMessage = 'Akses ditolak. Aplikasi POS ini khusus Kasir.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _user = userData;
        final prefs = await SharedPreferences.getInstance();

        // Mencegah error 'Null' is not a subtype of 'String'
        await prefs.setString('token', token);
        await prefs.setString('auth_token', token);
        await prefs.setString(
            'user_role', userData.role.isNotEmpty ? userData.role : 'kasir');
        await prefs.setString(
            'user_nama', userData.nama.isNotEmpty ? userData.nama : 'Kasir');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            (resData['message'] ?? 'Login gagal. Periksa kembali akun Anda.')
                .toString();
      }
    } catch (e) {
      _errorMessage = 'Gagal memproses data login: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }
}
