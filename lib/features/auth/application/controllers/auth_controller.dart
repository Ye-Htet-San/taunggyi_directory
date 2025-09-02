import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgi_directory/config/theme_provider.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/auth/data/models/user_model.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/places/application/services/sync_service.dart';
import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService;
  final _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool isAuthChecked = false; //

  AuthController({required this.authService});

  /// Call this on app start (e.g., SplashScreen)
  Future<void> checkLoginStatus(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    final token = await authService.getToken();
    if (token == null) {
      _isLoggedIn = false;
    }

    // If logged in, load all offline & backend data
    if (_isLoggedIn && token != null) {
      final profileNotifier = ref.read(profileProvider.notifier);
      await profileNotifier.loadProfile(); //load profile
      final profile = ref.read(profileProvider);

      if (profile != null) {
        final userId = profile.userId;

        // Update storage keys for user-specific data
        ref
            .read(favoritesProvider.notifier)
            .updateStorageKey('favorite_places_$userId');
        ref
            .read(visitedProvider.notifier)
            .updateStorageKey('visited_places_$userId');
        ref
            .read(reviewsProvider.notifier)
            .updateStorageKey('user_reviews_$userId');

        // Load favorites & visited offline + backend

        await Future.wait([
          ref.read(favoritesProvider.notifier).loadFromBackend(token),
          ref.read(visitedProvider.notifier).loadFromBackend(token),
        ]);

        // Sync pending offline changes
        await SyncService.syncAll(ref, token);
      }
    }

    isAuthChecked = true; // Mark check complete
    notifyListeners();
  }

  /// Login with API
  Future<String?> login(String email, String password, WidgetRef ref) async {
    final success = await authService.login(email, password);
    if (!success) return null;

    _isLoggedIn = true;

    //Save login state offline
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // Fetch new profile from backend and update provider
    await ref.read(profileProvider.notifier).loadProfile();
    final profile = ref.read(profileProvider);

    if (profile == null) return null;

    final userId = profile.userId;

    // Update theme and storage keys
    await ref.read(themeProvider.notifier).loadThemeForUser(userId);

    // Update storage keys
    ref
        .read(favoritesProvider.notifier)
        .updateStorageKey('favorite_places_$userId');
    ref
        .read(visitedProvider.notifier)
        .updateStorageKey('visited_places_$userId');
    ref.read(reviewsProvider.notifier).updateStorageKey('user_reviews_$userId');

    // Sync

    final token = await authService.getToken();
    if (token != null) {
      await Future.wait([
        ref.read(favoritesProvider.notifier).loadFromBackend(token),
        ref.read(visitedProvider.notifier).loadFromBackend(token),
      ]);

      await SyncService.syncAll(ref, token);
    }

    notifyListeners();

    return userId;
  }

  /// Logout
  Future<void> logout(WidgetRef ref) async {
    await _storage.delete(key: 'token'); // Remove JWT token

    // Update local state
    _isLoggedIn = false;

    // Remove from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // Clear profile state and sharedPreferences
    await ref.read(profileProvider.notifier).clearProfile();

    await ref.read(favoritesProvider.notifier).clear();
    await ref.read(reviewsProvider.notifier).clear();
    await ref.read(visitedProvider.notifier).clear();

    notifyListeners();
  }

  /// Optional: Signup and automatically login
  Future<bool> signup(
    String username,
    String email,
    String password,
    WidgetRef ref,
  ) async {
    final success = await authService.signup(
      UserModel(username: username, email: email, password: password),
    );

    if (!success) return false;

    // Optionally login after signup
    final userId = await login(email, password, ref);
    return userId != null; // true if login succeeded, false if failed
  }
}
