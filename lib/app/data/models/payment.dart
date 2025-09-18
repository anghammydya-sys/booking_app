class Payment {
  int? id;
  int bookingId;
  DateTime paidAt;
  double amount;
  String method;

  Payment({
    this.id,
    required this.bookingId,
    required this.paidAt,
    required this.amount,
    required this.method,
  });

  Map<String, dynamic> toSembast() {
    return {
      'id': id,
      'bookingId': bookingId,
      'paidAt': paidAt.toIso8601String(),
      'amount': amount,
      'method': method,
    };
  }

  factory Payment.fromSembast(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      bookingId: map['bookingId'] as int,
      paidAt: DateTime.parse(map['paidAt'] as String),
      amount: map['amount'] as double,
      method: map['method'] as String,
    );
  }
}
