import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tgi_directory/config/app_theme.dart';
import 'package:tgi_directory/config/go_router.dart';
import 'package:tgi_directory/config/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: TaunggyiGuide()));
}

class TaunggyiGuide extends ConsumerWidget {
  const TaunggyiGuide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider); //router

    final themeMode = ref.watch(themeProvider);//Listen to Theme

    return MaterialApp.router(
      title: 'Taunggyi Directory',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
