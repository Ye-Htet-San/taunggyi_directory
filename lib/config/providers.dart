import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/features/auth/application/controllers/auth_controller.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(authService: AuthService());
});
