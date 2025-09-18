import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../core/service_locator.dart';
import '../../services/sembast_service.dart';

// هذا الـ Provider سيحتوي على المستخدم الحالي (أو null)
final authStateProvider = StateProvider<User?>((ref) => null);

// هذا الكلاس سيحتوي على منطق تسجيل الدخول والخروج
class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier(this.ref) : super(null);
  final Ref ref;

  Future<bool> login(String username, String password) async {
    final sembastService = ref.read(sembastServiceProvider);
    final user = await sembastService.authenticateUser(username, password);
    if (user != null) {
      state = user; // تحديث الحالة بالمسخدم الجديد
      return true;
    }
    return false;
  }

  void logout() {
    state = null; // إعادة الحالة إلى null
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});
