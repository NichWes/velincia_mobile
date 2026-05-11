import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeepLinkService.init(navigatorKey);

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Velincia Build',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF97316),
            primary: const Color(0xFFF97316),
            secondary: const Color(0xFF0F172A),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8FAFC),
            foregroundColor: Color(0xFF0F172A),
            elevation: 0,
            centerTitle: false,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF97316),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
