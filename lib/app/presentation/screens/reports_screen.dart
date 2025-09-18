// reports_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... (استيرادات أخرى)

// Provider لإدارة حالة الفلاتر
final reportFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'reportType': 'bookings', // النوع الافتراضي
  'startDate': null,
  'endDate': null,
  'eventType': null,
  'status': null,
});

// Provider لجلب البيانات بناءً على الفلاتر
final filteredReportProvider = FutureProvider<List<dynamic>>((ref) async {
  final filters = ref.watch(reportFiltersProvider);
  final sembastService = ref.watch(sembastServiceProvider);

  // --- [المنطق الرئيسي هنا] ---
  // بناءً على filters['reportType']، استدعِ الدالة المناسبة من SembastService
  // مع تمرير بقية الفلاتر
  if (filters['reportType'] == 'bookings') {
    return await sembastService.getFilteredBookings(filters);
  } else if (filters['reportType'] == 'lost_items') {
    return await sembastService.getFilteredLostItems(filters);
  } else if (filters['reportType'] == 'payments') {
    return await sembastService.getFilteredPayments(filters);
  }
  return [];
});


class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportData = ref.watch(filteredReportProvider);
    final filters = ref.watch(reportFiltersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المتقدمة')),
      body: Column(
        children: [
          // --- [1. منطقة الفلاتر] ---
          _buildFiltersUI(context, ref),

          const Divider(thickness: 2),

          // --- [2. منطقة عرض النتائج] ---
          Expanded(
            child: reportData.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('لا توجد بيانات تطابق هذه الفلاتر.'));
                }
                // بناء الجدول بناءً على نوع التقرير
                if (filters['reportType'] == 'bookings') {
                  return _buildBookingsTable(items.cast<Booking>());
                } else if (filters['reportType'] == 'lost_items') {
                  return _buildLostItemsTable(items.cast<LostItem>());
                } else {
                  return _buildPaymentsTable(items.cast<Payment>());
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            ),
          ),
        ],
      ),
    );
  }

  // --- دوال مساعدة لبناء الواجهة ---
  Widget _buildFiltersUI(BuildContext context, WidgetRef ref) {
    // ... (هنا سنبني واجهة الفلاتر: أزرار اختيار نوع التقرير، حقول التواريخ، قوائم منسدلة)
    // عند تغيير أي فلتر، نقوم بتحديث الـ provider:
    // ref.read(reportFiltersProvider.notifier).update((state) => {...state, 'eventType': 'نساء'});
    return Container( /* واجهة الفلاتر */ );
  }

  Widget _buildBookingsTable(List<Booking> bookings) {
    // ... (بناء DataTable لعرض الحجوزات)
    return DataTable(columns: const [
      DataColumn(label: Text('رقم الحجز')),
      DataColumn(label: Text('العميل')),
      DataColumn(label: Text('المبلغ')),
      DataColumn(label: Text('الحالة')),
    ], rows: bookings.map((b) => DataRow(cells: [
      DataCell(Text(b.bookingNumber)),
      // ...
    ])).toList());
  }
  // ... (_buildLostItemsTable, _buildPaymentsTable)
}
// في ReportsScreen

void _exportToCsv(List<dynamic> data, String reportType) {
  if (data.isEmpty) return;

  List<List<dynamic>> rows = [];
  if (reportType == 'bookings') {
    rows.add(['رقم الحجز', 'العميل', 'التاريخ', 'المبلغ', 'الحالة']); // Headers
    rows.addAll((data as List<Booking>).map((b) => [b.bookingNumber, b.customerName, b.eventDate, b.totalAmount, b.status]));
  }
  // ... (منطق مشابه لبقية أنواع التقارير)

  String csv = const ListToCsvConverter().convert(rows);
  
  // حفظ الملف
  FileSaver.instance.saveFile(
    name: '${reportType}_report_${DateTime.now().toIso8601String()}',
    bytes: Uint8List.fromList(utf8.encode(csv)),
    ext: 'csv',
    mimeType: MimeType.csv,
  );
}

// استدعِ هذه الدالة من زر "تصدير" في الواجهة
