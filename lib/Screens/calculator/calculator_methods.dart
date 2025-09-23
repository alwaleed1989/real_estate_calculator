import 'package:flutter/services.dart';

class calculator_methods {
  late final double amount;
  late final double VAT_value;
  late final double Fees_value;
  calculator_methods(this.amount);

  double VAT( double VAT) {
    VAT = VAT / 100;
    print("VAT : ${VAT}");
    print("Total Amount ${amount * VAT}");
    return amount * VAT;
  }

  double Fees( double Fee) {
    Fee = Fee / 100;
    print("VAT : ${Fee}");
    print("Total Amount ${amount * Fee}");
    return amount * Fee;
  }

  double calculate_btn()
  {
    print("--------start--------");

    calculator_methods cal = new calculator_methods(amount);
    double vat = cal.VAT( 5);
    double fee =cal.Fees(2.5);
    print("----------------");
    print(amount+vat+fee);
    return amount+vat+fee;
  }

  double without_VAT()
  {
    calculator_methods cal = new calculator_methods(amount);
    double fee =cal.Fees(2.5);
    print("----------------");
    print(amount+fee);
    return amount+fee;
  }


}



class MaxValueTextInputFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalDigits;

  MaxValueTextInputFormatter({this.maxValue = double.infinity, this.decimalDigits = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue; // Allow empty input
    }

    // 1. Filter out invalid characters (non-digits except one decimal point)
    final RegExp regex = RegExp(r'^\d*\.?\d{0,' + decimalDigits.toString() + r'}$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue; // If invalid, keep the old value
    }

    // 2. Try parsing the new value to a double
    final double? parsedValue = double.tryParse(newValue.text);

    // 3. Check against the max value
    if (parsedValue != null && parsedValue > maxValue) {
      // If the parsed value exceeds the max, revert to the old value
      // This prevents the user from typing a number larger than maxValue.
      return oldValue;
    }

    // 4. If all checks pass (valid format and within max value), allow the new value
    return newValue;
  }
}
