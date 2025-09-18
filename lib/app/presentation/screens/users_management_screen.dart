import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user.dart';
import '../../../providers/database_providers.dart'; // نفترض وجود usersStreamProvider هنا

class UsersManagementScreen extends ConsumerWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        centerTitle: true,
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.role == 'admin' ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(
                      user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      color: user.role == 'admin' ? Colors.red.shade800 : Colors.blue.shade800,
                    ),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الصلاحية: ${user.role}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        tooltip: 'تعديل المستخدم',
                        onPressed: () {
                          // TODO: Implement edit user functionality
                          // context.push('/edit-user/${user.id}');
                        },
                      ),
                      // لا تسمح للمدير بحذف نفسه
                      if (ref.read(authProvider).user?.id != user.id)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'حذف المستخدم',
                          onPressed: () async {
                            // عرض رسالة تأكيد قبل الحذف
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text('هل أنت متأكد من رغبتك في حذف المستخدم "${user.name}"؟'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('حذف')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(sembastServiceProvider).deleteUser(user.id!);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-user');
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'إضافة مستخدم جديد',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
