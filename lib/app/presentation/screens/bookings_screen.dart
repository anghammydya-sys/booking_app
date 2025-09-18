import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/database_providers.dart';
import '../widgets/booking_list_tile.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'الكل';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إنشاء كائن الفلترة بناءً على الحالة المحلية
    final filter = BookingsFilter(
      searchTerm: _searchController.text,
      filter: _activeFilter == 'الكل' ? null : _activeFilter,
    );
    // استدعاء الـ Provider.family مع كائن الفلترة
    final bookingsAsyncValue = ref.watch(bookingsStreamProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- شريط البحث والفلترة ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'بحث برقم الحجز، اسم العميل...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => setState(() {}), // إعادة بناء الواجهة عند كل تغيير
                ),
                const SizedBox(height: 10),
                // أزرار الفلترة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['الكل', 'اليوم', 'مؤجل'].map((filterName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(filterName),
                          selected: _activeFilter == filterName,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _activeFilter = filterName);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // --- قائمة النتائج ---
          Expanded(
            child: bookingsAsyncValue.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Center(child: Text('لا توجد حجوزات تطابق البحث.'));
                }
                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return GestureDetector(
                      onTap: () => context.push('/booking/${booking.id}'),
                      child: BookingListTile(booking: booking),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-booking'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
