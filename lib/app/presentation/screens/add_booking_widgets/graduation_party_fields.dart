import 'package:flutter/material.dart';
import '../../templates/section_template.dart';
import '../../templates/fields/text_field_template.dart';
import '../../templates/togglable_service_template.dart';

class GraduationPartyFields extends StatelessWidget {
  final TextEditingController hallNameController;
  final TextEditingController maleGraduatesController;
  final TextEditingController femaleGraduatesController;
  final TextEditingController aisleNotesController;
  final TextEditingController amountController;

  // متغيرات خيار الكراسي
  final bool showChairsOption;
  final ValueChanged<bool> onChairsToggle;
  final TextEditingController chairsNotesController;

  const GraduationPartyFields({
    super.key,
    required this.hallNameController,
    required this.maleGraduatesController,
    required this.femaleGraduatesController,
    required this.aisleNotesController,
    required this.amountController,
    required this.showChairsOption,
    required this.onChairsToggle,
    required this.chairsNotesController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTemplate(
      title: 'تفاصيل حفلة التخرج',
      children: [
        TextFieldTemplate(
          controller: hallNameController,
          label: 'اسم القاعة',
          validator: (value) => value!.isEmpty ? 'اسم القاعة مطلوب' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFieldTemplate(
                controller: maleGraduatesController,
                label: 'خريجين (رجال)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFieldTemplate(
                controller: femaleGraduatesController,
                label: 'خريجات (نساء)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFieldTemplate(
          controller: aisleNotesController,
          label: 'ملاحظات زينة الممر',
        ),
        const SizedBox(height: 16),
        const Divider(),
        TogglableServiceTemplate(
          title: 'خيار الكراسي',
          isEnabled: showChairsOption,
          onToggle: onChairsToggle,
          notesController: chairsNotesController,
          onPickImage: () {}, // لإضافة صور للكراسي
        ),
        const SizedBox(height: 16),
        TextFieldTemplate(
          controller: amountController,
          label: 'المبلغ',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.attach_money,
        ),
      ],
    );
  }
}