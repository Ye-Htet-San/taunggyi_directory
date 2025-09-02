// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/profile/application/providers/account_provider.dart';
// import 'package:tgi_directory/features/profile/application/providers/profile_provider.dart';
import 'package:tgi_directory/features/profile/presentation/widgets/section_title.dart';

class AccountDetailsPage extends ConsumerWidget {
  const AccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final profile = ref.watch(profileProvider);
    final accountAsync = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: accountAsync.when(
        data: (account) {
          if (account == null) {
            return const Center(child: Text("No account data found"));
          }
          final email = account['userEmail'] ?? "Unknown";
          final username = account['userName'] ?? "User";
          final userId = 'USR-${username.hashCode.toString().substring(0, 6)}';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              SectionTitle(title: "Account Info"),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    //Email
                    ListTile(
                      leading: const Icon(
                        Icons.alternate_email,
                        color: Colors.blue,
                      ),
                      title: const Text("Email"),
                      subtitle: Text(email),
                      // trailing: TextButton(
                      //   onPressed: () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text("Update email coming soon"),
                      //       ),
                      //     );
                      //   },
                      //   child: const Text("Change"),
                      // ),
                    ),
                    const Divider(height: 0),

                    // User ID
                    ListTile(
                      leading: const Icon(Icons.badge, color: Colors.green),
                      title: const Text("User ID"),
                      subtitle: Text(userId),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID copied")),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),


              SectionTitle(title: "Security"),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    // Change Password

                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.orange),
                      title: const Text("Change Password"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SectionTitle(title: "Danger Zone"),

              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Delete account feature coming soon"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error:$error')),
      ),
    );
  }
}


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    final formKey = GlobalKey<FormState>();

    Future<void> changePassword(BuildContext context) async {
      if (!formKey.currentState!.validate()) return;

      setState(() {
        isLoading = true;
      });

      final success = await AuthService().changePassword(
        oldPasswordController.text,
        newPasswordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")),
        );
        Navigator.pop(context);

      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update password")
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your current and new password below.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
          
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => 
                value!.isEmpty? "Please enter your current password" :null,
              ),
              const SizedBox(height: 16),
          
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => 
                value!.isEmpty? "Please enter a new password" : null,
              ),
              const SizedBox(height: 24),
          
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:isLoading ? null: () => changePassword(context),
                    
                  child: isLoading ?
                  const CircularProgressIndicator(color: Colors.white,):
                  const Text("Update Password"),
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
