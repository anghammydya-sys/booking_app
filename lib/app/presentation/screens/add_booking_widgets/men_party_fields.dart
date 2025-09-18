import 'package:flutter/material.dart';
import '../../templates/counter_field_template.dart';
import '../../templates/section_template.dart';
import '../../templates/fields/text_field_template.dart';

class MenPartyFields extends StatelessWidget {
  final TextEditingController hallNameController;
  final TextEditingController decorNotesController;
  final TextEditingController amountController;
  final int daysCount;
  final ValueChanged<int> onDaysCountChanged;
  // لاحقًا يمكن إضافة حقل لاختيار صورة الديكور

  const MenPartyFields({
    super.key,
    required this.hallNameController,
    required this.decorNotesController,
    required this.amountController,
    required this.daysCount,
    required this.onDaysCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTemplate(
      title: 'تفاصيل حفلة الرجال',
      children: [
        TextFieldTemplate(
          controller: hallNameController,
          label: 'اسم القاعة',
          validator: (value) => value!.isEmpty ? 'اسم القاعة مطلوب' : null,
        ),
        const SizedBox(height: 16),
        TextFieldTemplate(
          controller: decorNotesController,
          label: 'ملاحظات الديكور',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CounterFieldTemplate(
          label: 'عدد الأيام',
          value: daysCount,
          onChanged: onDaysCountChanged,
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
