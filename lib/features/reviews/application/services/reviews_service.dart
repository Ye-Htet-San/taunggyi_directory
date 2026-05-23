import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/reviews/data/models/review.dart';

class ReviewService {
  // static const baseUrl = "http://192.168.245.158:8000";

  // Fetch current user's review for a place
  static Future<Review?> getMyReview(int placeId, String token) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.reviewsUrl}/my/$placeId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // backend doesn't include place_id in response, so pass it explicitly:
      return Review.fromJson(data, placeId: placeId.toString());
    } else if (response.statusCode == 404) {
      return null; // No review yet
    } else {
      throw Exception("Failed to fetch my review");
    }
  }

  // Adding review to place
  static Future<void> addReview({
    required int placeId,
    required double rating,
    required String comment,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.reviewsUrl}/$placeId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (res.statusCode != 201) {
      throw Exception("Failed to add review");
    }
  }

  static Future<List<Review>> getReviews(int placeId) async {
    final res = await http.get(Uri.parse('${ApiConfig.reviewsUrl}/places/$placeId'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      // Provide placeId fallback because backend list responses do not include place_id
      return data
          .map(
            (json) => Review.fromJson(
              json as Map<String, dynamic>,
              placeId: placeId.toString(),
            ),
          )
          .toList();
    }
    throw Exception("Failed to load reviews: ${res.body}");
  }

  // Update a review
  static Future<void> updateReview({
    required int reviewId,
    required double rating,
    required String comment,
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.reviewsUrl}/$reviewId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to update review: ${res.statusCode} ${res.body}");
    }
  }

  // Reaction to reviews
  static Future<void> reactReview({
    required int reviewId,
    required String reactionType,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.reviewsUrl}/$reviewId/reaction'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reaction_type': reactionType}),
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to react : ${res.statusCode} ${res.body}");
    }
  }

  // Delete review
  static Future<void> deleteReview({
    required int reviewId,
    required String token,
  }) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.reviewsUrl}/$reviewId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to delete review: ${res.statusCode} ${res.body}");
    }
  }
}
