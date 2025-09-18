class Booking {
  int? id;
  final String bookingNumber;
  final int customerId;
  final DateTime eventDate;
  final String eventType;
  String status;
  double totalAmount;
  final DateTime createdAt;

  // --- كل الحقول الإضافية ---
  final int? responsibleStaffId;
  final String? generalNotes;
  final int? parentBookingId;
  final String? decorType;
  final String? venueName;
  final String? address;
  final String? floorNumber;
  final String? flowerColor;
  final int? daysCount;
  final String? aisleDecorationNotes;
  final String? stairsDecorationNotes;
  final String? entranceNotes;
  final String? goldStandNotes;
  final String? speakerNotes;
  final int? maleGraduatesCount;
  final int? femaleGraduatesCount;
    final int? parentId; // <-- [جديد] الحقل لربط الحجز الأصلي


  Booking({
    this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.eventDate,
    required this.eventType,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.responsibleStaffId,
    this.generalNotes,
    this.parentBookingId,
    this.decorType,
    this.venueName,
    this.address,
    this.floorNumber,
    this.flowerColor,
    this.daysCount,
    this.aisleDecorationNotes,
    this.stairsDecorationNotes,
    this.entranceNotes,
    this.goldStandNotes,
    this.speakerNotes,
    this.maleGraduatesCount,
    this.femaleGraduatesCount,
        this.parentId, // <-- [جديد]

  });

  // --- [مهم جدًا] تأكد من أن هذه الدالة كاملة ---
  Map<String, dynamic> toSembast() {
    return {
      'bookingNumber': bookingNumber,
      'customerId': customerId,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'responsibleStaffId': responsibleStaffId,
      'generalNotes': generalNotes,
      'parentBookingId': parentBookingId,
      'decorType': decorType,
      'venueName': venueName,
      'address': address,
      'floorNumber': floorNumber,
      'flowerColor': flowerColor,
      'daysCount': daysCount,
      'aisleDecorationNotes': aisleDecorationNotes,
      'stairsDecorationNotes': stairsDecorationNotes,
      'entranceNotes': entranceNotes,
      'goldStandNotes': goldStandNotes,
      'speakerNotes': speakerNotes,
      'maleGraduatesCount': maleGraduatesCount,
      'femaleGraduatesCount': femaleGraduatesCount,
            'parentId': parentId, // <-- [جديد]

    };
  }

  // --- [مهم جدًا] تأكد من أن هذه الدالة كاملة ---
  factory Booking.fromSembast(Map<String, dynamic> map) {
    return Booking(
      bookingNumber: map['bookingNumber'],
      customerId: map['customerId'],
      eventDate: DateTime.parse(map['eventDate']),
      eventType: map['eventType'],
      status: map['status'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      responsibleStaffId: map['responsibleStaffId'],
      generalNotes: map['generalNotes'],
      parentBookingId: map['parentBookingId'],
      decorType: map['decorType'],
      venueName: map['venueName'],
      address: map['address'],
      floorNumber: map['floorNumber'],
      flowerColor: map['flowerColor'],
      daysCount: map['daysCount'],
      aisleDecorationNotes: map['aisleDecorationNotes'],
      stairsDecorationNotes: map['stairsDecorationNotes'],
      entranceNotes: map['entranceNotes'],
      goldStandNotes: map['goldStandNotes'],
      speakerNotes: map['speakerNotes'],
      maleGraduatesCount: map['maleGraduatesCount'],
      femaleGraduatesCount: map['femaleGraduatesCount'],
            parentId: map['parentId'], // <-- [جديد]

    );
  }
}
// في كلاس Booking

// ... (الحقول السابقة)
final String? goldStandImagePath;
final String? aisleDecorationImagePath;
final String? stairsDecorationImagePath;
final String? entranceImagePath;

// قم بتحديث الـ constructor
Booking({
  // ...
  this.goldStandImagePath,
  this.aisleDecorationImagePath,
  this.stairsDecorationImagePath,
  this.entranceImagePath,
});

// قم بتحديث toSembast() و fromSembast()
// في toSembast():
'goldStandImagePath': goldStandImagePath,
// ... (أضف البقية)

// في fromSembast():
goldStandImagePath: map['goldStandImagePath'] as String?,
// ... (أضف البقية)
// في كلاس Booking
final String? installationStaffName;
final DateTime? installationTimestamp;

// قم بتحديث الـ constructor و toSembast() و fromSembast() لتشمل هذين الحقلين.
