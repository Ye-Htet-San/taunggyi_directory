import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const key = 'favorite_place';

  static ValueNotifier<List<String>> favoriteIdsNotifier = ValueNotifier([]);

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(key) ?? [];
    favoriteIdsNotifier.value = favIds;
    return favIds;
  }

  static Future<void> toggleFavorite(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(key) ?? [];

    if (favorites.contains(placeId)) {
      favorites.remove(placeId);
    } else {
      favorites.add(placeId);
    }
    await prefs.setStringList(key, favorites);

    favoriteIdsNotifier.value = List.from(favorites);
  }

  static Future<bool> isFavorite(String placeId) async {
    return favoriteIdsNotifier.value.contains(placeId);
  }
}
