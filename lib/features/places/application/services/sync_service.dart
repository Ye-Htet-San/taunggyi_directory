import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class SyncService {
  static Future<void> syncAll(WidgetRef ref, String token) async {
    try {
      // Sync favorites
      await ref.read(favoritesProvider.notifier).syncFavorite(token);

      // Sync visited
      await ref.read(visitedProvider.notifier).syncVisited(token);
      print("Sync completed successfully.");
    } catch (e) {

      print("Sync failed: $e");
    }
  }
}
