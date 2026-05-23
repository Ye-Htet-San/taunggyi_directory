// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/profile/data/models/user_profile.dart';

class ProfileService {
  final AuthService authService = AuthService();

  static const String profileKey = "userProfile";

  // final String baseUrl = "http://10.10.8.119:8000/auth";
  // final String baseUrl = "http://192.168.245.158:8000/auth";

  // final String imageBase = "http://192.168.245.158:8000";

  //Save profile to SharedPreferences
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileKey, jsonEncode(profile.toMap()));
  }

  //Load profile from SharedPreferences
  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(profileKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return null; //No profile saved yet
    }

    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return UserProfile.fromMap(map);
    } catch (e) {
      print("Error loading profile: $e");
      return null;
    }
  }

  ///Clear profile (optional for logout or delete account)
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(profileKey);
  }

  /// Load profile from backend
  Future<UserProfile?> fetchProfileFromBackend() async {
    final token = await authService.getToken();
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.authUrl}/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final profile = UserProfile.fromMap(data);
      await saveProfile(profile); //save locally
      return profile;
    } else {
      print("Failed to fetch profile :${response.statusCode}");
      return null;
    }
  }

  /// Upload single profile image to backend
  /// Return the relative avatarPath (e.g "/uploads/users/abc.jpg")

  Future<String?> uploadProfileImage(File imageFile) async {
    final token = await authService.getToken();
    if (token == null) return null;

    final uri = Uri.parse('${ApiConfig.authUrl}/upload-image');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Field name must match backend : "file"
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      try {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final avatarPath = data['avatarPath'] as String?;
        return avatarPath;
      } catch (e) {
        print("Failed to decode upload response: $e");
        return null;
      }
    } else {
      print(
        "Image upload failed: ${streamedResponse.statusCode}- $responseBody",
      );
      return null;
    }
  }

  Future<bool> updateProfileBackend(UserProfile profile) async {
    final token = await authService.getToken();
    if (token == null) {
      return false;
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.authUrl}/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userName": profile.userName,
        "userBio": profile.userBio,
        "tagline": profile.tagline,
        "homeTown": profile.homeTown,
        "avatarPath": profile.avatarPath, // ✅ include this
      }),
    );
    if (response.statusCode == 200) {
      await saveProfile(profile); //update local cache too
      return true;
    } else {
      print("Failed to update profile:${response.body}");
      return false;
    }
  }
}

  /// Update profile on backend


