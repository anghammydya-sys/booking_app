import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // انتظر لمدة 3 ثوانٍ
    await Future.delayed(const Duration(seconds: 3));
    
    // تأكد من أن الويدجت لا تزال في الشجرة قبل التنقل
    if (mounted) {
      // استخدم go() بدلاً من push() لاستبدال شاشة البداية في تاريخ التنقل
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // أو أي لون خلفية تفضله
      body: Center(
        // --- [التحسين البصري هنا] ---
        // عرض الشعار الخاص بك
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: 150, // اضبط الحجم حسب شعارك
        ),
      ),
    );
  }
}
