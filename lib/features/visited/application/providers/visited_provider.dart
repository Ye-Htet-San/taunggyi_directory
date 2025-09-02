import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/config/base_notifier.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';

final visitedProvider = StateNotifierProvider<VisitedNotifier, List<int>>((
  ref,
) {
  return VisitedNotifier(ref);
});

class VisitedNotifier extends BaseNotifier<int> {
  final Ref ref;
  VisitedNotifier(this.ref) : super('visited_places');

  @override
  int fromStorage(String raw) => int.parse(raw);

  @override
  String toStorage(int item) => item.toString();

  bool isVisited(int placeId) => state.contains(placeId);

  
  /// Load visited places from backend and merge
  Future<void> loadFromBackend(String token) async {
    try {
      final backendVisited = await PlaceService.fetchVisited(token);
      final merged = {...backendVisited, ...state}.toList();
      state = merged;
      await saveToStorage();
    } catch (e) {
      // fallback: load from local storage if backend fails
      await loadFromStorage();
    }
  }

  /// Mark a place as visited (only add if not already exists)
  Future<void> markVisited(int placeId, String token) async {
    await addIfNotExist(placeId); // no dupication

    // Optional: make backend call if you have an endpoint
    try {
    
      await PlaceService.markVisited(placeId, token);
      markSynced(placeId);

    } catch (e) {
      // If backend fails, maybe remove from state or keep it locally
      // keep in pendingSync
      print("Failed to sync visited place: $e");
    }
  }

  /// Sync all pending visited with  backend
  Future<void> syncVisited(String token) async {
    for (var id in pendingSync) {
      try {
        await PlaceService.markVisited(id, token);
        markSynced(id);
      } catch (e) {
        // leave in pendingSync
      }
    }
  }
}
