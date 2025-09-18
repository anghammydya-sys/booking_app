import 'package:crypto/crypto.dart'; // مكتبة لتشفير كلمة المرور
import 'dart:convert'; // للتحويل إلى utf8

class User {
  int? id;
  String username;
  String passwordHash; // لن نخزن كلمة المرور كنص عادي أبدًا
  String role; // 'admin' أو 'employee'

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });

  // دالة لإنشاء مستخدم جديد مع تشفير كلمة المرور
  factory User.createNew({
    required String username,
    required String plainPassword,
    required String role,
  }) {
    final bytes = utf8.encode(plainPassword); // تحويل كلمة المرور إلى bytes
    final digest = sha256.convert(bytes); // تطبيق خوارزمية التشفير
    return User(
      username: username,
      passwordHash: digest.toString(), // تخزين الـ hash
      role: role,
    );
  }

  // دوال التحويل من وإلى Sembast
  Map<String, dynamic> toSembast() {
    return {
      'username': username,
      'passwordHash': passwordHash,
      'role': role,
    };
  }

  static User fromSembast(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      passwordHash: map['passwordHash'],
      role: map['role'],
    );
  }
}
