import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tgi_directory/features/places/data/models/place.dart';

class PlaceService {
  static const baseUrl = "http://192.168.43.149:8000";

  // Get all places
  static Future<List<Place>> getPlaces() async {
    final response = await http.get(Uri.parse('$baseUrl/places/'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Place.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }

  // Get favorites of current user
  static Future<List<int>> fetchFavorites(String token) async {
    final result = await http.get(
      Uri.parse("$baseUrl/places/me/favorites"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (result.statusCode == 200) {
      return List<int>.from(jsonDecode(result.body));
    }

    throw Exception("Failed to load favorites");
  }

  // Toggle favorite
  static Future<void> toggleFavorite(int placeId, String token) async {
    final result = await http.post(
      Uri.parse('$baseUrl/places/$placeId/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // body: jsonEncode({'place_id': placeId}),
    );
    if (result.statusCode != 200) {
      throw Exception("Failed to toggle favorite");
    }
  }

  static Future<void> markVisited(int placeId, String token) async {
    final result = await http.post(
      Uri.parse('$baseUrl/places/$placeId/visited'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // body: jsonEncode({'place_id': placeId}), // if required by your API
    );
    if (result.statusCode != 200) {
      throw Exception("Failed to mark as visited");
    }
  }

  /// Get visited places
  static Future<List<int>> fetchVisited(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/places/me/visited"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return List<int>.from(jsonDecode(res.body));
    }
    throw Exception("Failed to load visited");
  }

  // Add review
  static Future<void> addReview(
    int placeId,
    double rating,
    String comment,
    String token,
  ) async {
    final result = await http.post(
      Uri.parse('$baseUrl/places/$placeId/reviews'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (result.statusCode != 200) {
      throw Exception("Failed to add review");
    }
  }
}
