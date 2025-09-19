import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class setting_screen extends StatefulWidget {
  const setting_screen({super.key});

  @override
  State<setting_screen> createState() => _setting_screenState();
}

class _setting_screenState extends State<setting_screen> {
  // Create separate controllers for each field
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _pursuitFeeController = TextEditingController();

  // State variable for the checkbox
  bool _isTaxExempt = false;

  @override
  void initState() {
    super.initState();
    // Load all saved settings when the screen is created
    _loadSettings();
  }

  @override
  void dispose() {
    // Clean up both controllers
    _vatController.dispose();
    _pursuitFeeController.dispose();
    super.dispose();
  }

  // Function to load all saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load the saved values, providing defaults if they don't exist
    final savedVat = prefs.getDouble('vat_percentage') ?? 5.0;
    final savedPursuitFee = prefs.getDouble('pursuit_fee_percentage') ?? 2.5;
    final isExempt = prefs.getBool('is_tax_exempt') ?? false;

    // Update the state with the loaded values
    setState(() {
      _vatController.text = savedVat.toString();
      _pursuitFeeController.text = savedPursuitFee.toString();
      _isTaxExempt = isExempt;
    });
  }

  // Function to save all settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Get values from controllers
    final vatValue = double.tryParse(_vatController.text) ?? 0.0;
    final pursuitFeeValue = double.tryParse(_pursuitFeeController.text) ?? 0.0;

    // Save all three values
    await prefs.setDouble('vat_percentage', vatValue);
    await prefs.setDouble('pursuit_fee_percentage', pursuitFeeValue);
    await prefs.setBool('is_tax_exempt', _isTaxExempt);

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "نسبة الضريبة:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      // IMPORTANT: Control if the field is enabled
                      enabled: !_isTaxExempt,
                      controller: _vatController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'النسبة',
                        suffixText: '%',
                        border: const OutlineInputBorder(),
                        // Change background color when disabled for better UX
                        filled: true,
                        fillColor: _isTaxExempt ? Colors.grey[200] : Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- ADDED CHECKBOX HERE ---
              CheckboxListTile(
                title: const Text(
                  "معفي من الضريبه",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: _isTaxExempt,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isTaxExempt = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // Puts checkbox on the right for RTL
                contentPadding: EdgeInsets.zero,
              ),
              // --- END OF CHECKBOX ---

              const Divider(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "نسبة السعي:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      // Use the correct controller
                      controller: _pursuitFeeController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'النسبة',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveSettings, // Call the updated save function
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الإعدادات'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}