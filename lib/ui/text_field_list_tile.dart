import 'package:flutter/material.dart';

class TextFieldListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool? enabled;

  const TextFieldListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            enabled: enabled,
            onChanged: onChanged,
            validator: validator,
          ),
        ],
      ),
    );
  }
}