import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/booking.dart';
import '../../providers/database_providers.dart';

// Provider جديد يقوم بفلترة الحجوزات التي انتهت اليوم
final completedTodayBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final allBookingsStream = ref.watch(bookingsStreamProvider);
  
  return allBookingsStream.map((asyncValue) {
    return asyncValue.when(
      data: (bookings) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        // فلترة الحجوزات التي تاريخ انتهائها هو اليوم
        return bookings.where((booking) {
          final eventEndDate = booking.eventDate.add(Duration(days: booking.daysCount -1));
          return eventEndDate.year == today.year &&
                 eventEndDate.month == today.month &&
                 eventEndDate.day == today.day &&
                 booking.status != 'مكتمل'; // استبعاد المكتملة بالفعل
        }).toList();
      },
      loading: () => [],
      error: (e, s) => [],
    );
  });
});

class DailyTasksScreen extends ConsumerWidget {
  const DailyTasksScreen({super.key});

  void _showLostItemsDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل هناك مفقودات؟'),
        content: Text('هل تم تسجيل أي مفقودات خاصة بالحجز رقم ${booking.bookingNumber}؟'),
        actions: [
          TextButton(
            child: const Text('لا، كل شيء سليم'),
            onPressed: () {
              // TODO: تحديث حالة الحجز إلى "مكتمل"
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('نعم، تسجيل مفقودات'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // الانتقال إلى شاشة إضافة المفقودات مع تمرير رقم الحجز
              context.push('/add-lost-item', extra: booking);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(completedTodayBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مهام ما بعد الحفلات')),
      body: tasksAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('لا توجد مهام مطلوبة لليوم.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('حجز رقم: ${booking.bookingNumber}'),
                  subtitle: Text('نوع الحفلة: ${booking.eventType} - ${booking.venueName ?? booking.address}'),
                  trailing: ElevatedButton(
                    child: const Text('تم الفك'),
                    onPressed: () {
                      // عند الضغط، تظهر رسالة المفقودات
                      _showLostItemsDialog(context, booking);
                    },
                  ),
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
// في daily_tasks_screen.dart

// ...
onPressed: () async {
  // ...
  // إذا كان الحجز "نساء"
  if (booking.eventType == 'نساء') {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إجراءات ما بعد الفك'),
        content: const Text('هل تم تسجيل الرهن والمفقودات؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop('register_pledge'), child: const Text('تسجيل الرهن')),
          TextButton(onPressed: () => Navigator.of(ctx).pop('register_lost_items'), child: const Text('تسجيل المفقودات')),
          TextButton(onPressed: () => Navigator.of(ctx).pop('done'), child: const Text('تم كل شيء')),
        ],
      ),
    );
    // بناءً على اختيار المستخدم، انتقل إلى الشاشة المناسبة
    if (action == 'register_pledge') context.push('/booking/${booking.id}/add-pledge');
    // ...
  }
}
// في daily_tasks_screen.dart، داخل ListView.builder

final booking = dailyTasks[index];
final dismantlingDate = booking.eventDate.add(Duration(days: booking.daysCount - 1));

Card(
  child: ListTile(
    title: Text('حجز: ${booking.customerName} - ${booking.venueName ?? booking.address}'),
    subtitle: Text(
      'نوع الحفلة: ${booking.eventType}\n'
      'وقت الفك: ${DateFormat.yMMMd('ar').format(dismantlingDate)}',
      style: TextStyle(color: Colors.grey.shade600),
    ),
    isThreeLine: true,
    // --- [التحسين هنا] ---
    trailing: ElevatedButton(
      child: const Text('اتخاذ إجراء'),
      onPressed: () => _showPostEventActions(context, ref, booking),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.shade800,
      ),
    ),
  ),
)
// في daily_tasks_screen.dart، أضف هذه الدالة

void _showPostEventActions(BuildContext context, WidgetRef ref, Booking booking) async {
  final sembastService = ref.read(sembastServiceProvider);

  final action = await showDialog<String>(
    context: context,
    barrierDismissible: false, // يجب على المستخدم اختيار إجراء
    builder: (ctx) => AlertDialog(
      title: const Text('إجراءات ما بعد الحفلة'),
      content: const Text('ما هو الإجراء الذي تم اتخاذه بخصوص هذا الحجز؟'),
      actions: [
        TextButton(
          child: const Text('تم الفك (لا يوجد مفقودات)'),
          onPressed: () => Navigator.of(ctx).pop('dismantled_ok'),
        ),
        TextButton(
          child: const Text('تسجيل مفقودات'),
          onPressed: () => Navigator.of(ctx).pop('register_lost_items'),
        ),
        if (booking.eventType == 'نساء') // يظهر فقط لحجوزات النساء
          TextButton(
            child: const Text('إدارة الرهن'),
            onPressed: () => Navigator.of(ctx).pop('manage_pledge'),
          ),
      ],
    ),
  );

  // بناءً على اختيار المستخدم، قم بتنفيذ الإجراء المناسب
  if (action == 'dismantled_ok' && context.mounted) {
    // تحديث حالة الحجز إلى "مكتمل"
    await sembastService.updateBookingStatus(booking.id!, 'مكتمل');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث حالة الحجز إلى مكتمل.'), backgroundColor: Colors.green),
    );
  } else if (action == 'register_lost_items' && context.mounted) {
    context.push('/add-lost-item', extra: booking);
  } else if (action == 'manage_pledge' && context.mounted) {
    context.push('/booking/${booking.id}'); // يذهب إلى تفاصيل الحجز حيث توجد إدارة الرهن
  }
}
