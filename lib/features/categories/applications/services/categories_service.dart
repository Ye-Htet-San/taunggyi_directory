import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tgi_directory/config/api_config.dart';

class CategoriesService {
  // static const String baseUrl = "http://10.10.8.119:8000";
  // static const String baseUrl = "http://192.168.245.158:8000";

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final url = Uri.parse(ApiConfig.categoriesUrl);
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Failed to load categories: ${res.statusCode}");
    }
  }
}
