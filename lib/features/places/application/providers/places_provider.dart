import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';

// Async notifier for Places
final placesProvider = AsyncNotifierProvider<PlacesNotifier, List<Place>>(() => PlacesNotifier());

class PlacesNotifier extends AsyncNotifier<List<Place>> {
  // cached list to show when offline
  List<Place> cached = [];

  @override
  Future<List<Place>> build() async {
    return await fetchPlaces();
  }

  Future<List<Place>> fetchPlaces() async {
    try {
      final places = await PlaceService.getPlaces();
      cached = places; // update cached list
      return places;
    } catch (e) {
      // return cached list if network fails
      if (cached.isNotEmpty) {
        return cached;
      }
      // else rethrow error
      throw e;
    }
  }

  // method to refresh data manually (pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final places = await fetchPlaces();
      state = AsyncValue.data(places);
    } catch (e,st) {
      state = AsyncValue.error(e,st);
    }
  }

  // computed getters for Famous and Popular
  List<Place> get famous => cached.where((p) => p.isFamous).toList();
  List<Place> get popular => cached.where((p) => p.isPopular).toList();
}
