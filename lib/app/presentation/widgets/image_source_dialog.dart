import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/image_library_screen.dart';

class ImageSourceDialog extends StatelessWidget {
  const ImageSourceDialog({super.key});

  // دالة لرفع صورة جديدة
  Future<String?> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // هنا يجب حفظ الصورة في قاعدة البيانات (سيتم شرحه لاحقًا)
      // حاليًا، سنعيد المسار فقط
      return pickedFile.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختيار صورة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('الاختيار من مكتبة الصور'),
            onTap: () async {
              final selectedPath = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const ImageLibraryScreen()),
              );
              if (selectedPath != null) {
                Navigator.of(context).pop(selectedPath);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_photo_alternate_outlined),
            title: const Text('رفع صورة جديدة من المعرض'),
            onTap: () async {
              final newPath = await _pickFromGallery(context);
              if (newPath != null) {
                // TODO: حفظ الصورة الجديدة في MediaItems قبل إعادتها
                Navigator.of(context).pop(newPath);
              }
            },
          ),
        ],
      ),
    );
  }
}
