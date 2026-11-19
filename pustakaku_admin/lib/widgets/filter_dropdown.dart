import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.prefixIcon = Icons.filter_list,
    super.key,
  });

  final String hint;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (selection) {
        if (selection != null) {
          onChanged(selection);
        }
      },
    );
  }
}
