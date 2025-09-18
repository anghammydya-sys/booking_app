import 'dart:async';
import 'dart:convert'; // For utf8
import 'package:crypto/crypto.dart'; // For sha256
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// --- [تصحيح] استيراد كل النماذج المستخدمة ---
import '../data/models/booking.dart';
import '../data/models/customer.dart';
import '../data/models/inventory_item.dart';
import '../data/models/lost_item.dart';
import '../data/models/lost_item_action.dart';
import '../data/models/media_item.dart';
import '../data/models/payment.dart';
import '../data/models/user.dart';
import '../data/models/venue.dart';


class SembastService {
  static const String DB_NAME = 'booking_system.db';
  late Database _db;

  // --- تعريف كل المخازن مرة واحدة فقط ---
  final _customerStore = intMapStoreFactory.store('customers');
  final _venueStore = intMapStoreFactory.store('venues');
  final _inventoryItemStore = intMapStoreFactory.store('inventoryItems');
  final _bookingStore = intMapStoreFactory.store('bookings');
  final _paymentStore = intMapStoreFactory.store('payments');
  final _lostItemStore = intMapStoreFactory.store('lostItems');
  final _lostItemActionStore = intMapStoreFactory.store('lostItemActions');
  final _userStore = intMapStoreFactory.store('users');
  final _mediaStore = intMapStoreFactory.store('mediaItems');
  final _countersStore = StoreRef<String, int>.main();

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, DB_NAME);
    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  // --- دوال العملاء (Customers) ---
  Future<int> addCustomer(Customer customer) async => await _customerStore.add(_db, customer.toSembast());
  Future<int> updateCustomer(Customer customer) async => await _customerStore.record(customer.id!).update(_db, customer.toSembast());
  Future<int> deleteCustomer(int id) async => await _customerStore.record(id).delete(_db);
  Stream<List<Customer>> watchCustomers() {
    return _customerStore.query(finder: Finder(sortOrders: [SortOrder('name')]))
        .onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => Customer.fromSembast(s.value)..id = s.key).toList());
  }
  Future<Customer?> getCustomerById(int id) async {
    final record = await _customerStore.record(id).get(_db);
    return record != null ? (Customer.fromSembast(record)..id = id) : null;
  }

  // --- دوال المستخدمين (Users) ---
  Future<int> addUser(User user) async => await _userStore.add(_db, user.toSembast());
  Future<int> deleteUser(int id) async => await _userStore.record(id).delete(_db);
  Stream<List<User>> watchUsers() {
    return _userStore.query().onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => User.fromSembast(s.value)..id = s.key).toList());
  }
  Future<User?> authenticateUser(String username, String plainPassword) async {
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    final passwordHash = digest.toString();
    final finder = Finder(filter: Filter.and([
      Filter.equals('username', username),
      Filter.equals('passwordHash', passwordHash),
    ]));
    final record = await _userStore.findFirst(_db, finder: finder);
    if (record != null) {
      return User.fromSembast(record.value)..id = record.key;
    }
    return null;
  }

  // --- دوال الحجوزات (Bookings) ---
  Future<int> addBooking(Booking booking) async => await _bookingStore.add(_db, booking.toSembast());
  Future<int> updateBooking(Booking booking) async => await _bookingStore.record(booking.id!).update(_db, booking.toSembast());
  Future<Booking?> getBookingById(int id) async {
    final record = await _bookingStore.record(id).get(_db);
    return record != null ? (Booking.fromSembast(record)..id = id) : null;
  }
  Stream<List<Booking>> watchBookings() {
    return _bookingStore.query(finder: Finder(sortOrders: [SortOrder('eventDate', false)]))
        .onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => Booking.fromSembast(s.value)..id = s.key).toList());
  }
  Stream<List<Booking>> watchSubBookings(int parentId) {
    final finder = Finder(filter: Filter.equals('parentBookingId', parentId));
    return _bookingStore.query(finder: finder).onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => Booking.fromSembast(s.value)..id = s.key).toList());
  }
  Future<void> updateBookingStatus(int bookingId, String newStatus) async {
    await _bookingStore.record(bookingId).update(_db, {'status': newStatus});
  }
  Future<bool> checkVenueAvailability({required DateTime eventDate, required String venueName}) async {
    if (venueName.isEmpty) return true;
    final finder = Finder(filter: Filter.and([
      Filter.equals('venueName', venueName),
      Filter.equals('eventDate', eventDate.millisecondsSinceEpoch),
    ]));
    final existing = await _bookingStore.findFirst(_db, finder: finder);
    return existing == null;
  }

  // --- دوال الدفعات (Payments) ---
  Future<int> addPayment(Payment payment) async => await _paymentStore.add(_db, payment.toSembast());
  Stream<List<Payment>> watchPaymentsForBooking(int bookingId) {
    final finder = Finder(filter: Filter.equals('bookingId', bookingId));
    return _paymentStore.query(finder: finder).onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => Payment.fromSembast(s.value)..id = s.key).toList());
  }

  // --- دوال المفقودات (Lost Items) ---
  Future<int> addLostItem(LostItem item) async => await _lostItemStore.add(_db, item.toSembast());
  Future<int> updateLostItem(LostItem item) async => await _lostItemStore.record(item.id!).update(_db, item.toSembast());
  Stream<List<LostItem>> watchAllLostItems() {
    final finder = Finder(sortOrders: [SortOrder('reportedAt', false)]);
    return _lostItemStore.query(finder: finder).onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => LostItem.fromSembast(s.value)..id = s.key).toList());
  }

  // --- دوال إجراءات المفقودات (Lost Item Actions) ---
  Future<int> addLostItemAction(LostItemAction action) async => await _lostItemActionStore.add(_db, action.toSembast());
  Stream<List<LostItemAction>> watchActionsForLostItem(int lostItemId) {
    final finder = Finder(filter: Filter.equals('lostItemId', lostItemId));
    return _lostItemActionStore.query(finder: finder).onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => LostItemAction.fromSembast(s.value)..id = s.key).toList());
  }

  // --- دوال الوسائط (Media) ---
  Future<int> addMediaItem(MediaItem item) async => await _mediaStore.add(_db, item.toSembast());
  Stream<List<MediaItem>> watchMediaItems() {
    return _mediaStore.query().onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => MediaItem.fromSembast(s.value)..id = s.key).toList());
  }

  // --- دالة الترقيم التلقائي ---
  Future<String> getNextBookingNumber(String typeCode) async {
    final nextNumber = await _db.transaction((txn) async {
      int currentNumber = await _countersStore.record(typeCode).get(txn) ?? 0;
      currentNumber++;
      await _countersStore.record(typeCode).put(txn, currentNumber);
      return currentNumber;
    });
    final formattedNumber = nextNumber.toString().padLeft(3, '0');
    return '$typeCode-$formattedNumber';
  }

  // --- دوال التقارير ---
  Future<List<Booking>> getFilteredBookings(Map<String, dynamic> filters) async {
    List<Filter> activeFilters = [];
    if (filters['startDate'] != null) {
      activeFilters.add(Filter.greaterThanOrEquals('eventDate', (filters['startDate'] as DateTime).millisecondsSinceEpoch));
    }
    if (filters['endDate'] != null) {
      activeFilters.add(Filter.lessThanOrEquals('eventDate', (filters['endDate'] as DateTime).millisecondsSinceEpoch));
    }
    if (filters['eventType'] != null) {
      activeFilters.add(Filter.equals('eventType', filters['eventType']));
    }
    if (filters['status'] != null) {
      activeFilters.add(Filter.equals('status', filters['status']));
    }
    
    final finder = activeFilters.isNotEmpty ? Finder(filter: Filter.and(activeFilters)) : Finder();
    final snapshots = await _bookingStore.find(_db, finder: finder);
    return snapshots.map((s) => Booking.fromSembast(s.value)..id = s.key).toList();
  }
  
  // --- [إكمال الناقص] دوال CRUD لبقية النماذج ---
  Future<int> addVenue(Venue venue) async => await _venueStore.add(_db, venue.toSembast());
  Stream<List<Venue>> watchVenues() {
    return _venueStore.query().onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => Venue.fromSembast(s.value)..id = s.key).toList());
  }
  
  Future<int> addInventoryItem(InventoryItem item) async => await _inventoryItemStore.add(_db, item.toSembast());
  Stream<List<InventoryItem>> watchInventoryItems() {
    return _inventoryItemStore.query().onSnapshots(_db)
        .map((snapshots) => snapshots.map((s) => InventoryItem.fromSembast(s.value)..id = s.key).toList());
  }
  // ... (يمكنك إضافة getFilteredLostItems و getFilteredPayments بنفس الطريقة)
}
