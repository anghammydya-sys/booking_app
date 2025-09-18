class InventoryItem {
  int? id;
  String name;
  String category;
  int totalQuantity;

  InventoryItem({
    this.id,
    required this.name,
    required this.category,
    required this.totalQuantity,
  });

  Map<String, dynamic> toSembast() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'totalQuantity': totalQuantity,
    };
  }

  factory InventoryItem.fromSembast(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      totalQuantity: map['totalQuantity'] as int,
    );
  }
}
