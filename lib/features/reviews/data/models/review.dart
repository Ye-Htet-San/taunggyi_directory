import 'package:tgi_directory/config/api_config.dart';

class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final int likes;
  final int dislikes;
  final bool isMyReview;

  // static const String _baseUrl = "http://192.168.42.158:8000";

  Review({
    required this.id,
    required this.placeId,
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

  factory Review.fromJson(
    Map<String, dynamic> json, {
    String? myUserId,
    String? placeId,
  }) {
    final parsedUserId = (json['user_id'] ?? json['userId'])?.toString() ?? '';
    final parsedPlaceId =
        (json['place_id'] ?? json['placeId']?.toString() ?? placeId ?? '');
    final rawAvatar = json['user_avatar'] ?? json['userAvatar'] ?? '';
    final avatar =
        (rawAvatar.startsWith('/uploads')) ? '${ApiConfig.baseIp}$rawAvatar' : rawAvatar;

     final createdAt = json['created_at'] ?? json['date'] ?? json['createdAt'];
    DateTime parsedDate;
    if (createdAt is String) {
      parsedDate = DateTime.parse(createdAt);
    } else if (createdAt is DateTime) {
      parsedDate = createdAt;
    } else {
      parsedDate = DateTime.now();
    }


    return Review(
      id: json['id'].toString(),
      placeId: parsedPlaceId,
      userId: parsedUserId,
      userName: json['user_name'] ?? json['userName'] ?? '',
      userAvatar: avatar,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      date: parsedDate,
      likes: (json['likes'] ?? 0) as int,
      dislikes: (json['dislikes'] ?? 0) as int,
      isMyReview: myUserId != null && myUserId == parsedUserId,
    );
  }

    Review copyWith({
    String? id,
    String? placeId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? date,
    int? likes,
    int? dislikes,
    bool? isMyReview,
  }) {
    return Review(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      isMyReview: isMyReview ?? this.isMyReview,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'placeId':placeId,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
    'likes': likes,
    'dislikes': dislikes,
    'isMyReview': isMyReview,
  };
}
