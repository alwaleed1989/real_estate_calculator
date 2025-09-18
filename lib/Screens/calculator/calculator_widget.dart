import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Padding Amount_Fields(TextEditingController controller)
{
  return  Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'المبلغ',
        hintText: 'هذا الحقل يقبل الارقام فقط',
        border: OutlineInputBorder(),
      ),
      // 1. Set the keyboard type to number
      keyboardType: TextInputType.number,
      // 2. Add an input formatter to only allow digits
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    ),
  );
}


