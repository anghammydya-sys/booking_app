// TODO Implement this library.import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_providers.dart';
import '../../widgets/nav_card.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب بيانات الإحصائيات
    final customersCount = ref.watch(customersStreamProvider).asData?.value.length ?? 0;
    final bookingsCount = ref.watch(bookingsStreamProvider).asData?.value.length ?? 0;
    
    // جلب المستخدم الحالي لتحديد الصلاحيات
    final currentUser = ref.watch(authProvider).user;

    // قائمة بطاقات التنقل
    final navItems = [
      {'title': 'إدارة الحجوزات', 'icon': Icons.event, 'route': '/bookings', 'color': Colors.purple},
      {'title': 'إدارة العملاء', 'icon': Icons.people, 'route': '/customers', 'color': Colors.blue},
      {'title': 'مهام اليوم', 'icon': Icons.checklist, 'route': '/daily-tasks', 'color': Colors.amber.shade800},
      {'title': 'تركيبات الغد', 'icon': Icons.construction, 'route': '/upcoming-installs', 'color': Colors.brown},
      {'title': 'إدارة المفقودات', 'icon': Icons.find_in_page, 'route': '/lost-items', 'color': Colors.red},
      {'title': 'التقويم', 'icon': Icons.calendar_month, 'route': '/calendar', 'color': Colors.teal},
      // --- [صلاحيات المدير فقط] ---
      if (currentUser?.role == 'admin') ...[
        {'title': 'إدارة المستخدمين', 'icon': Icons.admin_panel_settings, 'route': '/users', 'color': Colors.grey.shade700},
        {'title': 'التقارير', 'icon': Icons.bar_chart, 'route': '/reports', 'color': Colors.indigo},
        {'title': 'الإعدادات', 'icon': Icons.settings, 'route': '/settings', 'color': Colors.blueGrey},
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
        actions
// ... (بداية الكود من الرد السابق)

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              // GoRouter سيقوم بإعادة التوجيه إلى شاشة تسجيل الدخول
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // إعادة تحميل البيانات عند السحب للأسفل
          ref.invalidate(customersStreamProvider);
          ref.invalidate(bookingsStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'مرحباً بك، ${currentUser?.name ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // بطاقات الإحصائيات
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'إجمالي العملاء',
                    value: customersCount.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'إجمالي الحجوزات',
                    value: bookingsCount.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'الوصول السريع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            // بطاقات التنقل
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                return NavCard(
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: () => context.push(item['route'] as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
