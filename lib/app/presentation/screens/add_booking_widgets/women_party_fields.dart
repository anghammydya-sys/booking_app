import 'package:flutter/material.dart';
import '../../templates/counter_field_template.dart';
import '../../templates/section_template.dart';
import '../../templates/fields/text_field_template.dart';
import '../../templates/togglable_service_template.dart';


class WomenPartyFields extends StatelessWidget {
  // متغيرات قسم الديكور
  final String? selectedDecorType;
  final ValueChanged<String?> onDecorTypeChanged;
  final TextEditingController venueNameController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final TextEditingController flowerColorController;
  final int daysCount;
  final ValueChanged<int> onDaysCountChanged;

final String? goldStandImagePath;
final VoidCallback onGoldStandPickImage;
  // متغيرات إضافات الصالة
  final bool showAisleDecoration;
  final ValueChanged<bool> onAisleToggle;
  final TextEditingController aisleDecorationController;
  final bool showStairsDecoration;
  final ValueChanged<bool> onStairsToggle;
  final TextEditingController stairsDecorationController;
  final bool showEntranceDecoration;
  final ValueChanged<bool> onEntranceToggle;
  final TextEditingController entranceDecorationController;

  // --- [جديد] متغيرات الخدمات العامة ---
  final bool showGoldStand;
  final ValueChanged<bool> onGoldStandToggle;
  final TextEditingController goldStandNotesController;
  final bool showSpeaker;
  final ValueChanged<bool> onSpeakerToggle;
  final TextEditingController speakerNotesController;
  final TextEditingController speakerAmountController;
  final bool showPrinting;
  final ValueChanged<bool> onPrintingToggle;
  final TextEditingController printingNotesController;
  final TextEditingController printingAmountController;

  // --- [جديد] متغيرات الأجهزة الخاصة ---
  final bool showSmokeMachine;
  final ValueChanged<bool> onSmokeMachineToggle;
  final TextEditingController smokeMachineAmountController;
  final bool showLaserMachine;
  final ValueChanged<bool> onLaserMachineToggle;
  final TextEditingController laserMachineAmountController;
  final bool showFollowSpot;
  final ValueChanged<bool> onFollowSpotToggle;
  final TextEditingController followSpotAmountController;

  const WomenPartyFields({
    super.key,
    // ... (كل المتغيرات السابقة)
    required this.selectedDecorType,
    required this.onDecorTypeChanged,
    required this.venueNameController,
    required this.addressController,
    required this.floorController,
    required this.flowerColorController,
    required this.daysCount,
    required this.onDaysCountChanged,
    required this.showAisleDecoration,
    required this.onAisleToggle,
    required this.aisleDecorationController,
    required this.showStairsDecoration,
    required this.onStairsToggle,
    required this.stairsDecorationController,
    required this.showEntranceDecoration,
    required this.onEntranceToggle,
    required this.entranceDecorationController,
      this.goldStandImagePath,
  required this.onGoldStandPickImage,
    // --- [جديد] إضافة المتغيرات الجديدة للـ constructor ---
    required this.showGoldStand,
    required this.onGoldStandToggle,
    required this.goldStandNotesController,
    required this.showSpeaker,
    required this.onSpeakerToggle,
    required this.speakerNotesController,
    required this.speakerAmountController,
    required this.showPrinting,
    required this.onPrintingToggle,
    required this.printingNotesController,
    required this.printingAmountController,
    required this.showSmokeMachine,
    required this.onSmokeMachineToggle,
    required this.smokeMachineAmountController,
    required this.showLaserMachine,
    required this.onLaserMachineToggle,
    required this.laserMachineAmountController,
    required this.showFollowSpot,
    required this.onFollowSpotToggle,
    required this.followSpotAmountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- قسم الديكور (كما هو) ---
        SectionTemplate(
          title: 'تفاصيل الديكور',
          children: [
            DropdownButtonFormField<String>(
              value: selectedDecorType,
              onChanged: onDecorTypeChanged,
              hint: const Text('اختر نوع الديكور'),
              items: ['بيت', 'صالة', 'مخيم'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            if (selectedDecorType == 'صالة')
              TextFieldTemplate(controller: venueNameController, label: 'اسم الصالة'),
            if (selectedDecorType == 'بيت' || selectedDecorType == 'مخيم') ...[
              TextFieldTemplate(controller: addressController, label: 'العنوان'),
              const SizedBox(height: 16),
              TextFieldTemplate(controller: floorController, label: 'الدور كم'),
            ],
            const SizedBox(height: 16),
            TextFieldTemplate(controller: flowerColorController, label: 'لون الورد'),
            const SizedBox(height: 16),
            CounterFieldTemplate(label: 'عدد الأيام', value: daysCount, onChanged: onDaysCountChanged),
          ],
        ),

        // --- قسم إضافات الصالة (كما هو) ---
        if (selectedDecorType == 'صالة')
          SectionTemplate(
            title: 'إضافات الصالة',
            children: [
              TogglableServiceTemplate(title: 'زينة الممر', isEnabled: showAisleDecoration, onToggle: onAisleToggle, notesController: aisleDecorationController, onPickImage: () {}),
              const Divider(height: 20),
              TogglableServiceTemplate(title: 'زينة الدرج', isEnabled: showStairsDecoration, onToggle: onStairsToggle, notesController: stairsDecorationController, onPickImage: () {}),
              const Divider(height: 20),
              TogglableServiceTemplate(title: 'المدخل', isEnabled: showEntranceDecoration, onToggle: onEntranceToggle, notesController: entranceDecorationController, onPickImage: () {}),
            ],
          ),

        // --- [تعديل] قسم الخدمات العامة (مكتمل الآن) ---
        SectionTemplate(
          title: 'خدمات وأثاث إضافي',
          children: [
            TogglableServiceTemplate(
  title: 'استند ذهب',
  isEnabled: showGoldStand,
  onToggle: onGoldStandToggle,
  notesController: goldStandNotesController,
  onPickImage: onGoldStandPickImage, // <-- مرر الدالة
  imagePath: goldStandImagePath, // <-- مرر المسار
),
            const Divider(height: 20),
            TogglableServiceTemplate(
              title: 'سماعة',
              isEnabled: showSpeaker,
              onToggle: onSpeakerToggle,
              notesController: speakerNotesController,
              amountController: speakerAmountController, // إضافة حقل المبلغ
            ),
            const Divider(height: 20),
            TogglableServiceTemplate(
              title: 'طباعة',
              isEnabled: showPrinting,
              onToggle: onPrintingToggle,
              notesController: printingNotesController,
              amountController: printingAmountController, // إضافة حقل المبلغ
            ),
          ],
        ),
        
        // --- [تعديل] قسم الأجهزة الخاصة (مكتمل الآن ويظهر مع الصالة) ---
        if (selectedDecorType == 'صالة')
          SectionTemplate(
            title: 'أجهزة خاصة',
            children: [
              TogglableServiceTemplate(
                title: 'جهاز دخان',
                isEnabled: showSmokeMachine,
                onToggle: onSmokeMachineToggle,
                notesController: TextEditingController(), // لا نحتاج ملاحظات هنا
                amountController: smokeMachineAmountController,
              ),
              const Divider(height: 20),
              TogglableServiceTemplate(
                title: 'جهاز ليزر',
                isEnabled: showLaserMachine,
                onToggle: onLaserMachineToggle,
                notesController: TextEditingController(),
                amountController: laserMachineAmountController,
              ),
              const Divider(height: 20),
              TogglableServiceTemplate(
                title: 'جهاز متابعة',
                isEnabled: showFollowSpot,
                onToggle: onFollowSpotToggle,
                notesController: TextEditingController(),
                amountController: followSpotAmountController,
              ),
            ],
          ),
      ],
    );
  }
}
// في WomenPartyFields

// ... (الخصائص السابقة)
final String multiDayDecorOption;
final ValueChanged<String> onMultiDayDecorOptionChanged;
final Map<int, String> dailyFlowerColorChanges;
final Function(int day, String color) onDailyFlowerColorChanged;
// ... (والمزيد للتعامل مع الديكورات المختلفة)
// في WomenPartyFields، داخل SectionTemplate 'تفاصيل الديكور'

// ... (بعد CounterFieldTemplate)

// --- [المنطق الجديد هنا] ---
// لا يظهر هذا القسم إلا إذا كان عدد الأيام > 1 ونوع الديكور 'بيت'
if (daysCount > 1 && selectedDecorType == 'بيت')
  Padding(
    padding: const EdgeInsets.only(top: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('خيارات الأيام المتعددة:', style: TextStyle(fontWeight: FontWeight.bold)),
        // أزرار الاختيار (Radio Buttons)
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('نفس الديكور'),
                value: 'نفس الديكور',
                groupValue: multiDayDecorOption,
                onChanged: (val) => onMultiDayDecorOptionChanged(val!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('كل يوم ديكور'),
                value: 'كل يوم ديكور',
                groupValue: multiDayDecorOption,
                onChanged: (val) => onMultiDayDecorOptionChanged(val!),
              ),
            ),
          ],
        ),

        // عرض الحقول بناءً على الاختيار
        if (multiDayDecorOption == 'نفس الديكور')
          // بناء حقول لتغيير لون الورد لكل يوم
          ...List.generate(daysCount - 1, (index) {
            final day = index + 2; // نبدأ من اليوم الثاني
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFieldTemplate(
                label: 'لون الورد لليوم $day (اختياري)',
                onChanged: (value) => onDailyFlowerColorChanged(day, value),
              ),
            );
          }),

        if (multiDayDecorOption == 'كل يوم ديكور')
          // بناء حقول لاختيار ديكور ولون ورد لكل يوم
          ...List.generate(daysCount, (index) {
            final day = index + 1;
            return Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('تفاصيل اليوم $day', style: const TextStyle(fontWeight: FontWeight.bold)),
                    // حقل لاختيار صورة الديكور لهذا اليوم
                    // ... (سيحتاج إلى onPickImage خاص بهذا اليوم)
                    TextFieldTemplate(
                      label: 'لون الورد لليوم $day',
                      // ... (سيحتاج إلى onchanged خاص بهذا اليوم)
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    ),
  ),
// في WomenPartyFields، داخل دالة build

// ...
// اقرأ الحالة من الـ Provider (ستحتاج إلى تمريرها إلى هذه الويدجت)
final formState = ref.watch(bookingFormProvider);

// ...

// حقل اسم الصالة
TextFieldTemplate(
  controller: venueNameController,
  label: 'اسم الصالة',
  // --- [التحسين الذكي هنا] ---
  suffixIcon: formState.hasBookingConflict 
      ? const Icon(Icons.warning_amber_rounded, color: Colors.orange) 
      : null,
  validator: (value) {
    if (value == null || value.isEmpty) return 'اسم الصالة مطلوب';
    if (formState.hasBookingConflict) return 'هذه الصالة محجوزة في نفس التاريخ!';
    return null;
  },
),
