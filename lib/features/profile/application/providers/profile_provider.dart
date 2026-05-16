// ignore_for_file: avoid_print

import 'dart:io';

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

  // Update profile (backend + local) / Optionally upload newAvatar first ,then send text update

  Future<bool> updateProfile(UserProfile profile, {File? newAvatar}) async {
    String? avatarPath = profile.avatarPath;

    // 1) Upload new avatar if provided
    if (newAvatar != null) {
      final uploadedPath = await service.uploadProfileImage(newAvatar);
      if (uploadedPath != null) {
        avatarPath = uploadedPath; // ✅ use backend path, not local
        
      } else {
        // upload failed - you can choose to abort or continue.
        // we'll continue (so only text updates happens) but print a message.
        print("Avatar uploaded fialed, proceeding with text update only.");
      }
    }

    // 2) Build new profile object with updated avatarOath
    final updatedProfile = profile.copyWith(avatarPath: avatarPath);
    // 3) Call backend to update text fields (and stored avatarPath)

    final success = await service.updateProfileBackend(updatedProfile);

    if (success) {
      // refresh from backend to get canonical representation

      final refreshedProfile = await service.fetchProfileFromBackend();
      if (refreshedProfile != null) {
        state = refreshedProfile; //Always show latest data from backend
      }
      return true;
    } else {
      return false;
    }
  }

  /// Clear profile on logout
  Future<void> clearProfile() async {
    state = null;
    await service.clearProfile();
  }
}
