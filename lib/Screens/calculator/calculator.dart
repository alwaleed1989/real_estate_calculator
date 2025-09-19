import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_calculator/Screens/setting/setting.dart';
import 'calculator_methods.dart';
import 'calculator_widget.dart';

class calculatorScreen extends StatefulWidget {
  const calculatorScreen({super.key});

  @override
  State<calculatorScreen> createState() => _calculatorScreenState();
}

class _calculatorScreenState extends State<calculatorScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _totalResultText = "";
  String _vatText = "";
  String _feeResult = "";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text);

    if (amount != null) {
      final calc = calculator_methods(amount);
      final totalResult = calc.calculate_btn();
      final vatResult = calc.VAT(5);
      final feeResult = calc.Fees(2.5);

      final currencyFormatter = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: 'ر.س',
        decimalDigits: 2,
      );

      setState(() {
        _totalResultText = "الإجمالي: ${currencyFormatter.format(totalResult)}";
        _vatText = "الضريبة (5%): ${currencyFormatter.format(vatResult)}";
        _feeResult = "السعي (2.5%): ${currencyFormatter.format(feeResult)}";
      });
    } else {
      _clear();
      // Assuming Error_Dialog is a function you've defined elsewhere
      // Error_Dialog(context);
    }
  }

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
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const setting_screen(),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      // 1. REMOVED the bottomNavigationBar property from here

      body: Padding( // Added padding around the body for better spacing
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Result Texts ---
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

            // 2. MOVED Spacer here to push everything below it to the bottom
            const Spacer(),

            // --- Input Field ---
            Amount_Fields(_amountController),
            const SizedBox(height: 16), // Spacing between field and buttons

            // 3. MOVED the buttons Row here, to the bottom of the Column
            Row(
              children: [
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
          ],
        ),
      ),
    );
  }
}