import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/customer.dart';
import '../../providers/database_providers.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  // مفتاح للتحقق من صحة النموذج
  final _formKey = GlobalKey<FormState>();
  // وحدات تحكم لحقول الإدخال
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // متغير لتتبع حالة التحميل عند الحفظ
  bool _isLoading = false;

  @override
  void dispose() {
    // التخلص من وحدات التحكم لتجنب تسرب الذاكرة
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // دالة لحفظ العميل
  Future<void> _saveCustomer() async {
    // التحقق من أن الحقول ليست فارغة
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // بدء التحميل
      });

      // إنشاء كائن العميل الجديد
      final newCustomer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      try {
        // الوصول إلى خدمة قاعدة البيانات عبر Riverpod وإضافة العميل
        final sembastService = ref.read(sembastServiceProvider);
        await sembastService.addCustomer(newCustomer);

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة العميل بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          // العودة إلى الشاشة السابقة
          context.pop();
        }
      } catch (e) {
        // في حالة حدوث خطأ، إظهار رسالة خطأ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // إيقاف التحميل في كل الحالات
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عميل جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل إدخال اسم العميل
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم العميل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // حقل إدخال رقم الهاتف
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // زر الحفظ
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveCustomer, // تعطيل الزر أثناء التحميل
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
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
