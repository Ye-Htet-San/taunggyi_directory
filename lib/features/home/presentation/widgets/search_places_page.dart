// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/categories/applications/services/categories_service.dart';
// import 'package:tgi_directory/features/home/presentation/widgets/place_section.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';

class SearchPlacesPage extends StatefulWidget {
  // final List<Place> allPlaces; // pass all your places to this page

  const SearchPlacesPage({super.key});

  @override
  State<SearchPlacesPage> createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> {
  List<Place> allPlaces = [];
  List<Place> filteredPlaces = [];

  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedSubcategory = 'All';

  List<String> categories = ['All'];
  List<String> subcategories = ['All'];

  Map<int, String> categoryMap = {}; // categoryId -> categoryName

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

      // subcategories
      subcategories.addAll(allPlaces.map((p) => p.subcategory?? '').toSet());
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
      places =
          places.where((p) => p.subcategory == selectedSubcategory).toList();
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
      body: isLoading ? const Center(child: CircularProgressIndicator(),):
          filteredPlaces.isEmpty
              ? const Center(child: Text('No places found'))
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading:
                        place.images.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                place.images[0],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(place.title),
                    subtitle: Text('${place.subcategory} • ${place.rating} ⭐'),
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
