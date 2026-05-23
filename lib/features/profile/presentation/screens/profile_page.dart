import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
// import 'package:tgi_directory/features/profile/application/services/profile_service.dart';
import 'package:tgi_directory/features/profile/presentation/widgets/stat_card.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch profile state
    final profile = ref.watch(profileProvider);

    // Watch favorites and visited
    final favoriteIds = ref.watch(favoritesProvider);
    final favoriteCount = favoriteIds.length;
    final visitedCount = ref.watch(visitedProvider).length;

    final myReviews =
        ref.watch(reviewsProvider).where((r) => r.isMyReview).toList();
    final myReviewCount = myReviews.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Profile Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profile != null
                            ? (profile.avatarPath.startsWith('/uploads/')
                                    ? NetworkImage(
                                      '${ApiConfig.baseIp}${profile.avatarPath}',
                                    )
                                    : AssetImage(profile.avatarPath))
                                as ImageProvider
                            : const AssetImage('assets/images/avatar.png'),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    profile?.userName ?? "Guest User",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Show bio & tagline together
                  const SizedBox(height: 4),
                  Text(
                    profile != null && profile.userBio.isNotEmpty
                        ? profile.userBio.join(" | ")
                        : "Traveler | Explorer",
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (profile?.tagline.isNotEmpty ?? false)
                    Text(
                      "\"${profile!.tagline}\"",
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 2),

                  Text(
                    "🏠 ${profile?.homeTown ?? "Unknown"}",
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () => context.push('/profile/edit'),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit Profile"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Stats Row ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.favorite,
                      title: "Favorites",
                      value: favoriteCount,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: StatCard(
                      icon: Icons.star,
                      title: "Reviews",
                      value: myReviewCount,
                      color: Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: StatCard(
                      icon: Icons.remove_red_eye,
                      title: "Visited",
                      value: visitedCount,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Quick Menu ---
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDark ? 2 : 4,
              child: Column(
                children: [
                  ListTile(
                    tileColor: cardColor,
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text("My Favorites", style: textTheme.bodyLarge),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/favorites'),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    tileColor: cardColor,
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text("My Reviews", style: textTheme.bodyLarge),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/profile/my-reviews');
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    tileColor: cardColor,
                    leading: const Icon(Icons.settings, color: Colors.blue),
                    title: Text("Settings", style: textTheme.bodyLarge),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/profile/settings');
                    },
                  ),
                  const Divider(height: 0),
                  // ListTile(
                  //   leading: const Icon(Icons.info, color: Colors.green),
                  //   title: const Text("About App"),
                  //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  //   onTap: () {
                  //     // TODO: Navigate to About Page
                  //   },
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
