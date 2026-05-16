// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgi_directory/config/providers.dart';
// import 'package:tgi_directory/config/providers.dart';
import 'package:tgi_directory/config/theme_provider.dart';
// import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> clearLocalData(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // wipe everything

    // Reset providers
    ref.read(favoritesProvider.notifier).clear();
    ref.read(visitedProvider.notifier).clear();
    ref.read(themeProvider.notifier).clear();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All local data cleared')));
      context.go('/home');
    }
  }

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    ref.read(authControllerProvider.notifier).logout(ref);

    // Clear local data

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final cardColor = Theme.of(context).cardColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            // Account Section
            ListTile(
              title: Text(
                'Account Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.person),
              title: Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/profile/edit'),
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.account_circle),
              title: Text(
                'My Account',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'View or manage your account',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/profile/settings/account'),
            ),
            const Divider(),
        
            // App Preferences
            const ListTile(
              title: Text(
                'App Preferences',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SwitchListTile(
              tileColor: cardColor,
              secondary: const Icon(Icons.dark_mode),
              title: Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              value: isDarkMode,
              onChanged: (value) async {
                final profile = ref.read(profileProvider);
                final userId = profile?.userId ?? 'Guest';
                ref.read(themeProvider.notifier).toggleTheme(value, userId);
              },
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.language),
              title: Text(
                'Language',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'English',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {},
            ),
            const Divider(),
        
            // Privacy & Security
            const ListTile(
              title: Text(
                'Privacy & Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.delete_forever),
              title: Text(
                'Clear Local Data',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Clear Local Data?'),
                        content: const Text(
                          'This will remove all stored data and log you out. Proceed?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                );
                if (confirm == true) await clearLocalData(context, ref);
              },
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.logout),
              title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () => logout(context, ref),
            ),
            const Divider(),
        
            // About
            const ListTile(
              title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              tileColor: cardColor,
              leading: const Icon(Icons.info),
              title: Text(
                'About App',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'TGI Directory',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 Taunggyi Guide',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
