import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';

final accountProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = AuthService();
  return await authService.getAccountInfo();
});
