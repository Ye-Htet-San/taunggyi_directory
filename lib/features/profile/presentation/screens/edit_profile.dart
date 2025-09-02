// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
import 'package:tgi_directory/features/profile/data/models/user_profile.dart';
import 'package:tgi_directory/features/profile/presentation/widgets/editable_card.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();

  File? _profileImage; // store picked image
  final ImagePicker _picker = ImagePicker();

  final List<String> bioOptions = [
    "Traveler",
    "Foodie",
    "Local Explorer",
    "Adventure Seeker",
    "Nature Lover",
    "Culture Enthusiast",
    "Nightlife Explorer",
    "Photographer",
    "Hiker",
  ];
  List<String> selectedBios = [];

  String? selectedTown;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    if (profile != null) {
      nameController.text = profile.userName;
      taglineController.text = profile.tagline;
      selectedBios = profile.userBio;
      selectedTown = profile.homeTown;

      if (profile.avatarPath.startsWith('/')) {
        _profileImage = File(profile.avatarPath);
      }
    }
  }

  Future<void> _pickImage() async {
    // Show bottom sheet to choose Camera or Gallery
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      setState(() => _profileImage = File(pickedFile.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (pickedFile != null) {
                      setState(() => _profileImage = File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    taglineController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: () async {
              if (profile == null) return;

              final updatedProfile = UserProfile(
                userId: profile.userId,
                userName:
                    nameController.text.trim().isEmpty
                        ? profile.userName
                        : nameController.text.trim(),
                userEmail: profile.userEmail,
                userBio: selectedBios,

                tagline:
                    taglineController.text.trim().isNotEmpty
                        ? taglineController.text.trim()
                        : profile.tagline,
                homeTown: selectedTown ?? profile.homeTown,
                avatarPath: _profileImage?.path ?? profile.avatarPath,
              );
              await ref
                  .read(profileProvider.notifier)
                  .updateProfile(updatedProfile);

              if (mounted) context.pop();
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Profile Image Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                
                                :(profile?.avatarPath.startsWith('/') ?? false
                                    ? FileImage(File(profile!.avatarPath))
                                    : AssetImage(profile!.avatarPath)
                                        as ImageProvider)
                                
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            radius: 20,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap camera to change your profile image",
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Username ---
            EditableCard(
              icon: Icons.person,
              iconColor: Colors.blue,
              title: 'Username',
              child: TextField(
                controller: nameController,
                style: textTheme.bodyMedium,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 8),

            // --- Bio Selection ---
            EditableCard(
              icon: Icons.interests,
              iconColor: Colors.green,
              title: 'Choose Your Interests (Max 3)',
              subtitle: selectedBios.isEmpty ? " " : selectedBios.join(","),
              onTap: () async {
                final updatedBios = await context.push<List<String>>(
                  '/profile/edit/select-bio',
                  extra: {
                    'bioOptions': bioOptions,
                    'selectedBios': selectedBios,
                  },
                );
                if (updatedBios != null) {
                  setState(() => selectedBios = updatedBios);
                }
              },
            ),

            const SizedBox(height: 8),

            // --- Tagline ---
            EditableCard(
              icon: Icons.short_text,
              iconColor: Colors.purple,
              title: "Short Tagline",
              subtitle:
                  taglineController.text.isEmpty
                      ? "Tap to add tagline"
                      : taglineController.text,
              onTap: () async {
                final newTagline = await context.push<String>(
                  '/profile/edit/short-tagline',
                  extra: taglineController.text,
                );
                if (newTagline != null && newTagline.isNotEmpty) {
                  setState(() {
                    taglineController.text = newTagline;
                  });
                }
              },
            ),
            const SizedBox(height: 8),

            // --- Hometown ---
            EditableCard(
              icon: Icons.location_on,
              iconColor: Colors.red,
              title: "Location",
              subtitle: selectedTown ?? "Select your location",
              onTap: () async {
                final newLocation = await context.push<String>(
                  '/profile/edit/select-location',
                  extra: selectedTown,
                );
                if (newLocation != null && newLocation.isNotEmpty) {
                  setState(() {
                    selectedTown = newLocation;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
