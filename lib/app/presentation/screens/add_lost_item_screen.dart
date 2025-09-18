import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/booking.dart';
import '../../data/models/lost_item.dart';
import '../providers/database_providers.dart';

class AddLostItemScreen extends ConsumerStatefulWidget {
  const AddLostItemScreen({super.key});

  @override
  ConsumerState<AddLostItemScreen> createState() => _AddLostItemScreenState();
}

class _AddLostItemScreenState extends ConsumerState<AddLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _reportedByController = TextEditingController(); // اسم العامل
  Booking? _selectedBooking;
  String _selectedStatus = 'تم العثور عليه';
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _reportedByController.dispose();
    super.dispose();
  }

  Future<void> _saveLostItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBooking == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار الحجز المرتبط.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final newLostItem = LostItem(
        bookingId: _selectedBooking!.id!,
        description: _descriptionController.text,
        status: _selectedStatus,
        reportedAt: DateTime.now(),
        reportedBy: _reportedByController.text,
      );

      try {
        final sembastService = ref.read(sembastServiceProvider);
        await sembastService.addLostItem(newLostItem);
        if (mounted) {
          context.pop(); // العودة إلى شاشة قائمة المفقودات
        }
      } catch (e) {
        // معالجة الخطأ
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // جلب قائمة الحجوزات لعرضها في القائمة المنسدلة
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل عنصر مفقود'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // القائمة المنسدلة لاختيار الحجز
              bookingsAsync.when(
                data: (bookings) => DropdownButtonFormField<Booking>(
                  value: _selectedBooking,
                  hint: const Text('اختر الحجز المرتبط'),
                  decoration: const InputDecoration(
                    labelText: 'الحجز',
                    border: OutlineInputBorder(),
                  ),
                  items: bookings.map((booking) {
                    return DropdownMenuItem<Booking>(
                      value: booking,
                      // عرض رقم الحجز واسم العميل
                      child: Text('حجز #${booking.bookingNumber}'),
                    );
                  }).toList(),
                  onChanged: (booking) {
                    setState(() => _selectedBooking = booking);
                  },
                  validator: (value) => value == null ? 'الحجز مطلوب' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('خطأ في تحميل الحجوزات: $err'),
              ),
              const SizedBox(height: 16),
              // حقل وصف العنصر المفقود
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف العنصر المفقود',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: 16),
              // حقل اسم العامل الذي سجل المفقودات
              TextFormField(
                controller: _reportedByController,
                decoration: const InputDecoration(
                  labelText: 'اسم العامل المسؤول',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'اسم العامل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              // حقل حالة العنصر
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                items: ['تم العثور عليه', 'تم التسليم للعميل', 'قيد المتابعة']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              // زر الحفظ
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveLostItem,
                icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save),
                label: Text(_isLoading ? 'جاري الحفظ...' : 'حفظ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
