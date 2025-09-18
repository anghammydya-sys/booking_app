import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/customer.dart';
import '../providers/database_providers.dart';

class QuickAddCustomerDialog extends ConsumerStatefulWidget {
  const QuickAddCustomerDialog({super.key});

  @override
  ConsumerState<QuickAddCustomerDialog> createState() => _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState extends ConsumerState<QuickAddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newCustomer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
      );
      try {
        final sembastService = ref.read(sembastServiceProvider);
        final newId = await sembastService.addCustomer(newCustomer);
        newCustomer.id = newId; // قم بتعيين الـ ID الجديد للكائن
        
        if (mounted) {
          // أعد العميل الجديد إلى الشاشة السابقة
          Navigator.of(context).pop(newCustomer);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة عميل جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
              validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الجوال'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'رقم الجوال مطلوب' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCustomer,
          child: _isLoading ? const CircularProgressIndicator() : const Text('حفظ'),
        ),
      ],
    );
  }
}
