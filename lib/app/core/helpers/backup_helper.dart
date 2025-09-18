import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../../services/sembast_service.dart'; // للوصول إلى اسم قاعدة البيانات

class BackupHelper {
  // --- دالة النسخ الاحتياطي ---
  static Future<void> createBackup(BuildContext context) async {
    try {
      // 1. تحديد مسار قاعدة البيانات الحالية
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, SembastService.DB_NAME);
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قاعدة البيانات غير موجودة!')));
        return;
      }

      // 2. السماح للمستخدم باختيار مكان حفظ النسخة الاحتياطية
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // ألغى المستخدم العملية
        return;
      }

      // 3. إنشاء اسم فريد للملف (e.g., backup-2023-10-27.db)
      final timestamp = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
      final backupFileName = 'backup-$timestamp.db';
      final backupFilePath = join(selectedDirectory, backupFileName);

      // 4. نسخ الملف
      await dbFile.copy(backupFilePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ النسخة الاحتياطية بنجاح في: $backupFilePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل النسخ الاحتياطي: $e')),
      );
    }
  }

  // --- دالة الاستعادة ---
  static Future<void> restoreBackup(BuildContext context) async {
    try {
      // 1. السماح للمستخدم باختيار ملف النسخة الاحتياطية
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null || result.files.single.path == null) {
        // ألغى المستخدم العملية
        return;
      }

      final backupFile = File(result.files.single.path!);

      // 2. تحديد مسار قاعدة البيانات الحالية
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, SembastService.DB_NAME);

      // 3. استبدال قاعدة البيانات الحالية بالنسخة الاحتياطية
      // ملاحظة: هذه عملية خطيرة ويجب تحذير المستخدم
      await backupFile.copy(dbPath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت استعادة النسخة الاحتياطية بنجاح. الرجاء إعادة تشغيل التطبيق.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشلت عملية الاستعادة: $e')),
      );
    }
  }
}
