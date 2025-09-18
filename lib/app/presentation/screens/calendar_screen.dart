import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/booking.dart';
import '../providers/database_providers.dart';
import '../widgets/booking_list_tile.dart'; // سنعيد استخدام هذه الويدجت

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Booking> _selectedDayBookings = [];

  // دالة لتحميل الحجوزات وربطها بالتقويم
  Map<DateTime, List<Booking>> _groupBookingsByDay(List<Booking> bookings) {
    Map<DateTime, List<Booking>> events = {};
    for (var booking in bookings) {
      // تجاهل الوقت، استخدم التاريخ فقط
      DateTime date = DateTime(booking.eventDate.year, booking.eventDate.month, booking.eventDate.day);
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(booking);
    }
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // تحديث قائمة الحجوزات لليوم المحدد
        final allBookings = ref.read(bookingsStreamProvider).asData?.value ?? [];
        final events = _groupBookingsByDay(allBookings);
        _selectedDayBookings = events[selectedDay] ?? [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقويم الحجوزات'),
        centerTitle: true,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final events = _groupBookingsByDay(bookings);

          // تحديث القائمة عند إعادة بناء الواجهة
          if (_selectedDay != null) {
            _selectedDayBookings = events[_selectedDay] ?? [];
          }

          return Column(
            children: [
              TableCalendar<Booking>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                locale: 'ar_SA', // <-- تفعيل اللغة العربية
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) {
                  return events[day] ?? []; // عرض علامات على الأيام التي بها حجوزات
                },
                calendarStyle: const CalendarStyle(
                  // تخصيص شكل علامات الأحداث
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // إخفاء زر تغيير التنسيق (أسبوع/شهر)
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 8.0),
              // --- عرض حجوزات اليوم المحدد ---
              Expanded(
                child: _selectedDayBookings.isEmpty
                    ? const Center(child: Text('لا توجد حجوزات في هذا اليوم.'))
                    : ListView.builder(
                        itemCount: _selectedDayBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _selectedDayBookings[index];
                          return BookingListTile(booking: booking);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}
