// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/auth/data/models/user_model.dart';
import 'package:tgi_directory/features/auth/presentation/widgets/custom_button.dart';
import 'package:tgi_directory/features/auth/presentation/widgets/custom_input_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();
  //manual credictentials

  // String username = "ye";
  // String email = "ye@gmail.com";
  // String password = "123";
  // String confirmPassword = "123";

  @override
  void dispose() {
    super.dispose();

    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff0eafc), Color(0xff61cef2), Color(0xfff4b3ef)],
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
                              'Create Account',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 20),

                            //Username
                            CustomInputField(
                              controller: usernameController,
                              hintText: 'Username',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

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
                            const SizedBox(height: 8),

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
                            const SizedBox(height: 8),

                            //Confirm Password
                            CustomInputField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            CustomButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  UserModel user = UserModel(
                                    username: usernameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  bool success = await authService.signup(user);

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Sign up successful! Please login",
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ),
                                    );
                                    Future.delayed(
                                      Duration(milliseconds: 1000),
                                      () {
                                        context.go('/login');
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Signup failed. Please try again.",
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Please fill the required fields.",
                                      ),
                                    ),
                                  );
                                }
                              },
                              label: 'SIGN UP',
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
