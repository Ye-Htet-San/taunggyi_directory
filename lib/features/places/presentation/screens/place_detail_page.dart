// ignore_for_file: collection_methods_unrelated_type

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/url_luncher.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/places/presentation/screens/info_row.dart';
import 'package:tgi_directory/features/reviews/presentation/reviews_section.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  @override
  void initState() {
    super.initState();

    // ✅ Mark visited when opened
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await AuthService().getToken(); // getting auth token
      if (token != null) {
        ref.read(visitedProvider.notifier).markVisited(widget.place.id, token);
      }
    });
  }

  void toggleFavorite() async {
    final token = await AuthService().getToken();
    if(token != null){
        ref.read(favoritesProvider.notifier).toggleFavorite(widget.place.id,token);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.place.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.place.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Carousel
            if (widget.place.images.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 220,
                  viewportFraction: 0.95,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
                items:
                    widget.place.images.map((imagePath) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:CachedNetworkImage(
                          imageUrl: '${PlaceService.baseUrl}/$imagePath',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,color: Colors.red,),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 16),

            //Details
            Padding(
              padding: EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Title
                  Text(
                    widget.place.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  //Subcategory
                  Text(
                    widget.place.subcategory ?? '',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),

                  //Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 4),
                      Text(widget.place.rating.toString()),
                      SizedBox(width: 4),
                      Text('(123)'),

                      Spacer(),

                      IconButton(
                        icon: Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          final url =
                              'https://www.google.com/maps/search/?api=1&query=${widget.place.latitude},${widget.place.longitude}';
                          launchExternalUrl(context, url);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  //Description
                  Text(
                    widget.place.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  Divider(height: 32),

                  //More info
                  InfoRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    values: [widget.place.address],
                  ),
                  if (widget.place.phone.isNotEmpty)
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      values: [widget.place.phone.join(',')],
                    ),
                  InfoRow(
                    icon: Icons.language,
                    label: 'Website',
                    values: [widget.place.website],
                    isLink: true,
                  ),
                  if (widget.place.openingHours.isNotEmpty)
                    InfoRow(
                      icon: Icons.schedule,
                      label: 'Opening Hours',
                      values: widget.place.openingHours,
                    ),

                  Divider(),

                  //Give rating
                  Text(
                    'Rate This Place',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  //Stars
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.star_border),
                        onPressed: () {
                          context.push('/review/${widget.place.id}');
                        },
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: () {
                      // Submit rating logic
                      context.push('/review/${widget.place.id}');
                    },
                    child: Text("Write A Review"),
                  ),
                  Divider(),
                  //Comments
                  ReviewsSection(placeId: widget.place.id),
                  const SizedBox(height: 8),
                  //Example comments
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
