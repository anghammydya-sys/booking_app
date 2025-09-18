import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/payment.dart';
import '../providers/database_providers.dart';
import 'add_payment_dialog.dart';


class PaymentsSection extends ConsumerWidget {
  final int bookingId;
  final double totalAmount;

  const PaymentsSection({
    super.key,
    required this.bookingId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة الدفعات الخاصة بهذا الحجز
    final paymentsAsync = ref.watch(paymentsForBookingProvider(bookingId));

    return paymentsAsync.when(
      data: (payments) {
        // حساب المبالغ
        final double paidAmount = payments.fold(0, (sum, item) => sum + item.amount);
        final double remainingAmount = totalAmount - paidAmount;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الحالة المالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSummaryRow('المبلغ الإجمالي:', '${totalAmount.toStringAsFixed(2)} ريال'),
                _buildSummaryRow('المبلغ المدفوع:', '${paidAmount.toStringAsFixed(2)} ريال', color: Colors.green),
                _buildSummaryRow('المبلغ المتبقي:', '${remainingAmount.toStringAsFixed(2)} ريال', color: Colors.red),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سجل الدفعات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AddPaymentDialog(
  bookingId: bookingId,
  bookingNumber: booking.bookingNumber, // <-- مرر رقم الحجز
  customerName: customer.name, // <-- مرر اسم العميل
);
    },
  );
                        print('إضافة دفعة جديدة للحجز رقم: $bookingId');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة دفعة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // عرض قائمة الدفعات
                if (payments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('لا توجد دفعات مسجلة.')),
                  )
                else
                  ...payments.map((payment) => ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text('مبلغ: ${payment.amount.toStringAsFixed(2)} ريال'),
                        subtitle: Text('بتاريخ: ${DateFormat.yMMMd('ar').format(payment.paidAt)}\nالطريقة: ${payment.method}'),
                        isThreeLine: true,
                      )),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('خطأ في تحميل الدفعات: $err'),
    );
  }

  Widget _buildSummaryRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
