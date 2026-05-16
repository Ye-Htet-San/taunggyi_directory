import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/categories/applications/services/categories_service.dart';
// import 'package:tgi_directory/features/home/presentation/widgets/place_section.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

class CategoryDetailPage extends ConsumerStatefulWidget {
  final int categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  Map<String, dynamic>? category;
  List<Place> places = [];
  bool loading = true;

  final List<String> subcategories = [
    'All',
    'Luxury',
    'Budget',
    'Family',
    'Popular',
  ];
  String selectedSubcategory = 'All';

  @override
  void initState() {
    super.initState();
    loadCategoryAndPlaces();
  }

  Future<void> loadCategoryAndPlaces() async {
    try {
      final categories = await CategoriesService.getCategories();
      category = categories.firstWhere((c) => c['id'] == widget.categoryId);

      final allPlaces = await PlaceService.getPlaces();
      places =
          allPlaces.where((p) => p.categoryId == widget.categoryId).toList();
      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Filter by selected category & subcategory
    final filteredPlaces =
        places.where((place) {
          if (selectedSubcategory == 'All') return true;
          return place.subcategoryName?.toLowerCase() ==
              selectedSubcategory.toLowerCase();
        }).toList();

    final reviews = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(category?['name'] ?? 'Category')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              category?['description'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // 🔹 Subcategory chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                final isSelected = sub == selectedSubcategory;
                return ChoiceChip(
                  label: Text(
                    sub,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  onSelected: (_) {
                    setState(() => selectedSubcategory = sub);
                  },
                );
              },
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemCount: subcategories.length,
            ),
          ),
          const SizedBox(height: 8),

          // 🔹 Grid of Places
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: filteredPlaces.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //  2 items per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, //  Adjust height
                ),
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  final reviewCount= reviews
                          .where((r) => r.placeId == place.id.toString())
                          .length;

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
                                isDark ? Colors.black45 : Colors.grey.shade200,
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
                                                child:
                                                    CircularProgressIndicator(),
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
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 6),

                            // Title
                            Text(
                              place.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
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
          ),
        ],
      ),
    );
  }
}
