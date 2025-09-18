import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_providers.dart';

class VenuesScreen extends ConsumerWidget {
  const VenuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venuesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة القاعات'),
        centerTitle: true,
      ),
      body: venuesAsync.when(
        data: (venues) {
          if (venues.isEmpty) {
            return const Center(child: Text('لم يتم إضافة أي قاعات بعد.'));
          }
          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_city_outlined, color: Colors.purple),
                  title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('النوع: ${venue.type}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // TODO: Implement delete functionality with confirmation
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
          context.push('/add-venue');
        },
        tooltip: 'إضافة قاعة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }
}
