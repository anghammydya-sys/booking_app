import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/booking.dart';
import '../providers/database_providers.dart';

class TomorrowInstallationsScreen extends ConsumerWidget {
  const TomorrowInstallationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tomorrowInstallationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تركيبات الغد'),
        centerTitle: true,
      ),
      body: tasksAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد حجوزات لتركيبها غدًا.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return InstallationTaskCard(booking: booking); // استخدام ويدجت مخصصة
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

// --- ويدجت مخصصة لعرض بطاقة المهمة ---
class InstallationTaskCard extends StatelessWidget {
  final Booking booking;
  const InstallationTaskCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- معلومات الحجز الأساسية ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حجز: ${booking.bookingNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text(booking.eventType),
                  backgroundColor: Colors.teal.withOpacity(0.1),
                ),
              ],
            ),
            const Divider(height: 15),
            
            // --- [الأهم] تفاصيل اليوم التالي ---
            _buildTomorrowDetails(context),

            const SizedBox(height: 10),
            // زر للانتقال إلى تفاصيل الحجز الكاملة
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/booking/${booking.id}'),
                child: const Text('عرض كامل التفاصيل →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء تفاصيل اليوم التالي
  Widget _buildTomorrowDetails(BuildContext context) {
    // هذا مجرد مثال، يجب توسيعه ليشمل كل الحالات
    // سنحتاج إلى إضافة الحقول الخاصة بالتغييرات اليومية إلى نموذج Booking
    // مثل dailyFlowerColorChanges و dailyDifferentDecors

    // مثال بسيط: عرض لون الورد الأساسي
    if (booking.flowerColor != null && booking.flowerColor!.isNotEmpty) {
      return InfoRow(icon: Icons.color_lens_outlined, title: 'لون الورد المطلوب:', value: booking.flowerColor!);
    }

    // مثال آخر: عرض ملاحظات ديكور الرجال
    if (booking.eventType == 'رجال' && booking.menDecorNotes != null) {
       return InfoRow(icon: Icons.notes, title: 'ملاحظات الديكور:', value: booking.menDecorNotes!);
    }

    // إذا لم تكن هناك تفاصيل خاصة، يمكن عرض العنوان أو اسم الصالة
    return InfoRow(
      icon: Icons.location_on_outlined,
      title: 'الموقع:',
      value: booking.venueName ?? booking.address ?? 'غير محدد',
    );
  }
}

// ويدجت مساعدة لعرض صف معلومة
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const InfoRow({super.key, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey.shade800))),
        ],
      ),
    );
  }
}
