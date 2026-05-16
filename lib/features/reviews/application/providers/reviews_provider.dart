import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/config/base_notifier.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/reviews/application/services/reviews_service.dart';
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
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Review(
      id: map['id'].toString(),
      placeId: (map['placeId'] ?? '').toString(),
      userId: map['userId'].toString(),
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date']),
      likes: (map['likes'] ?? 0) as int,
      dislikes: (map['dislikes'] ?? 0) as int,
      isMyReview: map['isMyReview'] ?? false,
    );
  }

  @override
  String toStorage(Review review) => jsonEncode({
    'id': review.id,
    'placeId': review.placeId,
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
    await ReviewService.addReview(
      placeId: placeId,
      rating: rating,
      comment: comment,
      token: token,
    );

    final account = await AuthService().getAccountInfo();
    final myUserId = account?['userId']?.toString() ?? 'me';

    final newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      placeId: placeId.toString(),
      userId: myUserId, // assign from auth
      userName: account?["userName"] ?? 'Me',
      userAvatar: account?['avatarPath'] ?? '',
      rating: rating,
      comment: comment,
      date: DateTime.now(),
      likes: 0,
      dislikes: 0,
      isMyReview: true,
    );
    state = [newReview, ...state];
    await saveToStorage();
  }

  Future<void> loadFromBackend(int placeId) async {
    // Optional: implement fetch reviews for current user
    try {
      final token = await AuthService().getToken();
      final account =
          token != null ? await AuthService().getAccountInfo() : null;
      final myUserId = account?['userId']?.toString();

      final reviews = await ReviewService.getReviews(placeId);

      // ensure isMyReview flag is set based on myUserId
      final updatedReviews =
          reviews
              .map(
                (r) => Review(
                  id: r.id,
                  placeId: r.placeId,
                  userId: r.userId,
                  userName: r.userName,
                  userAvatar: r.userAvatar,
                  rating: r.rating,
                  comment: r.comment,
                  date: r.date,
                  likes: r.likes,
                  dislikes: r.dislikes,
                  isMyReview: myUserId != null && myUserId == r.userId,
                ),
              )
              .toList();
      final otherReviews =
          state.where((r) => r.placeId != placeId.toString()).toList();
      state = [...otherReviews, ...updatedReviews];
      await saveToStorage();
    } catch (e) {
      // fallback: use local storage
      await loadFromStorage();
    }
  }

  // Update review
  Future<void> updateReview({
    required int reviewId,
    required int placeId,
    required double rating,
    required String comment,
    required String token,
  }) async {
    await ReviewService.updateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
      token: token,
    );
    await loadFromBackend(placeId);
  }

  /// React to review
  Future<void> reactReview({
    required int reviewId,
    required String reactionType,
    required String token,
  }) async {
    await ReviewService.reactReview(
      reviewId: reviewId,
      reactionType: reactionType,
      token: token,
    );

    state =
        state.map((r) {
          if (r.id == reviewId.toString()) {
            if (reactionType == "like") {
              return r.copyWith(likes: r.likes + 1);
            } else {
              return r.copyWith(dislikes: r.dislikes + 1);
            }
          }
          return r;
        }).toList();

    await saveToStorage();
  }

  Future<void> refreshLocalFromBackend(int placeId) async {
    await loadFromBackend(placeId);
  }
}
