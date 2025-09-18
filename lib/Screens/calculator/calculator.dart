import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 1. قم باستيراد مكتبة intl
import 'calculator_methods.dart';
import 'calculator_widget.dart';

class calculatorScreen extends StatefulWidget {
  const calculatorScreen({super.key});

  @override
  State<calculatorScreen> createState() => _calculatorScreenState();
}

class _calculatorScreenState extends State<calculatorScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _resultText = "النتيجة ستظهر هنا";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text);

    if (amount != null) {
      // افترض أن هذه الدالة تُرجع رقماً مثل double
      final result = calculator_methods(amount).calculate_btn();

      // --- هذا هو التصحيح والتحسين ---
      // 2. أنشئ أداة تنسيق للعملة بالريال السعودي
      final currencyFormatter = NumberFormat.currency(
        locale: 'ar_SA', // استخدم اللغة العربية للمملكة العربية السعودية
        symbol: 'ر.س',   // رمز العملة
        decimalDigits: 2, // عدد الخانات العشرية
      );

      // 3. قم بتنسيق النتيجة الرقمية إلى نص
      final formattedResult = currencyFormatter.format(result);
      // ------------------------------------

      setState(() {
        // 4. قم بتحديث متغير الحالة بالنص المنسق
        _resultText = formattedResult;
      });
    } else {
      setState(() {
        _resultText = "خطأ: الرجاء إدخال رقم صحيح";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة العقار'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: _calculate,
          icon: const Icon(Icons.calculate),
          label: const Text("احسب"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 22),
            Text(
              _resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Amount_Fields(_amountController),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
