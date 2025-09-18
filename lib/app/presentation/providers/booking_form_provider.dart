import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking.dart';
import '../../data/models/customer.dart';
import '../../services/sembast_service.dart';
import 'database_providers.dart';

// --- 1. كلاس الحالة (State) ---
// هذا الكلاس سيحتوي على كل متغيرات الحالة للنموذج في مكان واحد.
@immutable // يعني أن هذه الحالة لا يمكن تغييرها مباشرة، بل يجب إنشاء نسخة جديدة.
class BookingFormState {
  // متغيرات الحالة الأساسية
  final Customer? selectedCustomer;
  final DateTime? selectedEventDate;
  final String selectedEventType;
  final String selectedStatus;
  final bool isLoading;
  final String? suggestedBookingNumber;

  // متغيرات حالة الديكور (مثال)
  final String? selectedDecorType;
  final int daysCount;
  
  // ... يمكنك إضافة كل متغيرات الحالة الأخرى هنا ...

  // الـ Constructor
  const BookingFormState({
    this.selectedCustomer,
    this.selectedEventDate,
    this.selectedEventType = 'نساء',
    this.selectedStatus = 'جاري',
    this.isLoading = false,
    this.suggestedBookingNumber,
    this.selectedDecorType,
    this.daysCount = 1,
  });

  // دالة لإنشاء نسخة جديدة من الحالة مع تغيير بعض القيم
  BookingFormState copyWith({
    Customer? selectedCustomer,
    DateTime? selectedEventDate,
    String? selectedEventType,
    bool? isLoading,
    String? suggestedBookingNumber,
    String? selectedDecorType,
    int? daysCount,
  }) {
    return BookingFormState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      selectedEventDate: selectedEventDate ?? this.selectedEventDate,
      selectedEventType: selectedEventType ?? this.selectedEventType,
      isLoading: isLoading ?? this.isLoading,
      suggestedBookingNumber: suggestedBookingNumber ?? this.suggestedBookingNumber,
      selectedDecorType: selectedDecorType ?? this.selectedDecorType,
      daysCount: daysCount ?? this.daysCount,
    );
  }
}

// --- 2. الـ Notifier (العقل المدبر) ---
class BookingFormNotifier extends StateNotifier<BookingFormState> {
  final SembastService _sembastService;
  
  // وحدات التحكم لا تزال هنا لأنها مرتبطة بالواجهة بشكل مباشر
  final Map<String, TextEditingController> controllers = {
    'bookingNumber': TextEditingController(),
    'generalNotes': TextEditingController(),
    'totalAmount': TextEditingController(),
    'venueName': TextEditingController(),
    // ... أضف كل وحدات التحكم هنا
  };

  BookingFormNotifier(this._sembastService) : super(const BookingFormState());

  // --- دوال لتحديث الحالة ---
  void updateCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void updateEventType(String eventType) {
    state = state.copyWith(selectedEventType: eventType, selectedDecorType: null); // إعادة تعيين
    generateBookingNumber();
  }
  
  void updateDecorType(String? decorType) {
    state = state.copyWith(selectedDecorType: decorType);
    generateBookingNumber();
  }

  // --- دوال منطق العمل ---
  Future<void> pickEventDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      state = state.copyWith(selectedEventDate: pickedDate);
    }
  }

  Future<void> generateBookingNumber() async {
    // ... (نفس منطق توليد الرقم الذي كتبناه سابقًا)
    // لكن بدلاً من setState، استخدم state = state.copyWith(...)
    // مثال:
    // final bookingNumber = await _sembastService.getNextBookingNumber(typeCode);
    // state = state.copyWith(suggestedBookingNumber: bookingNumber);
  }

  Future<bool> saveBooking() async {
    state = state.copyWith(isLoading: true);
    // ... (منطق الحفظ الكامل)
    // استخدم state.selectedCustomer بدلاً من _selectedCustomer
    // وفي النهاية:
    // state = state.copyWith(isLoading: false);
    // return true; or false;
    return true; // كمثال
  }

  @override
  void dispose() {
    // التخلص من كل وحدات التحكم
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}

// --- 3. الـ Provider ---
// هذا هو الـ Provider الذي ستستخدمه الواجهة للتفاعل مع الـ Notifier
final bookingFormProvider = StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  return BookingFormNotifier(sembastService);
});
// في دالة saveBooking داخل BookingFormNotifier

final newBooking = Booking(
  // ... (البيانات السابقة)
  goldStandImagePath: state.goldStandImagePath, // اقرأ المسار من الحالة
  // ... (أضف بقية مسارات الصور)
);
// في BookingFormState
final bool hasBookingConflict;

// في الـ constructor
const BookingFormState({
  // ...
  this.hasBookingConflict = false,
});

// في copyWith
BookingFormState copyWith({
  // ...
  bool? hasBookingConflict,
}) {
  return BookingFormState(
    // ...
    hasBookingConflict: hasBookingConflict ?? this.hasBookingConflict,
  );
}
// في BookingFormNotifier

// دالة جديدة للتحقق
Future<void> _checkForConflict() async {
  // لا تقم بالتحقق إذا كانت البيانات الأساسية غير مكتملة
  if (state.selectedEventDate == null || controllers['venueName']!.text.isEmpty) {
    state = state.copyWith(hasBookingConflict: false); // إعادة تعيين حالة التعارض
    return;
  }

  final isAvailable = await _sembastService.checkVenueAvailability(
    eventDate: state.selectedEventDate!,
    venueName: controllers['venueName']!.text,
  );

  // تحديث الحالة بناءً على النتيجة
  state = state.copyWith(hasBookingConflict: !isAvailable);
}

// الآن، قم باستدعاء هذه الدالة عند تغيير البيانات
@override
Future<void> pickEventDate(BuildContext context) async {
  // ... (نفس الكود السابق)
  if (pickedDate != null) {
    state = state.copyWith(selectedEventDate: pickedDate);
    await _checkForConflict(); // <-- استدعِ التحقق هنا
  }
}

// وأيضًا، نحتاج إلى مستمع (listener) لوحدة تحكم اسم الصالة
@override
void dispose() {
  controllers['venueName']!.removeListener(_checkForConflict); // لا تنسَ إزالته
  // ...
  super.dispose();
}

// في الـ constructor الخاص بـ BookingFormNotifier
BookingFormNotifier(this._sembastService) : super(const BookingFormState()) {
  controllers['venueName']!.addListener(_checkForConflict); // <-- أضف المستمع هنا
}
// في BookingFormNotifier

// --- [التحسين هنا] ---
// الدالة سترجع الآن Future<String?>
// سترجع null إذا نجحت، أو رسالة الخطأ إذا فشلت.
Future<String?> saveBooking() async {
  // لا تقم بالحفظ إذا كانت البيانات الأساسية غير مكتملة
  if (state.selectedCustomer == null || state.selectedEventDate == null) {
    return 'الرجاء اختيار العميل وتاريخ الحفلة أولاً.';
  }
  
  state = state.copyWith(isLoading: true);

  try {
    // --- 1. تجميع البيانات ---
    // (هذا الجزء يبقى كما هو)
    final newBooking = Booking(
      // ... كل بيانات الحجز
    );

    // --- 2. محاولة الحفظ في قاعدة البيانات ---
    await _sembastService.addBooking(newBooking);

    // --- 3. إذا نجح كل شيء، أعد null ---
    state = state.copyWith(isLoading: false);
    return null; // يعني نجاح العملية

  } on DatabaseException catch (e) {
    // --- 4. التعامل مع أخطاء قاعدة البيانات ---
    // هذا الخطأ قد يحدث إذا كان هناك مشكلة في الكتابة على القرص
    print('Database Error on saveBooking: $e'); // للمطور
    state = state.copyWith(isLoading: false);
    return 'حدث خطأ في قاعدة البيانات. الرجاء المحاولة مرة أخرى.'; // للمستخدم

  } catch (e) {
    // --- 5. التعامل مع أي خطأ آخر غير متوقع ---
    print('Unexpected Error on saveBooking: $e'); // للمطور
    state = state.copyWith(isLoading: false);
    return 'حدث خطأ غير متوقع. الرجاء إبلاغ الدعم الفني.'; // للمستخدم
  }
}
