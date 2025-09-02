import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/home/presentation/widgets/section_title.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final samplePlaces = [];
    final favoriteIds = ref.watch(favoritesProvider);
    final favoritePlaces =
        samplePlaces.where((place) => favoriteIds.contains(place.id)).toList();

    final Map<String, List<Place>> groupedFavorites = {};
    for (var place in favoritePlaces) {
      final category = place.categoryId;
      if (!groupedFavorites.containsKey(category)) {
        groupedFavorites[category] = [];
      }
      groupedFavorites[category]!.add(place);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body:
          favoritePlaces.isEmpty
              ? Center(child: Text('No Favorites yet ❤️'))
              : Padding(
                padding: const EdgeInsets.all(12.0),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        groupedFavorites.entries.map((e) {
                          final category = e.key;
                          final places = e.value;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Section title
                                SectionTitle(title: category),
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

                                    return GestureDetector(
                                      onTap: () async {
                                        await context.push(
                                          '/place-detail',
                                          extra: place,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child:
                                                    place.images.isNotEmpty
                                                        ? Image.asset(
                                                          place.images[0],
                                                          height: 100,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          cacheWidth: 512,
                                                        )
                                                        : Container(
                                                          height: 100,
                                                          width:
                                                              double.infinity,
                                                          color:
                                                              Colors.grey[300],
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
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              // Subcategory
                                              Text(
                                                place.subcategory ?? '',
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
                                                  const Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    place.rating.toString(),
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
              ),
    );
  }
}
