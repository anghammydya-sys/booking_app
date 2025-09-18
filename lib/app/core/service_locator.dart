import 'package:get_it/get_it.dart';
import '../services/sembast_service.dart';

// إنشاء نسخة من GetIt
final locator = GetIt.instance;

// --- [تعديل رئيسي هنا] ---
// تحويل الدالة إلى Future<void> للتعامل مع التهيئة غير المتزامنة
Future<void> setupLocator() async {
  // إنشاء وتسجيل SembastService كـ Singleton
  final sembastService = SembastService();
  
  // --- [مهم جدًا] ---
  // استدعاء دالة init() هنا لفتح قاعدة البيانات مرة واحدة فقط
  await sembastService.init(); 
  
  // تسجيل النسخة التي تم تهيئتها بالفعل
  locator.registerSingleton<SembastService>(sembastService);

  // يمكنك تسجيل أي خدمات أخرى هنا بنفس الطريقة
  // مثال: locator.registerLazySingleton(() => NavigationService());
}
