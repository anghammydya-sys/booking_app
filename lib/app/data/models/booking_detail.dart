class BookingDetail {
  int? id;
  int bookingId;
  int inventoryItemId;
  int quantity;
  double price;

  BookingDetail({
    this.id,
    required this.bookingId,
    required this.inventoryItemId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toSembast() {
    return {
      'id': id,
      'bookingId': bookingId,
      'inventoryItemId': inventoryItemId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory BookingDetail.fromSembast(Map<String, dynamic> map) {
    return BookingDetail(
      id: map['id'] as int?,
      bookingId: map['bookingId'] as int,
      inventoryItemId: map['inventoryItemId'] as int,
      quantity: map['quantity'] as int,
      price: map['price'] as double,
    );
  }
}
