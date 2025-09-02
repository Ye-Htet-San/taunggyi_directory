class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final int likes;
  final int dislikes;
  final bool isMyReview;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.likes = 0,
    this.dislikes = 0,
    this.isMyReview = false,
  });
}
