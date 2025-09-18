import 'package:flutter/material.dart';

class SectionTemplate extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;

  const SectionTemplate({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.only(top: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal)),
              const Divider(height: 24, thickness: 1.5),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
