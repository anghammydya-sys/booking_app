import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/lost_item.dart';
import '../../../data/models/lost_item_action.dart';
import '../../providers/database_providers.dart';

// Provider لجلب الإجراءات الخاصة بعنصر معين
final lostItemActionsProvider = StreamProvider.family<List<LostItemAction>, int>((ref, lostItemId) {
  final sembastService = ref.watch(sembastServiceProvider);
  return sembastService.watchActionsForLostItem(lostItemId);
});

class LostItemDetailsScreen extends ConsumerWidget {
  final LostItem lostItem;

  const LostItemDetailsScreen({super.key, required this.lostItem});

  void _showAddActionDialog(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController();
    String selectedAction = 'اتصال بالعميل';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة إجراء جديد'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedAction,
                  isExpanded: true,
                  items: ['اتصال بالعميل', 'تعويض مادي', 'تمت الإعادة', 'إجراء داخلي']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedAction = value!),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newAction = LostItemAction(
                lostItemId: lostItem.id!,
                actionType: selectedAction,
                notes: notesController.text,
                actionDate: DateTime.now(),
              );
              final sembastService = ref.read(sembastServiceProvider);
              await sembastService.addLostItemAction(newAction);

              // إذا كان الإجراء هو "تمت الإعادة"، قم بتغيير حالة العنصر إلى "مغلق"
              if (selectedAction == 'تمت الإعادة') {
                lostItem.status = 'مغلق';
                await sembastService.updateLostItem(lostItem);
              }
              
              Navigator.of(ctx).pop();
            },
            child: const Text('حفظ الإجراء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(lostItemActionsProvider(lostItem.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المفقودات (حجز ${lostItem.bookingId})'),
        backgroundColor: lostItem.status == 'مغلق' ? Colors.grey : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (عرض تفاصيل العنصر المفقود نفسه)
            Text('الوصف: ${lostItem.description}', style: Theme.of(context).textTheme.titleLarge),
            Text('الحالة: ${lostItem.status}'),
            const Divider(height: 30),
            Text('سجل الإجراءات:', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: actionsAsync.when(
                data: (actions) {
                  if (actions.isEmpty) return const Center(child: Text('لا توجد إجراءات مسجلة.'));
                  return ListView.builder(
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(action.actionType),
                        subtitle: Text(action.notes),
                        trailing: Text(DateFormat.yMd('ar').format(action.actionDate)),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('خطأ: $err'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: lostItem.status == 'مفتوح'
          ? FloatingActionButton(
              onPressed: () => _showAddActionDialog(context, ref),
              child: const Icon(Icons.add_comment_outlined),
              tooltip: 'إضافة إجراء',
            )
          : null, // إخفاء الزر إذا كانت الحالة "مغلق"
    );
  }
}
