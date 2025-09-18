import 'package:flutter/material.dart';
import 'fields/text_field_template.dart'; // استخدام القالب الجديد

class TogglableServiceTemplate extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  
  // وحدات التحكم يتم تمريرها من الشاشة الأم
  final TextEditingController notesController;
  final TextEditingController? amountController;
  final VoidCallback? onPickImage;

  const TogglableServiceTemplate({
    super.key,
    required this.title,
    required this.isEnabled,
    required this.onToggle,
    required this.notesController,
    this.amountController,
    this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Switch(value: isEnabled, onChanged: onToggle, activeColor: Colors.teal),
          ],
        ),
        if (isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              children: [
                TextFieldTemplate(
                  controller: notesController,
                  label: 'ملاحظات $title',
                ),
                if (amountController != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextFieldTemplate(
                      controller: amountController!,
                      label: 'المبلغ',
                      keyboardType: TextInputType.number,
                      // --- [التصحيح هنا] ---
                      prefixIcon: Icons.monetization_on_outlined, 
                    ),
                  ),
                if (onPickImage != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onPickImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('اختيار صورة'),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
