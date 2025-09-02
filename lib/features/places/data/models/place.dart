class Place {
  final int id;
  final String title;
  final List<String> images;
  final double rating;
  final String description;
  final int categoryId;
  final String? subcategory; //nullable
  // final List<String> comments;
  final bool isFamous;
  final bool isPopular;
  //
  final String address;
  final List<String> phone;
  final String website;
  final List<String> openingHours;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.title,
    required this.images,
    required this.rating,
    required this.description,
    required this.categoryId,
    this.subcategory,
    // required this.comments,
    this.isFamous = false,
    this.isPopular = false,
    required this.address,
    required this.phone,
    required this.website,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> j) {
    try {
      return Place(
        id: j['id'],
        title: j['title'] ?? '',
        images: List<String>.from(j['images'] ?? []),
        rating: (j['rating'] ?? 0).toDouble(),
        description: j['description'] ?? '',
        categoryId: j['category_id'] ?? 0,
        subcategory: j['subcategoryName'] ?? '',
        isFamous: j['is_famous'] ?? false,
        isPopular: j['is_popular'] ?? false,
        address: j['address'] ?? '',
        phone:
            (j['phone'] as List<dynamic>?)
                ?.map((p) => p.toString().replaceAll(RegExp(r'[\[\]]'), ''))
                .toList() ??
            [],
        website: j['website'] ?? '',
        openingHours:
            (j['opening_hours'] as List?)
                ?.map((e) => "${e['day']}: ${e['open']}-${e['close']}")
                .toList() ??
            [], //convert dict to string list
        latitude: (j['latitude'] ?? 0).toDouble(),
        longitude: (j['longitude'] ?? 0).toDouble(),
      );
    } catch (e, s) {
      print("Error parsing Place: $e\n$s");
      rethrow;
    }
  }
}

class Comment {
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.username,
    required this.content,
    required this.createdAt,
  });
}
