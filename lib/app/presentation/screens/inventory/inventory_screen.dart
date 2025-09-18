import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_providers.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام الـ Provider الذي أنشأناه سابقًا
    final inventoryAsync = ref.watch(inventoryItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزون'),
        centerTitle: true,
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('لم يتم إضافة أي أصناف للمخزون بعد.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.brown),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الكمية المتاحة: ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // TODO: Implement delete functionality
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-inventory-item');
        },
        tooltip: 'إضافة صنف جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}
