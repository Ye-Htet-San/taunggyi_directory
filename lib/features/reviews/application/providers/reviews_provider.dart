import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/config/base_notifier.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/reviews/data/models/review.dart';

final reviewsProvider = StateNotifierProvider<ReviewsNotifier, List<Review>>((
  ref,
) {
  return ReviewsNotifier(ref);
});

class ReviewsNotifier extends BaseNotifier<Review> {
  final Ref ref;
  ReviewsNotifier(this.ref) : super('user_reviews');

  @override
  Review fromStorage(String raw) {
    final map = jsonDecode(raw);
    return Review(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'],
      date: DateTime.parse(map['date']),
      likes: map['likes'],
      dislikes: map['dislikes'],
      isMyReview: map['isMyReview'],
    );
  }

  @override
  String toStorage(Review review) => jsonEncode({
    'id': review.id,
    'userId': review.userId,
    'userName': review.userName,
    'userAvatar': review.userAvatar,
    'rating': review.rating,
    'comment': review.comment,
    'date': review.date.toIso8601String(),
    'likes': review.likes,
    'dislikes': review.dislikes,
    'isMyReview': review.isMyReview,
  });

  /// Add review to backend and local
  Future<void> addReview(
    int placeId,
    double rating,
    String comment,
    String token,
  ) async {
    await PlaceService.addReview(placeId, rating, comment, token);
    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: "0", // assign from auth
      userName: "Me",
      userAvatar: "",
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      likes: 0,
      dislikes: 0,
      isMyReview: true,
    );
    state = [...state, review];
    await saveToStorage();
  }

  Future<void> loadFromBackend() async {
    // Optional: implement fetch reviews for current user
  }
}
