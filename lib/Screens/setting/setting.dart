import 'package:flutter/material.dart';
import '../../main.dart';

class CalculatorSettings {
  final double taxRate;
  final double commissionRate;
  final bool isTaxExempt;

  CalculatorSettings({
    required this.taxRate,
    required this.commissionRate,
    required this.isTaxExempt,
  });
}

