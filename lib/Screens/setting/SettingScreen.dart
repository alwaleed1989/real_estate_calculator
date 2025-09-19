

import 'package:flutter/material.dart';
import 'package:real_estate_calculator/Screens/setting/setting.dart';

class SettingsBottomSheet extends StatefulWidget {
  final double initialTaxRate;
  final double initialCommissionRate;
  final bool isTaxExempt;

  const SettingsBottomSheet({
    super.key,
    required this.initialTaxRate,
    required this.initialCommissionRate,
    required this.isTaxExempt,
  });

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late TextEditingController _taxController;
  late TextEditingController _commissionController;
  late bool _isTaxExempt;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state with the values from the main screen
    _taxController = TextEditingController(text: (widget.initialTaxRate * 100).toStringAsFixed(1));
    _commissionController = TextEditingController(text: (widget.initialCommissionRate * 100).toStringAsFixed(1));
    _isTaxExempt = widget.isTaxExempt;
  }

  @override
  void dispose() {
    _taxController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  // Save and close the sheet, passing the new settings back
  void _saveSettings() {
    final newSettings = CalculatorSettings(
      // Convert percentage string back to a decimal value
      taxRate: (double.tryParse(_taxController.text) ?? 0) / 100,
      commissionRate: (double.tryParse(_commissionController.text) ?? 0) / 100,
      isTaxExempt: _isTaxExempt,
    );
    // Pop the sheet and return the new settings object
    Navigator.of(context).pop(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the content in a SingleChildScrollView to prevent overflow when the keyboard appears.
    return SingleChildScrollView(
      child: Padding(
        // Add padding to the content and also to account for the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the sheet only as tall as its content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإعدادات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),

            // --- Tax Settings ---
            const Text('الضريبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _taxController,
                label: 'نسبة الضريبة',
                enabled: !_isTaxExempt // Disable if tax is exempt
            ),
            SwitchListTile(
              title: const Text('معفي من الضريبه'),
              value: _isTaxExempt,
              onChanged: (newValue) {
                setState(() {
                  _isTaxExempt = newValue;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).primaryColor,
            ),

            const Divider(height: 32),

            // --- Commission Settings ---
            const Text('السعي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _commissionController,
              label: 'نسبة السعي',
              enabled: true,
            ),

            const SizedBox(height: 24),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ التغييرات'),
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper widget for creating styled text fields
  Widget _buildTextField({required TextEditingController controller, required String label, required bool enabled}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        labelText: label,
        suffixText: '%',
      ),
    );
  }
}