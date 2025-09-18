import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_form_provider.dart'; // <-- استيراد الـ Provider الجديد

class AddBookingScreen extends ConsumerWidget {
  const AddBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- قراءة الحالة والـ Notifier ---
    final formState = ref.watch(bookingFormProvider);
    final formNotifier = ref.read(bookingFormProvider.notifier);
    final controllers = formNotifier.controllers; // الوصول إلى وحدات التحكم

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حجز جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // ...
          child: Column(
            children: [
              // مثال: حقل اختيار العميل
              DropdownButtonFormField<Customer>(
                value: formState.selectedCustomer, // اقرأ القيمة من الحالة
                onChanged: (customer) {
                  // استدعِ الدالة من الـ Notifier لتحديث الحالة
                  formNotifier.updateCustomer(customer);
                },
                // ...
              ),

              // مثال: زر اختيار التاريخ
              TextFormField(
                // ...
                onTap: () => formNotifier.pickEventDate(context), // استدعِ الدالة مباشرة
              ),

              // مثال: زر الحفظ
              ElevatedButton(
                onPressed: formState.isLoading ? null : () async {
                  if (await formNotifier.saveBooking()) {
                    // تم الحفظ بنجاح
                    if (context.mounted) Navigator.of(context).pop();
                  } else {
                    // فشل الحفظ
                  }
                },
                child: formState.isLoading ? const CircularProgressIndicator() : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// في AddBookingScreen، داخل دالة build

ElevatedButton.icon(
  onPressed: formState.isLoading ? null : () async {
    // --- [التحسين هنا] ---
    // استدعِ دالة الحفظ وانتظر النتيجة
    final errorMessage = await formNotifier.saveBooking();

    // تحقق من النتيجة بعد انتهاء العملية
    if (context.mounted) {
      if (errorMessage == null) {
        // نجحت العملية: اعرض رسالة نجاح واخرج من الشاشة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الحجز بنجاح!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        // فشلت العملية: اعرض رسالة الخطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  },
  // ... (بقية خصائص الزر)
),
// في AddBookingScreen، داخل SectionTemplate 'البيانات الأساسية'

// ... (بعد حقل نوع الحفلة)

// --- [التحسين هنا] ---
// Dropdown لاختيار العامل المسؤول عن التركيب
// (ستحتاج إلى جلب قائمة المستخدمين من provider آخر)
DropdownButtonFormField<User>(
  // ...
  onChanged: (user) {
    if (user != null) {
      formNotifier.selectInstallationStaff(user.name);
    }
  },
  // ...
),

// زر لتسجيل وقت التركيب
TextButton.icon(
  icon: const Icon(Icons.timer_outlined),
  label: const Text('تسجيل وقت التركيب الآن'),
  onPressed: () {
    formNotifier.setInstallationTimestamp();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل وقت التركيب الحالي.')),
    );
  },
)
