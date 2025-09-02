import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/categories/applications/services/categories_service.dart';
import 'package:tgi_directory/features/categories/presentation/widgets/category_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> categories = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final data = await CategoriesService.getCategories();
      setState(() {
        categories = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2; // default for mobile
                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 4; // desktop
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3; // tablet
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            title: category['name'],
                            iconName: category['icon_url'], // use icon from backend
                            onTap: () {
                              context.push('/category/${category['id']}');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
