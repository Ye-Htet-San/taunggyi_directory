// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/profile/data/models/user_profile.dart';

class ProfileService {
  final AuthService authService = AuthService();

  static const String profileKey = "userProfile";

  final String baseUrl = "http://192.168.43.149:8000/auth";

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
      Uri.parse('$baseUrl/me'),
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

  /// Update profile on backend
  Future<bool> updateProfileBackend(UserProfile profile) async {
    final token = await authService.getToken();
    if (token == null) {
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/profile/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toMap()),
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
