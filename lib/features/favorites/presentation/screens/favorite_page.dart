import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/categories/applications/services/categories_service.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
// import 'package:tgi_directory/features/home/presentation/widgets/place_section.dart';
import 'package:tgi_directory/features/home/presentation/widgets/section_title.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final favoriteIds = ref.watch(favoritesProvider);
    final reviews = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: FutureBuilder(
        future: Future.wait([
          PlaceService.getPlaces(),
          CategoriesService.getCategories(),
        ]),

        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allPlaces = snapshot.data![0] as List<Place>;
          final categories = snapshot.data![1] as List<dynamic>;

          // Build categoryId -> categoryName map
          final Map<int, String> categoryMap = {
            for (var c in categories) c['id'] as int: c['name'] as String,
          };

          final favoritePlaces =
              allPlaces.where((p) => favoriteIds.contains(p.id)).toList();

          if (favoritePlaces.isEmpty) {
            return const Center(child: Text('No Favorites yet ❤️ '));
          }

          // Group by category name instead of ID
          final Map<String, List<Place>> groupedFavorites = {};
          for (var place in favoritePlaces) {
            final categoryName = categoryMap[place.categoryId] ?? 'Unknown';
            groupedFavorites.putIfAbsent(categoryName, () => []);
            groupedFavorites[categoryName]!.add(place);
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    groupedFavorites.entries.map((entry) {
                      final categoryName = entry.key;
                      final places = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Section title
                            SectionTitle(title: categoryName),
                            SizedBox(height: 8),
                            //Grid of favorite places
                            GridView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable inner scroll
                              shrinkWrap: true,
                              itemCount: places.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 2 items per row
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, index) {
                                final place = places[index];
                                final reviewCount =
                                    reviews
                                        .where(
                                          (r) =>
                                              r.placeId == place.id.toString(),
                                        )
                                        .length;

                                return GestureDetector(
                                  onTap: () async {
                                    await context.push(
                                      '/place-detail',
                                      extra: place,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              isDark
                                                  ? Colors.black45
                                                  : Colors.grey.shade200,
                                          blurRadius: 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                place.images.isNotEmpty
                                                    ? CachedNetworkImage(
                                                      imageUrl:
                                                          '${ApiConfig.baseIp}/${place.images[0]}',
                                                      height: 100,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => Container(
                                                            height: 100,
                                                            color:
                                                                Colors
                                                                    .grey[300],
                                                            child: const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.red,
                                                            size: 60,
                                                          ),
                                                    )
                                                    : Container(
                                                      height: 100,
                                                      width: double.infinity,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(height: 6),

                                          // Title
                                          Text(
                                            place.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          // Subcategory
                                          Text(
                                            place.subcategoryName ?? '',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 4),

                                          // Rating
                                          Row(
                                            children: [
                                              Text(
                                                place.rating.toStringAsFixed(1),
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              Text(
                                                '($reviewCount) reviews',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 4),

                                          // Description
                                          Text(
                                            place.description,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color:
                                                  isDark
                                                      ? Colors.white70
                                                      : Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          );
        },

        // Group by category
      ),
    );
  }
}
