import 'package:flutter/material.dart';
import 'fields/text_field_template.dart';
import 'dart:io';

class TogglableServiceTemplate extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final TextEditingController notesController;

final String? imagePath;
  
  // --- [جديد] خصائص اختيارية ---
  final TextEditingController? amountController;
  final VoidCallback? onPickImage;

  
const TogglableServiceTemplate({
  // ...
  this.imagePath,


// داخل دالة build، بعد زر "اختيار صورة"

  
    super.key,
    required this.title,
    required this.isEnabled,
    required this.onToggle,
    required this.notesController,
    this.amountController, // جعله اختياريًا
    this.onPickImage,      // جعله اختياريًا
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: Colors.teal,
            ),
          ],
        ),
        if (isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // --- [تعديل] استخدام Flex بدلاً من Column ---
                  child: Column(
                    children: [
                      TextFieldTemplate(
                        controller: notesController,
                        label: 'ملاحظات',
                        maxLines: 2,
                      ),
                      // --- [جديد] عرض حقل المبلغ إذا تم توفيره ---
                      if (amountController != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: TextFieldTemplate(
                            controller: amountController!,
                            label: 'المبلغ',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.attach_money,
                          ),
                        ),
                    ],
                  ),
                ),
                // --- [جديد] عرض زر الصورة إذا تم توفيره ---
                if (imagePath != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Image.file(
      File(imagePath!), // عرض الصورة من مسارها على الجهاز
      height: 100,
      width: 100,
      fit: BoxFit.cover,
    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
// في TogglableServiceTemplate، داخل Column الخاص بالخدمة المفعلة

// ...
if (onPickImage != null)
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      children: [
        // عرض الصورة المصغرة إذا كانت موجودة
        if (imagePath != null)
          Container(
            width: 50, height: 50,
            margin: const EdgeInsets.only(left: 10),
            child: Image.file(File(imagePath!), fit: BoxFit.cover),
          ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickImage, // onPickImage سيقوم بفتح النافذة
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(imagePath != null ? 'تغيير الصورة' : 'اختيار صورة'),
          ),
        ),
      ],
    ),
  ),
// ...
