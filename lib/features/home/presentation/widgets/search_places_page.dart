// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/categories/applications/services/categories_service.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';

class SearchPlacesPage extends ConsumerStatefulWidget {
  // final List<Place> allPlaces; // pass all your places to this page

  const SearchPlacesPage({super.key});

  @override
  ConsumerState<SearchPlacesPage> createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends ConsumerState<SearchPlacesPage> {
  List<Place> allPlaces = [];
  List<Place> filteredPlaces = [];

  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedSubcategory = 'All';

  List<String> categories = ['All'];
  List<String> subcategories = ['All'];

  Map<int, String> categoryMap = {}; // categoryId -> categoryName
  Map<int, String> subcategoryMap = {}; // subcategoryId -> subcategoryName

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // // categories = ['All'] +
    //     // widget.allPlaces.map((p) => p.categoryId).toSet().toList();
    // subcategories = ['All'] +
    //     widget.allPlaces.map((p) => p.subcategory).toSet().toList();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch categories
      final fetchCategories = await CategoriesService.getCategories();
      categoryMap = {
        for (var c in fetchCategories) c['id'] as int: c['name'] as String,
      };

      categories.addAll(categoryMap.values.toSet());

      // Fetch places
      final places = await PlaceService.getPlaces();

      allPlaces = places;

      // Build subcategory map from places
      subcategoryMap = {
        for (var p in allPlaces) p.subcategoryId: p.subcategoryName ?? '',
      };
      // subcategories
      subcategories.addAll(
        subcategoryMap.values.where((s) => s.isNotEmpty).toSet(),
      );
      // Filter places initially
      filterPlaces();
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPlaces() {
    List<Place> places = allPlaces;

    // Filter by category
    if (selectedCategory != 'All') {
      final selectedId =
          categoryMap.entries
              .firstWhere((e) => e.value == selectedCategory)
              .key;
      places = places.where((p) => p.categoryId == selectedId).toList();
    }
    // Filter by subcategory
    if (selectedSubcategory != 'All') {
      final selectedId =
          subcategoryMap.entries
              .firstWhere((e) => e.value == selectedSubcategory)
              .key;
      places = places.where((p) => p.subcategoryId == selectedId).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      places =
          places
              .where(
                (p) =>
                    p.title.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
    }

    // Sort by rating descending if no search query
    if (searchQuery.isEmpty) {
      places.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      filteredPlaces = places;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Places'),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      filterPlaces();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items:
                            categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSubcategory,
                        items:
                            subcategories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubcategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Subcategory',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredPlaces.isEmpty
              ? const Center(child: Text('No places found'))
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  
                  final reviewCount =
                      reviews
                          .where((r) => r.placeId == place.id.toString())
                          .length;
                  return ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading:
                        place.images.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${ApiConfig.baseIp}/${place.images[0]}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.red,
                                    ),
                              ),
                            )
                            : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(place.title),
                    subtitle: Text(
                      '${place.subcategoryName ?? ""} • ${place.rating.toStringAsFixed(1)} ⭐ ($reviewCount) reviews',
                    ),
                    onTap: () {
                      context.push('/place-detail', extra: place);
                    },
                  );
                },
                separatorBuilder:
                    (BuildContext context, int index) => Divider(),
              ),
    );
  }
}
