import 'package:flutter/material.dart';
import '../../core/helpers/backup_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('إنشاء نسخة احتياطية'),
            subtitle: const Text('حفظ نسخة من قاعدة البيانات في مكان آمن.'),
            onTap: () => BackupHelper.createBackup(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore_page_outlined, color: Colors.orange),
            title: const Text('استعادة نسخة احتياطية'),
            subtitle: const Text('استبدال البيانات الحالية ببيانات من نسخة سابقة.'),
            onTap: () async {
              // تحذير المستخدم قبل المتابعة
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تحذير!'),
                  content: const Text('هذه العملية ستقوم بحذف كل البيانات الحالية واستبدالها بالنسخة التي ستختارها. هل أنت متأكد؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('نعم، متأكد')),
                  ],
                ),
              );
              if (confirm == true) {
                BackupHelper.restoreBackup(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
