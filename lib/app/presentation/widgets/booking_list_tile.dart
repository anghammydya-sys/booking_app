import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking.dart';

class BookingListTile extends StatelessWidget {
  final Booking booking;

  const BookingListTile({super.key, required this.booking});

  // دالة مساعدة لتحديد لون الحالة
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'جاهز':
        return Colors.green;
      case 'مؤجل':
        return Colors.red;
      case 'جاري':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(booking.status).withOpacity(0.2),
          child: Icon(
            Icons.event_note,
            color: _getStatusColor(booking.status),
          ),
        ),
        title: Text(
          'حجز رقم: ${booking.bookingNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'تاريخ الحفلة: ${DateFormat.yMMMd('ar').format(booking.eventDate)}\n'
          'الحالة: ${booking.status}',
        ),
        isThreeLine: true,
        trailing: Text(
          '${booking.totalAmount.toStringAsFixed(2)} ريال',
          style: TextStyle(
            color: Colors.teal.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
