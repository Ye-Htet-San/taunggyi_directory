import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/categories/presentation/widgets/category_card.dart';
import 'package:tgi_directory/features/home/presentation/widgets/section_title.dart';

class CategorySection extends StatelessWidget {
  final String title;

  const CategorySection({super.key, required this.title});

  // static const String baseUrl = "http://10.10.8.119:8000";

  // static const String baseUrl = "http://192.168.245.158:8000";

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url = Uri.parse("${ApiConfig.baseIp}/categories/");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Failed to load categories: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionTitle(title: title),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.go('/category');
              },
              child: Text('See All', style: TextStyle(color: Colors.blue[800])),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 150, // Enough to show 2 rows of rectangular cards
          child: FutureBuilder(
            future: fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories found'));
              }

              final categories = snapshot.data!;
              final mid = (categories.length / 2).ceil();
              final firstRow = categories.sublist(0, mid);
              final secondRow = categories.sublist(mid);

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: firstRow.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        CategoryCard(
                          title: firstRow[index]['name'] ?? 'No Name',
                          iconName: firstRow[index]['icon_url'] ?? '',
                          onTap: () {
                            context.push(
                              '/category/${firstRow[index]['id']}',
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        if (index < secondRow.length)
                          CategoryCard(
                            title: secondRow[index]['name']?? 'No Name',
                            iconName: secondRow[index]['icon_url'] ?? '',
                            onTap: () {
                              context.push(
                                '/category/${secondRow[index]['id']}',
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
