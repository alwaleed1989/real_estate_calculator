import 'dart:io';

import 'package:flutter/cupertino.dart';
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


Future<void> Error_Dialog(BuildContext context) async {

     String Title_msg = "خطأ في المدخلات";
    String Text_msg = "هذا الحقل لا يحتوي على قيمة";
    if (Platform.isIOS) {
      print("OS ios");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title:  Text(Title_msg),
            content:  Text(Text_msg),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('حسنًا'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else {
      print("OS android");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Text(Title_msg),
            content:  Text(Text_msg),
            actions: <Widget>[
              TextButton(
                child: const Text('موافق'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

}