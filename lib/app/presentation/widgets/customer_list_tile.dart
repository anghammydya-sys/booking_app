import 'package:flutter/material.dart';
import '../../data/models/customer.dart';
// لم نعد بحاجة إلى مكتبة intl هنا
// import 'package:intl/intl.dart';

class CustomerListTile extends StatelessWidget {
  final Customer customer;

  const CustomerListTile({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
            style: TextStyle(
              color: Colors.teal.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        // --- [التصحيح هنا] ---
        // تم تبسيط الـ subtitle لعرض رقم الهاتف فقط
        subtitle: Text('الهاتف: ${customer.phone}'),
        // لم يعد isThreeLine ضروريًا
        // isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () {
            // TODO: Implement navigation to edit customer screen
            print('تعديل العميل: ${customer.id}');
          },
        ),
      ),
    );
  }
}
