import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- 1. استيراد GoRouter
import 'widgets/nav_card.dart';
import 'widgets/stat_card.dart';
import '../../providers/database_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsyncValue = ref.watch(customersStreamProvider);
    final bookingsAsyncValue = ref.watch(bookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // بطاقات الإحصائيات (تبقى كما هي)
            Row(
              children: [
                Expanded(
                  child: customersAsyncValue.when(
                    data: (customers) => StatCard(
                      title: 'إجمالي العملاء',
                      value: customers.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    loading: () => const StatCard(title: 'إجمالي العملاء', value: '...', icon: Icons.people, color: Colors.blue),
                    error: (err, stack) => const StatCard(title: 'خطأ', value: '!', icon: Icons.error, color: Colors.red),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: bookingsAsyncValue.when(
                    data: (bookings) => StatCard(
                      title: 'إجمالي الحجوزات',
                      value: bookings.length.toString(),
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                    loading: () => const StatCard(title: 'إجمالي الحجوزات', value: '...', icon: Icons.calendar_today, color: Colors.green),
                    error: (err, stack) => const StatCard(title: 'خطأ', value: '!', icon: Icons.error, color: Colors.red),
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
            // --- [التصحيح الرئيسي هنا] ---
            // بطاقات التنقل مع تمرير دالة onTap
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  NavCard(
                    title: 'إدارة العملاء',
                    icon: Icons.person_add,
                    color: Colors.orange,
                    onTap: () => context.go('/customers'), // <-- تنفيذ التنقل هنا
                  ),
                  NavCard(
  title: 'إدارة الحجوزات',
  icon: Icons.event,
  color: Colors.purple,
  onTap: () => context.go('/bookings'), // <-- تفعيل التنقل هنا
),
                  NavCard(
                    title: 'إدارة القاعات',
                    icon: Icons.location_on,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Implement venues screen navigation
                      print('الانتقال إلى القاعات');
                    },
                  ),
                  NavCard(
                    title: 'إدارة المخزون',
                    icon: Icons.inventory,
                    color: Colors.cyan,
                    onTap: () {
                      // TODO: Implement inventory screen navigation
                      print('الانتقال إلى المخزون');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
