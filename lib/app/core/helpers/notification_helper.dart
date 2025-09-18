import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // دالة لتهيئة المكتبة
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // يستخدم أيقونة التطبيق

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
    tz.initializeTimeZones(); // تهيئة المناطق الزمنية
  }

  // دالة لطلب الأذونات (مهمة لـ iOS و Android 13+)
  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // --- [الأهم] دالة لجدولة إشعار تذكير ---
  static Future<void> scheduleBookingReminder({
     required int bookingId,
  required String customerName,
  required String customerPhone, // <-- [جديد] نحتاج رقم الجوال
  required DateTime eventDate,
  }) async {
    // حساب موعد الإشعار (مثال: قبل 24 ساعة من موعد الحجز)
    final scheduleDate = eventDate.subtract(const Duration(days: 1));

    // التأكد من أن الموعد لم يمضِ
    if (scheduleDate.isBefore(DateTime.now())) {
      return; // لا تقم بجدولة إشعار لموعد فات
    }

    await _notificationsPlugin.zonedSchedule(
      bookingId, // استخدام ID الحجز ليكون ID الإشعار (لمنع التكرار)
      'تذكير بموعد حجز', // عنوان الإشعار
      'لا تنسَ تذكير العميل "$customerName" بموعد حجزه غدًا.', // نص الإشعار
      tz.TZDateTime.from(scheduleDate, tz.local), // وقت الإشعار
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'booking_reminders_channel',
          'تذكيرات الحجوزات',
          channelDescription: 'قناة خاصة بتذكيرات مواعيد الحجوزات',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
     final String message = 'مرحباً $customerName، نود تذكيركم بموعد حجزكم بتاريخ ${DateFormat.yMMMEd('ar').format(eventDate)}.';
  final String payload = '$customerPhone|$message'; // مثال: "966501234567|مرحباً أحمد..."

  await _notificationsPlugin.zonedSchedule(
    bookingId,
    'تذكير بموعد حجز',
    'لا تنسَ تذكير العميل "$customerName" بموعد حجزه غدًا.',
    tz.TZDateTime.from(scheduleDate, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'booking_reminders_channel',
        'تذكيرات الحجوزات',
        channelDescription: 'قناة خاصة بتذكيرات مواعيد الحجوزات',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: payload, // <-- [الأهم] إضافة الحمولة هنا
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  }
// في notification_helper.dart

class NotificationHelper {
  // ...

  // --- [تعديل] تعديل دالة التهيئة ---
  static Future<void> initialize({
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    // ... (كود androidSettings و iosSettings يبقى كما هو)

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // --- [تعديل] تمرير الدالة هنا ---
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    
    tz.initializeTimeZones();
  }
  // ...
}

  // دالة لإلغاء إشعار معين (عند حذف الحجز مثلاً)
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
