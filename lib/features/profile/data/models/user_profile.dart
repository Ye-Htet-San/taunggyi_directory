class UserProfile {
  final String userId; // Unique ID from backend
  final String userName;
  final String userEmail; // Keep consistent naming
  List<String> userBio;
  final String tagline;
  final String homeTown;
  final String avatarPath;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userBio,
    required this.tagline,
    required this.homeTown,
    required this.avatarPath,
  });

  // Convert to Map (for saving locally or sending to backend)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userBio': userBio,
      'tagline': tagline,
      'homeTown': homeTown,
      'avatarPath': avatarPath,
    };
  }

  // Create UserProfile from Map (from backend or local storage)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
     List<String> bioList;

  if (map['userBio'] is String) {
    // Split string by " | " if it comes as a single string
    bioList = (map['userBio'] as String).split(" | ");
  } else if (map['userBio'] is List) {
    // If it comes as a list, cast each element to String
    bioList = List<String>.from(map['userBio']);
  } else {
    bioList = [];
  }


    return UserProfile(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userBio: bioList,
      tagline: map['tagline'] ?? '',
      homeTown: map['homeTown'] ?? '',
      avatarPath: map['avatarPath'] ?? 'assets/images/avatar.png',
    );
  }

  // Copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    List<String>? userBio,
    String? tagline,
    String? homeTown,
    String? avatarPath,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userBio: userBio ?? this.userBio,
      tagline: tagline ?? this.tagline,
      homeTown: homeTown ?? this.homeTown,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
