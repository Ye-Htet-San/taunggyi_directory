// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
// // import 'package:tgi_directory/features/profile/data/models/user_profile.dart';

// class UpdateEmailPage extends ConsumerStatefulWidget {
//   const UpdateEmailPage({super.key});

//   @override
//   ConsumerState<UpdateEmailPage> createState() => _UpdateEmailPageState();
// }

// class _UpdateEmailPageState extends ConsumerState<UpdateEmailPage> {
//   final TextEditingController emailController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final profile = ref.read(profileProvider);
//     emailController.text = profile.userEmail;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profile = ref.watch(profileProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update Email'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Enter your new email address",
//               style: TextStyle(fontSize: 14, color: Colors.black54),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//               controller: emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: InputDecoration(
//                 labelText: "Email",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final newEmail = emailController.text.trim();

//                   if (newEmail.isEmpty || !newEmail.contains("@")) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Please enter a valid email")),
//                     );
//                     return;
//                   }

//                   // Update email in state and save to local storage
//                   final updatedProfile = profile.copyWith(userEmail: newEmail);
//                   await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Email updated successfully")),
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text("Update Email"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
