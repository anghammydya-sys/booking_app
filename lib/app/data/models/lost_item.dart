// في lost_item.dart

class LostItem {
  int? id;
  final int bookingId;
  final String description;
  final String? imagePath;
  final DateTime reportedAt;
  String status; // <-- [جديد] الحالة: 'مفتوح'، 'مغلق'

  LostItem({
    this.id,
    required this.bookingId,
    required this.description,
    this.imagePath,
    required this.reportedAt,
    this.status = 'مفتوح', // <-- قيمة افتراضية
  });

  Map<String, dynamic> toSembast() {
    return {
      'bookingId': bookingId,
      'description': description,
      'imagePath': imagePath,
      'reportedAt': reportedAt.toIso8601String(),
      'status': status, // <-- [جديد]
    };
  }

  static LostItem fromSembast(Map<String, dynamic> map) {
    return LostItem(
      bookingId: map['bookingId'],
      description: map['description'],
      imagePath: map['imagePath'],
      reportedAt: DateTime.parse(map['reportedAt']),
      status: map['status'] ?? 'مفتوح', // <-- [جديد]
    );
  }
}
