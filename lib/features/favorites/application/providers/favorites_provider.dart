import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/config/base_notifier.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<int>>((
  ref,
) {
  return FavoritesNotifier(ref);
});

class FavoritesNotifier extends BaseNotifier<int> {
  final Ref ref;
  FavoritesNotifier(this.ref) : super('favorite_places');

  @override
  int fromStorage(String raw) => int.parse(raw);

  @override
  String toStorage(int item) => item.toString();

  bool isFavorite(int placeId) => state.contains(placeId);

  /// Load favorites from backend and merge with local
  Future<void> loadFromBackend(String token) async {
    try {
      final backendFavs = await PlaceService.fetchFavorites(token);
      final merged = {...backendFavs, ...state}.toList();
      state = merged;
      await saveToStorage();
    } catch (e) {
      // fallback: load from local storage if backend fail
      await loadFromStorage();
      
    }
  }

  /// Toggle favorite (offline-first)
  Future<void> toggleFavorite(int placeId, String token) async {
    await toggle(placeId); // update local state & storage
    try {
      await PlaceService.toggleFavorite(placeId, token);
      markSynced(placeId);
    } catch (e) {
      //IF backend fails, keep in pendingSync
    }
  }

  /// Sync all pending favorites with backend
  Future<void> syncFavorite(String token) async {
    for (var id in pendingSync) {
      try {
        await PlaceService.toggleFavorite(id, token);
        markSynced(id);
      } catch (e) {
        //leave in pendingSync
      }
    }
  }
}
