class Pledge {
  int? id;
  final int bookingId;
  final String customerName;
  final String description;
  final String? imagePath;
  final DateTime createdAt;
  String status; // 'active', 'returned'

  Pledge({
    this.id,
    required this.bookingId,
    required this.customerName,
    required this.description,
    this.imagePath,
    required this.createdAt,
    this.status = 'active',
  });

  // أضف دوال toSembast() و fromSembast()
}
