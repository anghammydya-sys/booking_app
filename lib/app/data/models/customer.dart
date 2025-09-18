class Customer {
  int? id; // ID سيكون اختياريًا عند الإنشاء، وsembast سيعطيه قيمة
  String name;
  String phone;
  String? notes;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.notes,
  });

  // تحويل كائن العميل إلى Map<String, dynamic> لحفظه في sembast
  Map<String, dynamic> toSembast() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
    };
  }

  // إنشاء كائن عميل من Map<String, dynamic> (عند قراءته من sembast)
  factory Customer.fromSembast(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      notes: map['notes'] as String?,
    );
  }
}
