import 'package:shared_preferences/shared_preferences.dart';

class VisitedService {
  static const key = 'visited_places';

  ///Load visited place Ids
  static Future<List<String>> loadVisited() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(key) ?? [];
  }

  ///Mark a plae as visited
  static Future<void> markVisited(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final visited = prefs.getStringList(key) ?? [];

    if (!visited.contains(placeId)) {
      visited.add(placeId);
      await prefs.setStringList(key, visited);
    }
  }

  ///Get the count of visited places
  static Future<int> getVisitedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key)?.length ?? 0;
  }
}
