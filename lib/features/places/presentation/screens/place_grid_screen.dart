import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';

class PlaceGridScreen extends ConsumerWidget {
  final String title;
  final List<Place> places;

  const PlaceGridScreen({super.key, required this.title, required this.places});

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    final reviews= ref.watch(reviewsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),

        child: GridView.builder(
          itemCount: places.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //  2 items per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75, //  Adjust height
          ),
          itemBuilder: (context, index) {
            final place = places[index];
            final reviewCount= reviews.where(
                (r) => r.placeId == place.id.toString(),
              ).length;

            return GestureDetector(
              onTap: () {
                context.push('/place-detail', extra: place);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black45
                              : Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            place.images.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl:
                                      '${PlaceService.baseUrl}/${place.images[0]}',
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                        ),
                                      ),
                                )
                                : Container(
                                  height: 100,
                                  width: double.infinity,
                                  color: Colors.grey[300],

                                  child: const Icon(Icons.image_not_supported),
                                ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        place.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Subcategory
                      Text(
                        place.subcategoryName ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Rating
                      Row(
                        children: [
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            '($reviewCount) reviews',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Description
                      Text(
                        place.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
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
      ),
    );
  }
}
