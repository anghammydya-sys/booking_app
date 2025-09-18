import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_providers.dart';

class LostItemsScreen extends ConsumerWidget {
  const LostItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lostItemsAsync = ref.watch(lostItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المفقودات'),
        centerTitle: true,
      ),
      body: lostItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد عناصر مفقودة مسجلة.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.search, color: Colors.orange),
                  title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'الحجز رقم: ${item.bookingId}\n'
                    'الحالة: ${item.status}\n'
                    'سُجل بواسطة: ${item.reportedBy} بتاريخ ${DateFormat.yMd('ar').format(item.reportedAt)}',
                  ),
                  isThreeLine: true,
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
          // TODO: Navigate to AddLostItemScreen
          context.push('/add-lost-item');
        },
        tooltip: 'تسجيل عنصر مفقود',
        child: const Icon(Icons.add),
      ),
    );
  }
}
// في lost_items_screen.dart، داخل ListView.builder

// ...
final item = items[index];
return Card(
  color: item.status == 'مغلق' ? Colors.green[50] : Colors.red[50],
  child: ListTile(
    title: Text(item.description),
    subtitle: Text('حجز رقم: ${item.bookingId}'),
    trailing: Text(item.status),
    onTap: () {
      // الانتقال إلى شاشة التفاصيل مع تمرير الكائن
      context.push('/lost-item-details', extra: item);
    },
  ),
);
// ...
