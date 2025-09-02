import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoriesService {
  static const String baseUrl = "http://192.168.43.149:8000";

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final url = Uri.parse("$baseUrl/categories/");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Failed to load categories: ${res.statusCode}");
    }
  }
}
