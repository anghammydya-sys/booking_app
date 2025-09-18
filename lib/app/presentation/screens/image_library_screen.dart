import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_providers.dart'; // ستحتاج لإنشاء mediaStreamProvider

// أنشئ هذا الـ Provider في database_providers.dart
final mediaStreamProvider = StreamProvider((ref) {
  return ref.watch(sembastServiceProvider).watchMediaItems();
});

class ImageLibraryScreen extends ConsumerWidget {
  const ImageLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(mediaStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('مكتبة الصور')),
      body: mediaAsync.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('المكتبة فارغة.'));
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  // أعد مسار الصورة عند اختيارها
                  Navigator.of(context).pop(item.filePath);
                },
                child: Card(
                  child: Image.file(File(item.filePath), fit: BoxFit.cover),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('خطأ: $err'),
      ),
    );
  }
}
