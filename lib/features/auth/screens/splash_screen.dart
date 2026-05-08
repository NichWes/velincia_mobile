import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/greeting_utils.dart';
import '../providers/auth_provider.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await context.read<AuthProvider>().checkLogin();
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo_velincia.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Velincia Build',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              getDynamicGreeting(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFFF97316),
            ),
          ],
        ),
      ),
    );
  }
}
