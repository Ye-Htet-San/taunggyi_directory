// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/providers.dart';
// import 'package:tgi_directory/config/providers.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/auth/presentation/widgets/custom_button.dart';
import 'package:tgi_directory/features/auth/presentation/widgets/custom_input_field.dart';
// import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
// import 'package:tgi_directory/features/places/application/services/sync_service.dart';
// import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final authService = AuthService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // final String confirmEmail = "ye@gmail.com";
  // final String confirmPassword = "123";

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff2f3e2), Color(0xffb2e5f8), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? double.infinity : 500,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "Login to continue",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 20),

                            //Email
                            CustomInputField(
                              controller: emailController,
                              hintText: 'Email',
                              icon: Icons.email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            //Password
                            CustomInputField(
                              controller: passwordController,
                              hintText: 'Password',
                              icon: Icons.lock,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            //Login Button
                            CustomButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Logging in...")),
                                );

                                final userId = await ref
                                    .read(authControllerProvider)
                                    .login(
                                      emailController.text,
                                      passwordController.text,
                                      ref,
                                    );
                                print("User ID from login: $userId");
                                // final token = await AuthService().getToken();
                                // print("Token in app: $token");

                                // final account =
                                //     await AuthService().getAccountInfo();
                                // print("My Account: $account");
                                // <-- here
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();

                                if (userId != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login successful!"),
                                    ),
                                  );
                                  // await Future.delayed(
                                  //   const Duration(milliseconds: 500),
                                  // );
                                  if (!mounted) return;
                                  context.go(
                                    '/auth-splash',
                                  ); // navigate after login
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Login failed")),
                                  );
                                }
                              },
                              label: 'LOGIN',
                            ),
                            const SizedBox(height: 24),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    context.go('/signup');
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
