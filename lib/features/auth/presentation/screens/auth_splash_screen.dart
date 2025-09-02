// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/config/providers.dart';

class AuthSplashScreen extends ConsumerStatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  ConsumerState<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends ConsumerState<AuthSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final authController = ref.read(authControllerProvider);

    await authController.checkLoginStatus(ref); // Load login state from storage

    // Load favorites and visited
    
    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authController.isLoggedIn) {
      context.go('/home'); // Already logged in -> go home
    } else {
      context.go('/login'); // Not logged in -> go login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator(color: Colors.teal)),
        ],
      ),
    );
  }
}
