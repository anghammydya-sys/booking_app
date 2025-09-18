import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/payment.dart';
import '../providers/database_providers.dart';
import '../../core/helpers/printing_helper.dart';


class AddPaymentDialog extends ConsumerStatefulWidget {
  // في AddPaymentDialog
final int bookingId;
final String bookingNumber; // <-- [جديد]
final String customerName;  // <-- [جديد]

const AddPaymentDialog({
  super.key,
  required this.bookingId,
  required this.bookingNumber, // <-- [جديد]
  required this.customerName,   // <-- [جديد]
});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'نقدي';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // في _AddPaymentDialogState

Future<void> _savePayment() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    final newPayment = Payment(
      bookingId: widget.bookingId,
      amount: double.parse(_amountController.text),
      method: _selectedMethod,
      paidAt: DateTime.now(),
    );

    try {
      final sembastService = ref.read(sembastServiceProvider);
      final newPaymentId = await sembastService.addPayment(newPayment); // احصل على ID الدفعة
      
      if (mounted) {
        // أغلق نافذة الإضافة أولاً
        context.pop(); 

        // اسأل المستخدم إذا كان يريد الطباعة
        final wantToPrint = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('نجاح'),
            content: const Text('تمت إضافة الدفعة بنجاح. هل تريد طباعة سند القبض؟'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('لاحقًا')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('نعم، اطبع')),
            ],
          ),
        );

        // إذا اختار المستخدم الطباعة
        if (wantToPrint == true) {
          final receiptData = {
            'receiptNumber': newPaymentId, // استخدام ID الدفعة كرقم للسند
            'paymentDate': newPayment.paidAt,
            'customerName': widget.customerName,
            'amount': newPayment.amount.toStringAsFixed(2),
            'bookingDescription': 'حجز رقم ${widget.bookingNumber}',
            'paymentMethod': newPayment.method,
          };
          await PrintingHelper.printPaymentReceipt(receiptData);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة دفعة جديدة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'المبلغ مطلوب';
                }
                if (double.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'طريقة الدفع',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              items: ['نقدي', 'شبكة', 'تحويل بنكي'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePayment,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('حفظ'),
        ),
      ],
    );
  }
}
