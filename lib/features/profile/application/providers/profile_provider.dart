import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/features/profile/application/services/profile_service.dart';
import 'package:tgi_directory/features/profile/data/models/user_profile.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>(
  (ref) => ProfileNotifier(),
);

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final ProfileService service = ProfileService();

  ProfileNotifier() : super(null) {
    loadProfile();
  }

  /// Load profile from backend first ,then fallback to local
  Future<void> loadProfile() async {
    UserProfile? profile = await service.fetchProfileFromBackend();

    // If backend fails , try loading from sharedPreferences
    profile ??= await service.loadProfile();
    // if still null,provide a defauld profile
    profile ??= UserProfile(
      userId: '0',
      userName: 'Explorer of Taunggyi',
      userEmail: 'user@gmail.com',
      userBio: ['Traveler | Foodie | Local Explorer'],
      tagline: 'Lover of mountains and tea!',
      homeTown: 'Downtown',
      avatarPath: 'assets/images/avatar.png',
    );

    state = profile;
  }

  // Update profile (backend + local)
  Future<bool> updateProfile(UserProfile profile) async {
    final success = await service.updateProfileBackend(profile);
    if (success) {
      final refreshedProfile = await service.fetchProfileFromBackend();
      if (refreshedProfile != null) {
        state = refreshedProfile;//Always show latest data from backend
      }
    }
    return success;
  }

  /// Clear profile on logout
  Future<void> clearProfile() async {
    state = null;
    await service.clearProfile();
  }
}
