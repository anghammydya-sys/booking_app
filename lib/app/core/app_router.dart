import 'package:go_router/go_router.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/customers_screen.dart';
import '../presentation/screens/add_customer_screen.dart';
import '../presentation/screens/bookings_screen.dart';
import '../presentation/screens/add_booking_screen.dart'; // <-- استيراد الشاشة الجديدة
import '../presentation/screens/booking_details_screen.dart'; // <-- استيراد الشاشة الجديدة



final router = GoRouter(
  // يمكن إضافة initialLocation لاحقًا إذا احتجنا
  // initialLocation: '/',

  // تفعيل طباعة سجلات التنقل في الـ console للمساعدة في التشخيص
  debugLogDiagnostics: true,

  // تعريف كل المسارات على مستوى واحد (غير متداخلة)
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: '/add-customer', // <-- مسار مباشر وبسيط
      builder: (context, state) => const AddCustomerScreen(),
    ),
       GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingsScreen(),
    ),
     GoRoute(
      path: '/booking/:id', // :id هو متغير ديناميكي
      builder: (context, state) {
        // استخراج الـ id من المسار
        final bookingId = int.parse(state.pathParameters['id']!);
        return BookingDetailsScreen(bookingId: bookingId);
      },
    ),
    // في app_router.dart، داخل قائمة GoRouter
GoRoute(
  path: '/lost-items',
  builder: (context, state) => const LostItemsScreen(),
),
// في app_router.dart، داخل قائمة GoRouter
GoRoute(
  path: '/add-lost-item',
  builder: (context, state) => const AddLostItemScreen(),
),

   GoRoute(
  path: '/add-booking',
  builder: (context, state) {
    // اقرأ الـ ID من الـ extra
    final parentId = state.extra as int?; 
    return AddBookingScreen(parentBookingId: parentId); // <-- مرره للشاشة
  },
)

  ],
);
// في app_router.dart
GoRoute(
  path: '/venues',
  builder: (context, state) => const VenuesScreen(),
),
GoRoute(
  path: '/add-venue',
  builder: (context, state) => const AddVenueScreen(),
),
// في app_router.dart
GoRoute(
  path: '/inventory',
  builder: (context, state) => const InventoryScreen(),
),
GoRoute(
  path: '/add-inventory-item',
  builder: (context, state) => const AddInventoryItemScreen(),
),
// في app_router.dart
GoRoute(
  path: '/calendar',
  builder: (context, state) => const CalendarScreen(),
),
// في app_router.dart
GoRoute(
  path: '/lost-item-details',
  builder: (context, state) {
    // استخراج الكائن الذي تم تمريره
    final lostItem = state.extra as LostItem;
    return LostItemDetailsScreen(lostItem: lostItem);
  },
),
GoRoute(
  path: '/reports',
  builder: (context, state) => const ReportsScreen(),
),

GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
// في app_router.dart

final GoRouter router = GoRouter(
  // ...
  redirect: (BuildContext context, GoRouterState state) {
    // استخدم Riverpod لقراءة حالة المصادقة
    final isLoggedIn = ref.read(authStateProvider) != null;
    
    final isLoggingIn = state.matchedLocation == '/login';

    // إذا لم يكن المستخدم مسجلاً دخوله ويحاول الوصول لأي صفحة غير تسجيل الدخول
    if (!isLoggedIn && !isLoggingIn) {
      return '/login'; // أعد توجيهه إلى صفحة تسجيل الدخول
    }
    
    // إذا كان المستخدم مسجلاً دخوله ويحاول الوصول لصفحة تسجيل الدخول
    if (isLoggedIn && isLoggingIn) {
      return '/'; // أعد توجيهه إلى لوحة التحكم
    }

    return null; // لا تقم بإعادة التوجيه
  },
  // ...
);
GoRoute(
  path: '/daily-tasks',
  builder: (context, state) => const DailyTasksScreen(),
),
GoRoute(
  path: '/tomorrow-installations',
  builder: (context, state) => const TomorrowInstallationsScreen(),
),
// في app_router.dart

final GoRouter router = GoRouter(
  initialLocation: '/', // <-- اجعل هذه هي نقطة البداية
  routes: [
    // --- [التحسين هنا] ---
    GoRoute(
      path: '/', // المسار الأولي
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // ... (بقية المسارات كما هي)
  ],
);
