// في lost_item_action.dart

class LostItemAction {
  int? id;
  final int lostItemId; // للربط بالعنصر المفقود
  final String actionType; // مثال: 'اتصال بالعميل'، 'تعويض مادي'، 'إعادة'
  final String notes;
  final DateTime actionDate;

  LostItemAction({
    this.id,
    required this.lostItemId,
    required this.actionType,
    required this.notes,
    required this.actionDate,
  });

  Map<String, dynamic> toSembast() {
    return {
      'lostItemId': lostItemId,
      'actionType': actionType,
      'notes': notes,
      'actionDate': actionDate.toIso8601String(),
    };
  }

  static LostItemAction fromSembast(Map<String, dynamic> map) {
    return LostItemAction(
      lostItemId: map['lostItemId'],
      actionType: map['actionType'],
      notes: map['notes'],
      actionDate: DateTime.parse(map['actionDate']),
    );
  }
}
