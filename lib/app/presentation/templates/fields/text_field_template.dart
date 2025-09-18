import 'package:flutter/material.dart';

class TextFieldTemplate extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int? maxLines; // <-- أضف هذه الخاصية

  const TextFieldTemplate({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines, // <-- أضفها هنا
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines, // <-- استخدمها هنا
    );
  }
}
