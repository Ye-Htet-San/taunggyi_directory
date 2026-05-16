class Place {
  final int id;
  final String title;
  final List<String> images;
  final double rating;
  final String description;
  final int categoryId;
  final int subcategoryId;
  final String? subcategoryName; //nullable
  // final List<String> comments;
  final bool isFamous;
  final bool isPopular;
  //
  final String address;
  final List<String> phone;
  final String? email;
  final String website;
  final List<String> openingHours;
  final List<String>? paymentMethods;
  final double latitude;
  final double longitude;
  final int reviewCount;

  Place({
    required this.id,
    required this.title,
    required this.images,
    required this.rating,
    required this.description,
    required this.categoryId,
    required this.subcategoryId,
    this.subcategoryName,
    // required this.comments,
    this.isFamous = false,
    this.isPopular = false,
    required this.address,

    required this.phone,
    required this.email,
    required this.website,
    required this.openingHours,
    required this.paymentMethods,
    required this.latitude,
    required this.longitude,
    this.reviewCount =0,
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
        subcategoryId: j['subcategory_id'] ?? 0,
        subcategoryName: j['subcategoryName'],
        isFamous: j['is_famous'] ?? false,
        isPopular: j['is_popular'] ?? false,
        address: j['address'] ?? '',
        phone:
            (j['phone'] as List<dynamic>?)
                ?.map((p) => p.toString().replaceAll(RegExp(r'[\[\]]'), ''))
                .toList() ??
            [],
        email: j['email'] ?? '',
        website: j['website'] ?? '',
        openingHours:
            (j['opening_hours'] as List?)?.map((e) {
              final day = e['day'] ?? '';
              final open = e['open'] ?? '';
              final close = e['close'] ?? '';
              final closed = e['closed'] ?? false;

              if (closed) return "$day: Closed";
              if (open.isEmpty && close.isEmpty) return "$day: Open all day";
              return "$day: $open - $close";
            }).toList() ??
            [], //convert dict to string list
        paymentMethods:
            (j['payment_methods'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        latitude: (j['latitude'] ?? 0).toDouble(),
        longitude: (j['longitude'] ?? 0).toDouble(),
        reviewCount: j['review_count'] ?? 0,
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
