// في media_item.dart

class MediaItem {
  int? id;
  String title; // اسم وصفي للصورة (e.g., "ديكور صالة مودرن")
  String filePath; // مسار الصورة على جهاز المستخدم
  String category; // 'decor', 'table', 'chair', 'other'

  MediaItem({
    this.id,
    required this.title,
    required this.filePath,
    required this.category,
  });

  Map<String, dynamic> toSembast() => {
    'title': title,
    'filePath': filePath,
    'category': category,
  };

  static MediaItem fromSembast(Map<String, dynamic> map) => MediaItem(
    title: map['title'],
    filePath: map['filePath'],
    category: map['category'],
  );
}
