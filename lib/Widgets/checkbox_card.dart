import 'package:flutter/material.dart';

class CheckboxCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final double? amount;
  final VoidCallback? onEdit;

  const CheckboxCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.amount,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 1.0,
        child: CheckboxListTile(
          dense: true,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          value: value,
          onChanged: onChanged,
          subtitle: value == true
              ? Row(
                  children: [
                    Text(
                      '$amount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        onPressed: onEdit,
                      ),
                    ),
                  ],
                )
              : const Text('Click on Checkbox to add'),
        ),
      ),
    );
  }
}
