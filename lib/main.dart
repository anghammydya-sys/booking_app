import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/core/app_router.dart';
import 'app/core/service_locator.dart';
import 'app/core/helpers/notification_helper.dart'; // <-- استيراد المساعد
import 'app/core/helpers/messaging_helper.dart';

// --- [تعديل رئيسي هنا] ---
// تحويل الدالة إلى Future<void> ووضع async
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- [جديد] تهيئة الإشعارات ---
  await NotificationHelper.initialize();
  await NotificationHelper.requestPermissions();
// في main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationHelper.initialize(
    // --- [الأهم] تعريف ماذا يحدث عند الضغط على الإشعار ---
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final String? payload = response.payload;
      if (payload != null) {
        // 1. فك ترميز الحمولة
        final parts = payload.split('|');
        if (parts.length == 2) {
          final phone = parts[0];
          final message = parts[1];
          
          // 2. استدعاء مساعد الرسائل لفتح واتساب
          try {
            await MessagingHelper.sendWhatsApp(phone, message);
          } catch (e) {
            // لا يمكن عرض SnackBar هنا لأن الـ context غير متاح
            // يمكن تسجيل الخطأ في ملف log مثلاً
            print('Failed to launch WhatsApp from notification: $e');
          }
        }
      }
    },
  );

  await NotificationHelper.requestPermissions();

  setupLocator();
  await locator.allReady();

  runApp(const ProviderScope(child: MyApp()));
}

  setupLocator();
  await locator.allReady();
  // الآن فقط يمكننا تشغيل التطبيق بأمان
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'منظومة الحجوزات',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      locale: const Locale('ar', 'SA'),
    );
  }
}
// في main.dart

import 'app/core/app_theme.dart'; // <-- استورد ملف الثيم

// ...

class MyApp extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ...
      theme: AppTheme.theme, // <-- استخدم الثيم المركزي هنا
      // ...
    );
  }
}
