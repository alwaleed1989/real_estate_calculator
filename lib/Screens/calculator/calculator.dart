import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calculator_methods.dart';
import 'calculator_widget.dart';

class calculatorScreen extends StatefulWidget {
  const calculatorScreen({super.key});

  @override
  State<calculatorScreen> createState() => _calculatorScreenState();
}

class _calculatorScreenState extends State<calculatorScreen> {
  final TextEditingController _amountController = TextEditingController();

  // 1. أنشئ متغيرات حالة لكل قيمة تريد عرضها
  String _totalResultText = "";
  String _vatText = "";
  String _feeResult = "";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // 2. قم بإجراء جميع الحسابات هنا
  void _calculate() {
    final amount = double.tryParse(_amountController.text);

    if (amount != null) {
      // افترض أن الكلاس calculator_methods يحتوي على دوال لحساب كل قيمة
      final calc = calculator_methods(amount);
      final totalResult = calc.calculate_btn(); // لحساب الإجمالي
      final vatResult = calc.VAT(15);
      final feeResult = calc.Fees(2.5);

      // أداة تنسيق العملة
      final currencyFormatter = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: 'ر.س',
        decimalDigits: 2,
      );

      // استخدم setState لتحديث جميع متغيرات الحالة مرة واحدة
      setState(() {
        _totalResultText = "الإجمالي: ${currencyFormatter.format(totalResult)}";
        _vatText = "الضريبة (15%): ${currencyFormatter.format(vatResult)}";
        _feeResult = "السعي (2.5%): ${currencyFormatter.format(feeResult)}";


      });
    } else {
      // في حالة الإدخال الخاطئ، قم بمسح النتائج
      _clear();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("الرجاء إدخال رقم صحيح")),
      // );
      Error_Dialog(context);

    }
  }

  // دالة لمسح الحقول والنتائج
  void _clear() {
    _amountController.clear();
    setState(() {
      _totalResultText = "";
      _vatText = "";
      _feeResult = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة العقار'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      // تم نقل الأزرار إلى هنا لتكون في مكانها الصحيح
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 200,),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text("احسب"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear),
                label: const Text("مسح"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _totalResultText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _vatText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          Text(
            _feeResult,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const Spacer(),
          Amount_Fields(_amountController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

