import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_providers.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/customer_list_tile.dart'; // استيراد الويدجت الجديد

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مشاهدة الـ StreamProvider الخاص بالعملاء
    final customersAsyncValue = ref.watch(customersStreamProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        centerTitle: true,
      ),
      body: customersAsyncValue.when(
        // في حالة وجود بيانات
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد عملاء حتى الآن.\nقم بإضافة عميل جديد!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return CustomerListTile(customer: customer);
            },
          );
        },
        // في حالة التحميل
        loading: () => const Center(child: CircularProgressIndicator()),
        // في حالة حدوث خطأ
        error: (error, stackTrace) => Center(
          child: Text(
            'حدث خطأ أثناء تحميل البيانات:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    // --- [التعديل هنا] ---
    // الانتقال إلى شاشة إضافة عميل باستخدام GoRouter
     context.push('/add-customer');
  },
  backgroundColor: Colors.teal,
  child: const Icon(Icons.add, color: Colors.white),
),
    );
  }
}
