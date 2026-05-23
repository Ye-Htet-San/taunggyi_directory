import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/auth/data/models/user_model.dart';

class AuthService {
  // Same Wi-Fi:
  // final String baseUrl = "http://10.10.8.119:8000/auth";

  // Wifi from Android
  // final String baseUrl = "http://192.168.245.158:8000/auth";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> signup(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.authUrl}/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      print("Signup response: ${response.statusCode} - ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.authUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Login response body: $data");
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(
          key: "refresh_token",
          value: data["refresh_token"],
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data["user_id"].toString());
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // store userId on login
  }

  Future<String?> getToken() async {
    final accesstoken = await _storage.read(key: "access_token");
    final refreshToken = await _storage.read(key: "refresh_token");

    print("Token from storage: $accesstoken");
    if (accesstoken == null || refreshToken == null) return null;

    // If expired, refresh
    final isExpired = JwtDecoder.isExpired(accesstoken); //
    if (isExpired) {
      final newToken = await _refreshAccessToken(refreshToken);
      return newToken;
    }

    return accesstoken;
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.authUrl}/refresh"),
        headers: {"Authorization": "Bearer $refreshToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: "access_token", value: data["access_token"]);
        await _storage.write(
          key: "refresh_token",
          value: data["refresh_token"],
        );
        return data["access_token"];
      } else {
        print("Failed to refresh token: ${response.body}");
      }
    } catch (e) {
      print("Refresh token error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAccountInfo() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.authUrl}/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print("Account Info: $body");
        return body;
      } else {
         print("❌ /auth/me failed: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Account info error: $e");
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final token = await _storage.read(key: "token");
    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.authUrl}/change-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "access_token"); //removing the saved JWT token
    await _storage.delete(key: "refresh_token");
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
