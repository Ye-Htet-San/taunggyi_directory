import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/home/presentation/widgets/section_title.dart';
import 'package:tgi_directory/features/places/application/providers/places_provider.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';

class PlaceSection extends ConsumerWidget {
  final String title;
  final String subtitle;

  const PlaceSection({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);
    final placesNotifier = ref.read(placesProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => placesNotifier.refresh(),
      child: placesAsync.when(
        loading: () {
          // show cached data if available
          final cached = placesNotifier.cached;
          if (cached.isNotEmpty) {
            final places = _filterPlaces(cached);
            return _buildPlaceList(context, places);
          }
          // else show loader
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, _) {
          final cached = placesNotifier.cached;
          if (cached.isNotEmpty) {
            final places = _filterPlaces(cached);
            return _buildPlaceList(context, places);
          }
          return Center(child: Text('Failed to load places'));
        },
        data: (allPlaces) {
          final places = _filterPlaces(allPlaces);
          return _buildPlaceList(context, places);
        },
      ),
    );
  }

  List _filterPlaces(List places) {
    return title == 'Famous Places'
        ? places.where((p) => p.isFamous).toList()
        : places.where((p) => p.isPopular).toList();
  }

  Widget _buildPlaceList(BuildContext context, List places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & See All
        Row(
          children: [
            SectionTitle(title: title),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.push('/place-grid?title=$title', extra: places);
              },
              child: Text(
                'See All',
                style: TextStyle(fontSize: 14, color: Colors.blue[800]),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(subtitle, style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    context.push('/place-detail', extra: place);
                  },
                  child: Container(
                    width: 200,
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                                place.images.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl:
                                          '${PlaceService.baseUrl}/${place.images[0]}',
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.red,
                                            ),
                                          ),
                                    )
                                    : Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place.title,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            place.subcategory ?? '',
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
