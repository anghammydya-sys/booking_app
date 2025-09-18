import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/venue.dart';
import '../../providers/database_providers.dart';

class AddVenueScreen extends ConsumerStatefulWidget {
  const AddVenueScreen({super.key});

  @override
  ConsumerState<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends ConsumerState<AddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'صالة';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveVenue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newVenue = Venue(
        name: _nameController.text,
        type: _selectedType,
      );
      try {
        final sembastService = ref.read(sembastServiceProvider);
        await sembastService.addVenue(newVenue);
        if (mounted) context.pop();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قاعة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم القاعة/الصالة', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                items: ['صالة', 'قاعة', 'مخيم', 'استراحة']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVenue,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
