import 'package:booking_system/app/data/models/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/service_locator.dart';
import '../../services/sembast_service.dart';
import '../../data/models/customer.dart';
import '../../data/models/booking.dart';
import '../../data/models/venue.dart';
import '../../data/models/inventory_item.dart';

// 1. مزود للوصول إلى خدمة Sembast
// هذا الـ Provider يطلب خدمة Sembast التي سجلناها في GetIt.
final sembastServiceProvider = Provider<SembastService>((ref) {
  return locator<SembastService>();
});

// 2. مزودات لمراقبة البيانات باستخدام Streams من SembastService
// StreamProvider يستمع إلى المجرى (Stream) الذي توفره خدمتنا ويعيد بناء الواجهة عند تغير البيانات.
final subBookingsProvider = StreamProvider.family<List<Booking>, int>((ref, parentId) {
  final sembastService = ref.watch(sembastServiceProvider);
  // سنحتاج إلى دالة جديدة في SembastService
  return sembastService.watchSubBookings(parentId); 
});
// في database_providers.dart

// --- [جديد] تعريف العميل الوهمي ككائن ثابت ---
final Customer addNewCustomerOption = Customer(id: -1, name: 'إضافة عميل جديد...', phone: '');

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  
  // استمع إلى المجرى الأصلي
  return sembastService.watchCustomers().map((customers) {
    // قم بإنشاء قائمة جديدة وأضف الخيار الوهمي في البداية
    return [addNewCustomerOption, ...customers];
  });
});

final bookingsStreamProvider = StreamProvider<List<Booking>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  
  // --- [نقطة تفتيش 1] ---
  // استمع إلى الـ snapshots الخام من Sembast
  return sembastService.watchBookingsRaw().map((snapshots) {
    
    // --- [نقطة تفتيش 2] ---
    print('--- [PROVIDER] Received ${snapshots.length} raw snapshots from Sembast ---');
    
    List<Booking> bookings = [];
    for (var snapshot in snapshots) {
      try {
        // --- [نقطة تفتيش 3] ---
        // طباعة كل سجل قبل محاولة تحويله
        print('[PROVIDER] Processing record key: ${snapshot.key}, value: ${snapshot.value}');
        
        final booking = Booking.fromSembast(snapshot.value);
        booking.id = snapshot.key;
        bookings.add(booking);
        
        // --- [نقطة تفتيش 4] ---
        print('[PROVIDER] Successfully converted record key: ${snapshot.key}');

      } catch (e, stackTrace) {
        // --- [نقطة تفتيش 5] ---
        // هذا هو الجزء الأهم: هل فشلت عملية التحويل؟
        print('--- !!! [PROVIDER] ERROR converting record key: ${snapshot.key} !!! ---');
        print('Error: $e');
        print('StackTrace: $stackTrace');
        print('Problematic data: ${snapshot.value}');
        print('--------------------------------------------------------------------');
      }
    }
    
    // --- [نقطة تفتيش 6] ---
    print('[PROVIDER] Finished processing. Total successful bookings: ${bookings.length}');
    return bookings;
  });
});

final venuesStreamProvider = StreamProvider<List<Venue>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  // استمع إلى مجرى القاعات
  return sembastService.watchVenues();
});

final inventoryItemsStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  // استمع إلى مجرى أصناف المخزون
  return sembastService.watchInventoryItems();
});
final paymentsForBookingProvider = StreamProvider.family<List<Payment>, int>((ref, bookingId) {
  final sembastService = ref.watch(sembastServiceProvider);
  return sembastService.watchPaymentsForBooking(bookingId);
});
// في database_providers.dart

// أضف هذا المزود في نهاية الملف
final lostItemsStreamProvider = StreamProvider<List<LostItem>>((ref) {
  final sembastService = ref.watch(sembastServiceProvider);
  return sembastService.watchAllLostItems();
});
// في database_providers.dart

// ... (بعد lostItemsStreamProvider)

// --- [جديد] مزود لجلب بيانات عميل واحد باستخدام الـ ID ---
// .family يسمح لنا بتمرير قيمة (id العميل) إليه
final customerByIdProvider = FutureProvider.family<Customer?, int>((ref, customerId) {
  final sembastService = ref.watch(sembastServiceProvider);
  return sembastService.getCustomerById(customerId);
});


