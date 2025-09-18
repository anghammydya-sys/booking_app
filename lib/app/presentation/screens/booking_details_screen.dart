import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';
import '../../data/models/customer.dart';
import '../../data/models/payment.dart';
import '../providers/database_providers.dart';
import '../widgets/payments_section.dart';
import '../../core/helpers/messaging_helper.dart';



// Provider لجلب تفاصيل الحجز والعميل
final bookingDetailsProvider = FutureProvider.autoDispose.family<({Booking booking, Customer? customer}), int>((ref, bookingId) async {
  final sembastService = ref.watch(sembastServiceProvider);
  final booking = await sembastService.getBookingById(bookingId);
  if (booking == null) throw Exception('لم يتم العثور على الحجز');
  final customer = await sembastService.getCustomerById(booking.customerId);
  return (booking: booking, customer: customer);
});

// Provider لمراقبة دفعات حجز معين
final paymentsStreamProvider = StreamProvider.autoDispose.family<List<Payment>, int>((ref, bookingId) {
  final sembastService = ref.watch(sembastServiceProvider);
  return sembastService.watchPaymentsForBooking(bookingId);
});

class BookingDetailsScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  // --- [تصحيح] دالة إضافة الدفعة ---
  void _showAddPaymentDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة دفعة جديدة'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'المبلغ', prefixIcon: Icon(Icons.monetization_on)),
              validator: (value) {
                if (value == null || value.isEmpty) return 'الرجاء إدخال المبلغ';
                if (double.tryParse(value) == null) return 'الرجاء إدخال رقم صحيح';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  // --- [تصحيح] استخدام الحقول الصحيحة لـ Payment ---
                  final newPayment = Payment(
                    bookingId: bookingId,
                    amount: amount,
                    paidAt: DateTime.now(), // استخدام 'paidAt'
                    method: 'كاش',          // إضافة 'method'
                  );

                  final sembastService = ref.read(sembastServiceProvider);
                  await sembastService.addPayment(newPayment);

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة الدفعة'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(bookingDetailsProvider(bookingId));
    final paymentsAsync = ref.watch(paymentsStreamProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحجز'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            onPressed: () => _showAddPaymentDialog(context, ref),
            tooltip: 'إضافة دفعة',
          )
        ],
      ),
      body: detailsAsync.when(
        data: (data) {
          final booking = data.booking;
          final customer = data.customer;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildDetailCard('بيانات الحجز', [
                _buildDetailRow('رقم الحجز:', booking.bookingNumber),
                _buildDetailRow('تاريخ الحفلة:', DateFormat.yMMMMEEEEd('ar').format(booking.eventDate)),
                _buildDetailRow('الحالة:', booking.status, statusColor: _getStatusColor(booking.status)),
              ]),
              const SizedBox(height: 16),
              _buildDetailCard('بيانات العميل', [
                _buildDetailRow('اسم العميل:', customer?.name ?? 'غير متوفر'),
                _buildDetailRow('رقم الهاتف:', customer?.phone ?? 'غير متوفر'),
              ]),
              const SizedBox(height: 16),
              paymentsAsync.when(
                data: (payments) {
                  final double totalPaid = payments.fold(0.0, (sum, item) => sum + item.amount);
                  final double remaining = booking.totalAmount - totalPaid;

                  return _buildDetailCard('البيانات المالية', [
                    _buildDetailRow('المبلغ الإجمالي:', '${booking.totalAmount.toStringAsFixed(2)} ريال', isAmount: true),
                    // --- [تصحيح] خطأ مطبعي في اسم الدالة ---
                    _buildDetailRow('المبلغ المدفوع:', '${totalPaid.toStringAsFixed(2)} ريال', isAmount: true, color: Colors.green),
                    _buildDetailRow('المبلغ المتبقي:', '${remaining.toStringAsFixed(2)} ريال', isAmount: true, color: Colors.red),
                    const Divider(height: 24),
                    const Text('سجل الدفعات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (payments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('لا توجد دفعات مسجلة.', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...payments.map((p) => ListTile(
                            leading: const Icon(Icons.payment, color: Colors.grey),
                            title: Text('مبلغ: ${p.amount.toStringAsFixed(2)} ريال'),
                            // --- [تصحيح] استخدام 'paidAt' بدلاً من 'paymentDate' ---
                            subtitle: Text('بتاريخ: ${DateFormat.yMMMd('ar').format(p.paidAt)}'),
                          )).toList(),
                  ]);
                  Consumer(
  builder: (context, ref, child) {
    final subBookingsAsync = ref.watch(subBookingsProvider(booking.id!));
    return subBookingsAsync.when(
      data: (subBookings) {
        if (subBookings.isEmpty) {
          return const SizedBox.shrink(); // لا تعرض شيئًا إذا كانت فارغة
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              const ListTile(
                title: Text('الحجوزات الفرعية المرتبطة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...subBookings.map((sub) => BookingListTile(booking: sub)),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('خطأ: $err'),
    );
  },
),
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('خطأ في تحميل الدفعات: $err'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  // --- [تصحيح] تضمين الدوال المساعدة بالكامل ---
  // في booking_details_screen.dart

// ... (داخل كلاس BookingDetailsScreen)

Widget _buildDetailsCard(Booking booking) {
  // --- [التحسين هنا] ---
  // استخدام Consumer للوصول إلى ref
  return Consumer(
    builder: (context, ref, child) {
      // 1. مراقبة حالة جلب العميل باستخدام الـ ID من الحجز
      final customerAsync = ref.watch(customerByIdProvider(booking.customerId));

      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تفاصيل الحجز الأساسية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              
              // 2. استخدام .when للتعامل مع حالات جلب العميل (loading, data, error)
              customerAsync.when(
                data: (customer) {
                  // 3. عرض اسم العميل بدلاً من الـ ID
                  return _buildDetailRow(
                    'اسم العميل:',
                    customer?.name ?? 'غير متوفر', // عرض الاسم، أو نص بديل
                    icon: Icons.person_outline,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildDetailRow('اسم العميل:', 'خطأ في التحميل'),
              ),
              
              _buildDetailRow(
                'رقم الحجز:',
                booking.bookingNumber,
                icon: Icons.confirmation_number_outlined,
              ),
              _buildDetailRow(
                'تاريخ الحفلة:',
                DateFormat.yMMMEd('ar').format(booking.eventDate),
                icon: Icons.calendar_today_outlined,
              ),
              _buildDetailRow(
                'نوع الحفلة:',
                booking.eventType,
                icon: Icons.celebration_outlined,
              ),
              _buildDetailRow(
                'الحالة:',
                booking.status,
                icon: Icons.info_outline,
                statusColor: _getStatusColor(booking.status),
              ),
              // في booking_details_screen.dart، داخل Column في _buildDetailsCard

// ... (بعد عرض كل التفاصيل)
const SizedBox(height: 16),
Center(
  child: ElevatedButton.icon(
    onPressed: () async {
      // جلب بيانات العميل مرة أخرى
      final customer = await ref.read(customerByIdProvider(booking.customerId).future);
      if (customer != null) {
        // إنشاء نص الرسالة
        final message = 'مرحباً ${customer.name}، نود تذكيركم بموعد حجزكم بتاريخ ${DateFormat.yMMMEd('ar').format(booking.eventDate)}.';
        
        try {
          // إرسال الرسالة
          await MessagingHelper.sendWhatsApp(customer.phone, message);
        } catch (e) {
          // عرض رسالة خطأ إذا فشل الإرسال
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لا يمكن فتح واتساب. تأكد من أنه مثبت على الجهاز.')),
          );
        }
      }
    },
    icon: const Icon(Icons.send_outlined),
    label: const Text('إرسال تذكير واتساب'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
  ),
),

            ],
          ),
        ),
      );
    },
  );
}

// ... (بقية دوال الكلاس مثل _buildDetailRow و _getStatusColor تبقى كما هي)


  Widget _buildDetailRow(String label, String value, {Color? statusColor, bool isAmount = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: color ?? statusColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'جاهز': return Colors.green;
      case 'مؤجل': return Colors.red;
      default: return Colors.orange;
    }
  }
}
// في booking_details_screen.dart، داخل دالة build

// أولاً، اقرأ المستخدم الحالي
final currentUser = ref.watch(authStateProvider);

return Scaffold(
  appBar: AppBar(
    title: const Text('تفاصيل الحجز'),
    // --- [التحسين الأمني هنا] ---
    actions: [
      // اعرض زر الحذف فقط إذا كان المستخدم مديرًا
      if (currentUser != null && currentUser.role == 'admin')
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'حذف الحجز',
          onPressed: () async {
            // عرض رسالة تأكيد قبل الحذف
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: const Text('هل أنت متأكد من رغبتك في حذف هذا الحجز بشكل نهائي؟ لا يمكن التراجع عن هذا الإجراء.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );

            // إذا أكد المستخدم، قم بتنفيذ الحذف
            if (confirm == true && context.mounted) {
              final sembastService = ref.read(sembastServiceProvider);
              await sembastService.deleteBooking(bookingId); // bookingId من الشاشة
              // العودة إلى الشاشة السابقة بعد الحذف
              context.pop();
            }
          },
        ),
    ],
  ),
  body: // ... (بقية الواجهة)
);
// في booking_details_screen.dart

// ... داخل دالة build ...
// ... بعد جلب بيانات الحجز booking ...

// مثال: عرض تفاصيل "استند ذهب" مع الصورة
if (booking.goldStandNotes != null && booking.goldStandNotes!.isNotEmpty)
  _buildDetailRowWithImage(
    icon: Icons.star,
    title: 'استند ذهب',
    value: booking.goldStandNotes!,
    imagePath: booking.goldStandImagePath, // مرر مسار الصورة
  ),

// ... (كرر نفس المنطق لبقية الخدمات مثل زينة الممر والدرج)
// في booking_details_screen.dart

Widget _buildDetailRowWithImage({
  required IconData icon,
  required String title,
  required String value,
  String? imagePath, // مسار الصورة اختياري
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 36),
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
        // --- [التحسين البصري هنا] ---
        // اعرض الصورة فقط إذا كان المسار موجودًا
        if (imagePath != null && imagePath.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 36),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath), // تأكد من استيراد 'dart:io'
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    ),
  );
}
// في booking_details_screen.dart، داخل قسم الحسابات

// ...

// --- [التحسين البصري هنا] ---
const SizedBox(height: 10),
// حساب النسبة المئوية للمدفوعات
final double progress = (booking.totalAmount > 0) 
    ? (booking.paidAmount / booking.totalAmount) 
    : 0.0;

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: LinearProgressIndicator(
    value: progress,
    minHeight: 10,
    backgroundColor: Colors.grey.shade300,
    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
    borderRadius: BorderRadius.circular(5),
  ),
),
const SizedBox(height: 10),

// عرض الأرقام (الإجمالي، المدفوع، المتبقي)
_buildFinancialRow('المبلغ الإجمالي:', '${booking.totalAmount.toStringAsFixed(2)} ريال'),
_buildFinancialRow('المبلغ المدفوع:', '${booking.paidAmount.toStringAsFixed(2)} ريال', color: Colors.green),
_buildFinancialRow('المبلغ المتبقي:', '${booking.remainingAmount.toStringAsFixed(2)} ريال', color: Colors.red),

// ...
